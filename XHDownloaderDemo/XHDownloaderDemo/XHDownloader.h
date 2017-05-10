//
//  XHDownloader.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHMediaFile.h"

@protocol DownloadDelegate <NSObject>

- (void)refreshCellWithID:(NSString *)ID;

@end
typedef void(^XHDownloaderProgressBlock)(NSString *ID);
typedef void(^XHDownloaderStateBlock)( MediaFileState state);


@interface XHDownloader : NSObject

@property (nonatomic, weak) id delegate;

+ (instancetype)sharedInstance;
- (void)downloadWithURL:(NSString *)url downloadDelegate:(id<DownloadDelegate>)delegate;
- (void)downloadWithURL:(NSString *)url
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock;
                  
- (void)downloadWithArr:(NSArray *)urls
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock;

@end
