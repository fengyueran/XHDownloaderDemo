//
//  XHMediaFile.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 03/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MediaFileState) {
    MediaFileStateStart,
    MediaFileStateSuspended,
    MediaFileStateDownloading,
    MediaFileStateFailed,
    MediaFileStateCompleted,
};

@interface XHMediaFile : NSObject
@property (nonatomic, strong) NSString *ID;
/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 数据的总长度 */
@property (nonatomic, assign) long long totalLength;
/** 已下载的数据大小 */
@property (nonatomic, assign) long long downloadedBytes;
/** 文件状态 */
@property (nonatomic, assign) MediaFileState state;
/** 下载进度 */
@property (nonatomic, copy) void(^progressBlock)(long long receivedSize, long long expectedSize, NSInteger progress);
/** 下载状态 */
@property (nonatomic, copy) void(^stateBlock)(MediaFileState MediaFileState);
@end
