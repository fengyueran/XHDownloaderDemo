//
//  XHDownloader.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHDownloaderConf.h"
#import "XHFileManager.h"
#import "XHDownloader.h"
#import "NSString+Hash.h"



@interface XHDownloader ()<NSURLSessionDataDelegate, DeleteWorkDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *cacheDir;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@property (nonatomic, assign) NSUInteger maxDownloads;

@property (nonatomic, strong) XHFileManager* fm;
/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *mediaFiles;
@end

@implementation XHDownloader

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XHDownloader *downloader;
    dispatch_once(&onceToken, ^{
        downloader = [[XHDownloader alloc]init];
    });
    return downloader;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _mediaFiles = [NSMutableDictionary dictionary];
        _tasks = [NSMutableDictionary dictionary];
        _maxDownloads = 2;
        _cacheDir = [XHDownloaderConf pathRoot];
        _fm = [XHFileManager sharedInstance];
        _fm.delegate = self;
        
    }
    return self;
}


- (void)downloadWithURL:(NSString *)url
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock {
    
    NSString *ID = url.md5String;
    
    if ([self isNewTask:ID]) {
        // 创建流
        NSString *cachePath = [_cacheDir stringByAppendingPathComponent:ID];
        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:cachePath append:YES];
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        //获取已下载的文件长度
        long long downloadedBytes = [self.fm fileSizeForPath:cachePath];
        
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",downloadedBytes];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        
        // 创建一个Data任务
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
        NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
        [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
        
        // 保存任务
        [self.tasks setValue:task forKey:ID];
        
        XHMediaFile *mediaFile = [[XHMediaFile alloc]init];
        mediaFile.url = url;
        mediaFile.stream = stream;
        mediaFile.downloadedBytes = downloadedBytes;
        mediaFile.stateBlock = stateBlock;
        mediaFile.progressBlock = progressBlock;
        mediaFile.addDate = [NSDate date];
        
        mediaFile.ID = ID;
        [self.mediaFiles setValue:mediaFile forKey:@(task.taskIdentifier).stringValue];
        
        [self queueTask:mediaFile task:task];
    }
    


}

- (void)queueTask:(XHMediaFile *)mediaFile task:(NSURLSessionDataTask *)task {
    [self.fm saveFile:mediaFile];
    [self.fm saveID:mediaFile];
    if ([self.fm runningCount] >= _maxDownloads) {
        [mediaFile stateChange:MediaFileStatePending];
    } else {
        [mediaFile stateChange:MediaFileStateDownloading];
        [task resume];
    }
   
}

- (void)launchNextTask {
    for (NSString* key in self.mediaFiles) {
        XHMediaFile* mf = [self.mediaFiles objectForKey:key];
        if (mf.state == MediaFileStatePending && [self.fm runningCount] < 2) {
            [mf stateChange:MediaFileStateDownloading];
            NSURLSessionDataTask *task = [self.tasks valueForKey:mf.ID];
            [task resume];
             [self.fm saveID:mf];
            
        }
    }
    
}

- (BOOL)isNewTask:(NSString *)ID {
      XHMediaFile *mediaFile =  [self.fm getMediaByID:ID];
    if (mediaFile) {
        if (mediaFile.state == MediaFileStateDownloading) {
            [self pause:ID];
            return NO;
        } else if (mediaFile.state == MediaFileStateCompleted) {
            return NO;
        }
    }
    return YES;
}


/**
 *  暂停下载
 */
- (void)pause:(NSString *)ID
{
    NSURLSessionDataTask *task = [self getTask:ID];
    [task cancel];
    XHMediaFile *mediaFile =  [self getMediaFile:task.taskIdentifier];
    [mediaFile stateChange:MediaFileStateSuspended];
    [self launchNextTask];
}



/**
 *  根据ID获得对应的下载任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)ID
{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:ID];
}

/**
 *  根据url获取对应的下载信息模型
 */
- (XHMediaFile *)getMediaFile:(NSUInteger)taskIdentifier
{
    return (XHMediaFile *)[self.mediaFiles valueForKey:@(taskIdentifier).stringValue];
}

- (void)deleteTask:(NSString *)ID {
    [self pause:ID];
}
#pragma mark NSURLSessionDataDelegate

/**
 * 接收到响应
 */

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    XHMediaFile *mediaFile = [self getMediaFile:dataTask.taskIdentifier];
    
    // 打开流
    [mediaFile.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalSize = response.expectedContentLength + mediaFile.downloadedBytes;
    mediaFile.totalSize = totalSize;
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
     XHMediaFile *mediaFile = [self getMediaFile:dataTask.taskIdentifier];
    
    // 写入数据
    [mediaFile.stream write:data.bytes maxLength:data.length];
    mediaFile.downloadedBytes += [data length];
    
    // 下载进度
    double receivedSize = mediaFile.downloadedBytes;
    double expectedSize = mediaFile.totalSize;
    NSUInteger progress = (int)(receivedSize/ expectedSize*100);
    NSLog(@"progress = %%%ld",progress);

    mediaFile.progressBlock(receivedSize, expectedSize, progress);
    mediaFile.progress = progress * 0.01;
    [self.fm saveFile:mediaFile];
}

/**
 * 请求完毕（成功|失败）
 */

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    XHMediaFile *mediaFile = [self getMediaFile:task.taskIdentifier];
    if (error) {
        [mediaFile stateChange:MediaFileStateFailed];
    } else {
        [mediaFile stateChange:MediaFileStateCompleted];
        mediaFile.completed = YES;
        [self.fm saveFile:mediaFile];
        [self.fm forceSaveAll];
        [self launchNextTask];
    }
        
    // 关闭流
    [mediaFile.stream close];
     mediaFile.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:mediaFile.ID];
    [self.mediaFiles removeObjectForKey:@(task.taskIdentifier).stringValue];

}

@end
