//
//  XHDownloader.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^XHDownloaderProgressBlock)(NSInteger expectedSize, NSInteger receivedSize, NSInteger speed);
typedef void(^XHDownloaderCompletedBlock)( BOOL finished);


@interface XHDownloader : NSObject

+ (instancetype)sharedInstance;

- (void)downloadWithURL:(NSString *)url
               progress:(XHDownloaderProgressBlock)progressBlock
              completed:(XHDownloaderCompletedBlock)completedBlock;
@end
