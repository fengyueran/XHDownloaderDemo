//
//  XHDownloader.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHMediaFile.h"

typedef void(^XHDownloaderProgressBlock)(long long receivedSize, long long expectedSize, NSInteger speed);
typedef void(^XHDownloaderStateBlock)( MediaFileState state);


@interface XHDownloader : NSObject

+ (instancetype)sharedInstance;
- (NSArray*)getMedia;
- (void)downloadWithURL:(NSString *)url
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock;

@end
