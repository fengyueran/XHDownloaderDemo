//
//  XHDownloader.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHDownloader.h"
#import "NSString+Hash.h"
#import "XHMediaFile.h"

@interface XHDownloader ()<NSURLSessionDataDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *cacheDir;
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
        
    }
    return self;
}

- (NSString *)createCacheDirectory {
    NSString *documentPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dataPath = [documentPath stringByAppendingString:@"XHCache"];
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
              completed:(XHDownloaderCompletedBlock)completedBlock {
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:[_cacheDir stringByAppendingString:url.md5String] append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //获取已下载的文件长度
    long long downloadedBytes = [self fileSizeForPath:url.md5String];
    
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",downloadedBytes];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    XHMediaFile *mediaFile = [[XHMediaFile alloc]init];
    [self.mediaFiles setValue:mediaFile forKey:@(task.taskIdentifier).stringValue];
    
    
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    //    MCDownloadOperation *dataOperation = [self operationWithTask:dataTask];
    //
    //    [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    // Identify the operation that runs this task and pass it the delegate method
    //    MCDownloadOperation *dataOperation = [self operationWithTask:dataTask];
    //
    //    [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    //    MCDownloadOperation *dataOperation = [self operationWithTask:dataTask];
    //
    //    [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // Identify the operation that runs this task and pass it the delegate method
    //    MCDownloadOperation *dataOperation = [self operationWithTask:task];
    //
    //    [dataOperation URLSession:session task:task didCompleteWithError:error];
}

@end
