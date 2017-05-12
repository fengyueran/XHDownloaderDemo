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

/**
 代理更新下载数据状态

 @param ID 文件ID
 */
- (void)refreshCellWithID:(NSString *)ID;

@end

typedef void(^XHDownloaderProgressBlock)(NSString *ID);
typedef void(^XHDownloaderStateBlock)( MediaFileState state);


@interface XHDownloader : NSObject

@property (nonatomic, weak) id delegate;


/**
 XHDownloader实例

 */
+ (instancetype)sharedInstance;

/**
 单个文件下载

 @param url 文件下载地址
 @param delegate 数据更新代理
 */
- (void)downloadWithURL:(NSString *)url downloadDelegate:(id<DownloadDelegate>)delegate;

/**
 多个文件同时下载(公用UI)

 @param urls 文件地址
 @param delegate 数据更新代理
 */
- (void)downloadWithArr:(NSArray *)urls downloadDelegate:(id<DownloadDelegate>)delegate;

/**
 单个文件下载

 @param url 文件下载地址
 @param progressBlock 下载进度block
 @param stateBlock 下载状态block
 */
- (void)downloadWithURL:(NSString *)url
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock;

/**
 多个文件同时下载(公用UI)
 
 @param urls 文件下载地址
 @param progressBlock 下载进度block
 @param stateBlock 下载状态block
 */

- (void)downloadWithArr:(NSArray *)urls
               progress:(XHDownloaderProgressBlock)progressBlock
                  state:(XHDownloaderStateBlock)stateBlock;

@end
