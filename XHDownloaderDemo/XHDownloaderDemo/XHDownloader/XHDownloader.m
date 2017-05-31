//
//  XHDownloader.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHDownloaderConf.h"
#import "XHMediaGroup.h"
#import "XHFileManager.h"
#import "XHDownloader.h"
#import "NSString+Hash.h"



@interface XHDownloader ()<NSURLSessionDataDelegate, DeleteWorkDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *cacheDir;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@property (nonatomic, strong) NSArray* sortFiles;
@property (nonatomic, assign) BOOL sortDirty;
@property (nonatomic, assign) NSUInteger maxDownloads;

@property (nonatomic, strong) XHFileManager* fm;
/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *mediaFiles;
@end

@implementation XHDownloader
{
   NSString * _groupID;
}
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
        _sortFiles = [NSArray array];
        _tasks = [NSMutableDictionary dictionary];
        _maxDownloads = 4;
        _cacheDir = [XHDownloaderConf pathRoot];
        _fm = [XHFileManager sharedInstance];
        _fm.delegate = self;
        _sortDirty = YES;
        
    }
    return self;
}

- (void)downloadWithURL:(NSString *)url downloadDelegate:(id<DownloadDelegate>)delegate {
    self.delegate = delegate;
    [self downloadWithURL:url progress:nil state:nil];

}

- (void)downloadWithArr:(NSArray *)urls downloadDelegate:(id<DownloadDelegate>)delegate {
    self.delegate = delegate;
    [self downloadWithArr:urls progress:nil state:nil];
}

- (void)downloadWithArr:(NSArray *)urls
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock {
    _groupID = ((NSString *)urls[0]).md5String;
    for (int i = 0; i < urls.count; i++) {
        [self downloadWithURL:urls[i] progress:progressBlock state:stateBlock];
    }
}

- (void)downloadWithURL:(NSString *)url
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock {
    
    NSString *ID = url.md5String;
    
    if ([self isNewTask:ID]) {
        NSString *cachePath = [_cacheDir stringByAppendingPathComponent:ID];
        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:cachePath append:YES];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        //获取已下载的文件长度
        long long downloadedBytes = [self.fm fileSizeForPath:cachePath];
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",downloadedBytes];
        [request setValue:range forHTTPHeaderField:@"Range"];
        // 创建一个Data任务
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
        task.taskDescription = ID;
        // 保存任务
        [self.tasks setValue:task forKey:ID];
        
        XHMediaFile *mf = [self.mediaFiles valueForKey:ID];
        if (!mf) {
            mf = [[XHMediaFile alloc]init];
            mf.url = url;
            mf.downloadedBytes = downloadedBytes;
            mf.stateBlock = stateBlock;
            mf.progressBlock = progressBlock;
            mf.stream =stream;
            mf.ID = ID;
            mf.groupID = _groupID;
            [self.mediaFiles setValue:mf forKey:ID];

        }
        mf.downloadedBytes = downloadedBytes;
        mf.addDate = [NSDate date];
        [self queueTask:mf task:task];
    }
    

}

- (void)queueTask:(XHMediaFile *)mf task:(NSURLSessionDataTask *)task {
     self.sortDirty = YES;
    
    [self.fm saveFile:mf];
    [self.fm saveID:mf];
    if ([self.fm runningCount] >= _maxDownloads) {
        [mf stateChange:MediaFileStatePending];
    } else {
        [mf stateChange:MediaFileStateDownloading];
        [task resume];
       
    }
    
    [self notifyStateChange:mf];

}

- (void)notifyStateChange:(XHMediaFile *)mf {
    if (self.delegate) {
        if (mf.groupID) {
            [self.delegate refreshCellWithID:mf.groupID];
        } else {
            [self.delegate refreshCellWithID:mf.ID];
        }
    }
}

- (void)launchNextTask {
    self.sortFiles = [self getSortedMedia];
    self.sortDirty = NO;
    for (XHMediaFile* mf in self.sortFiles) {
        if (mf.state == MediaFileStatePending && [self.fm runningCount] < self.maxDownloads) {
            [mf stateChange:MediaFileStateDownloading];
            [self notifyStateChange:mf];
            NSURLSessionDataTask *task = [self.tasks valueForKey:mf.ID];
            [task resume];
             [self.fm saveID:mf];
            
        }
    }
    
}

- (BOOL)isNewTask:(NSString *)ID {
    XHMediaFile *mediaFile =  [self.fm getMediaByID:ID];
    if (mediaFile) {
        if (mediaFile.state == MediaFileStateDownloading || mediaFile.state == MediaFileStatePending) {
            [self pause:ID];
            return NO;
        } else if (mediaFile.state == MediaFileStateCompleted) {
            return NO;
        }
    }
    return YES;
}

- (NSArray*)getSortedMedia {
    if (self.sortDirty) {
        self.sortFiles = [self.mediaFiles.allValues sortedArrayUsingComparator:^NSComparisonResult(XHMediaFile*  _Nonnull obj1, XHMediaFile*  _Nonnull obj2) {
            return [obj1.addDate compare:obj2.addDate];
        }];
    }
    
    return self.sortFiles;
}




/**
 *  暂停下载
 */
- (void)pause:(NSString *)ID
{
    NSURLSessionDataTask *task = [self getTask:ID];
    [task cancel];
    XHMediaFile *mf =  [self getMediaFile:ID];
    [mf stateChange:MediaFileStateSuspended];
    [self notifyStateChange:mf];
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
- (XHMediaFile *)getMediaFile:(NSString *)ID
{
    return (XHMediaFile *)[self.mediaFiles valueForKey:ID];
}

- (void)deleteTask:(NSString *)ID {
    [self pause:ID];
}

- (void)deleteAllTask {
    for (NSURLSessionDataTask *task  in self.tasks.allValues) {
        [task cancel];
    }
    self.mediaFiles = [NSMutableDictionary new];
}

#pragma mark NSURLSessionDataDelegate

/**
 * 接收到响应
 */

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    XHMediaFile *mediaFile = [self getMediaFile:dataTask.taskDescription];
    [mediaFile didReceiveResponse:response];
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    XHMediaFile *mf = [self getMediaFile:dataTask.taskDescription];
    [mf didReceiveData:data];
    [self notifyStateChange:mf];
    [self.fm saveFile:mf];
}

/**
 * 请求完毕（成功|失败）
 */

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    XHMediaFile *mf = [self getMediaFile:task.taskDescription];

    if (mf) {
        if (!error) {
            [mf didCompleteWithError:error];
            [self.mediaFiles removeObjectForKey:mf.ID];
            [self.fm saveFile:mf];
            [self.fm forceSaveAll];
            [self launchNextTask];
        }
        
        [self notifyStateChange:mf];
        // 清除任务
        [self.tasks removeObjectForKey:mf.ID];
    }
}

@end
