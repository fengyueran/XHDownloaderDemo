//
//  XHDownloader.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHDownloader.h"
#import "NSString+Hash.h"



@interface XHDownloader ()<NSURLSessionDataDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *cacheDir;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@property (nonatomic, assign) NSUInteger maxDownloads;
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
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _cacheDir = [self createCacheDirectory];
        _mediaFiles = [NSMutableDictionary dictionary];
        _tasks = [NSMutableDictionary dictionary];
        _maxDownloads = 2;
        
    }
    return self;
}

- (NSString *)createCacheDirectory {
    NSString *documentPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"XHCache"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    return dataPath;
}

//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

- (void)downloadWithURL:(NSString *)url
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock {

    
    NSString *ID = url.md5String;
    
    // 暂停
    if ([self.tasks valueForKey:ID]) {
        [self handle:ID];
        return;
    }
    

//    [self createTaskWithID:<#(NSString *)#>ID]
    // 创建流
    NSString *cachePath = [_cacheDir stringByAppendingPathComponent:ID];
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:cachePath append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //获取已下载的文件长度
    long long downloadedBytes = [self fileSizeForPath:cachePath];
    
    
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
    mediaFile.stream = stream;
    mediaFile.downloadedBytes = downloadedBytes;
    mediaFile.stateBlock = stateBlock;
    mediaFile.progressBlock = progressBlock;
    
    mediaFile.ID = ID;
    [self.mediaFiles setValue:mediaFile forKey:@(task.taskIdentifier).stringValue];

    [self queueTask:mediaFile task:task];

    


}

- (void)queueTask:(XHMediaFile *)mediaFile task:(NSURLSessionDataTask *)task {
    if ([self runningCount] >= _maxDownloads) {
        mediaFile.state = MediaFileStatePending;
    } else {
         mediaFile.state = MediaFileStateDownloading;
         [task resume];
    }
   
}

- (void)launchNextTask {
    for (NSString* key in self.mediaFiles) {
        XHMediaFile* mf = [self.mediaFiles objectForKey:key];
        if (mf.state == MediaFileStatePending && [self runningCount] < 2) {
            mf.state = MediaFileStateDownloading;
            NSURLSessionDataTask *task = [self.tasks valueForKey:mf.ID];
            [task resume];
            
        }
    }
    
}

- (void)handle:(NSString *)ID
{
    NSURLSessionDataTask *task = [self getTask:ID];
    XHMediaFile *mediaFile =  [self getMediaFile:task.taskIdentifier];

    if (mediaFile.state == MediaFileStateDownloading) {
        [self pause:ID];
    }
}


/**
 *  暂停下载
 */
- (void)pause:(NSString *)ID
{
    NSURLSessionDataTask *task = [self getTask:ID];
    [task cancel];
    XHMediaFile *mediaFile =  [self getMediaFile:task.taskIdentifier];
    mediaFile.state = MediaFileStateSuspended;
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

- (int)runningCount {
    int count = 0;
    for (NSString* key in self.mediaFiles) {
        XHMediaFile* mf = [self.mediaFiles objectForKey:key];
        if (mf.state == MediaFileStateDownloading) {
            count++;
        }
    }
    return count;
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
    NSInteger totalLength = response.expectedContentLength + mediaFile.downloadedBytes;
    mediaFile.totalLength = totalLength;
    
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
    double expectedSize = mediaFile.totalLength;
    NSUInteger progress = (int)(receivedSize/ expectedSize*100);
    NSLog(@"progress = %%%ld",progress);

    mediaFile.progressBlock(receivedSize, expectedSize, progress);
}

/**
 * 请求完毕（成功|失败）
 */

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    XHMediaFile *mediaFile = [self getMediaFile:task.taskIdentifier];
    if (error) {
        mediaFile.state = MediaFileStateFailed;
    } else {
        mediaFile.state = MediaFileStateCompleted;
    }
        
    // 关闭流
    [mediaFile.stream close];
     mediaFile.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:mediaFile.ID];
    [self.mediaFiles removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    [self launchNextTask];
}

@end
