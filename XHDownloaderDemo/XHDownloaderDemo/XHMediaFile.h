//
//  XHMediaFile.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 03/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//


#import <Foundation/Foundation.h>

/** 下载文件状态 */
typedef NS_ENUM(NSInteger, MediaFileState) {
    MediaFileStateSuspended,
    MediaFileStateDownloading,
    MediaFileStatePending,
    MediaFileStateFailed,
    MediaFileStateCompleted,
};

@interface XHMediaFile : NSObject

/** 文件下载ID */
@property (nonatomic, strong) NSString *ID;
/** 文件组下载ID */
@property (nonatomic, strong) NSString *groupID;
/** 文件下载url */
@property (nonatomic, strong) NSString *url;
/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 数据的总长度 */
@property (nonatomic, assign) long long totalSize;
/** 已下载的数据大小 */
@property (nonatomic, assign) long long downloadedBytes;
/** 数据下载进度 */
@property (nonatomic, assign) NSUInteger progress;
/** 文件状态 */
@property (nonatomic, assign) MediaFileState state;
/** 数据下载日期 */
@property (nonatomic, strong) NSDate* addDate;
/** 文件下载是否完成 */
@property (nonatomic, assign) BOOL completed;
/** 下载进度block */
@property (nonatomic, copy) void(^progressBlock)(NSString *ID);
/** 下载状态block */
@property (nonatomic, copy) void(^stateBlock)(MediaFileState MediaFileState);


/**
 获取下载文件列表
 
 */
- (NSDictionary*) getJSONObject;

/**
 初始化下载信息

 @param dic 载入的本地信息文件
 @return 下载信息实例
 */
- (instancetype)initWithDictionary:(NSDictionary *)dic;

/**
 数据下载过程的状态变化

 @param state 下载状态
 */
- (void)stateChange:(MediaFileState)state;


/**
 处理数据下载不同阶段的文件状态变化

 */
- (void)didReceiveResponse:(NSURLResponse *)response;
- (void)didReceiveData:(NSData *)data;
- (void)didCompleteWithError:(NSError *)error;
@end
