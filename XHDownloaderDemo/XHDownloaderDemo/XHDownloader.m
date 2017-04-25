//
//  XHDownloader.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHDownloader.h"

@interface XHDownloader ()<NSURLSessionDataDelegate>
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (strong, nonatomic) NSURLSession *session;
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
        _downloadQueue = [[NSOperationQueue alloc]init];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        
    }
    return self;
}


- (void)downloadWithURL:(NSURL *)url
               progress:(XHDownloaderProgressBlock)progressBlock
              completed:(XHDownloaderCompletedBlock)completedBlock {
    
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
