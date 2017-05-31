//
//  XHFileManager.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 06/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHMediaGroup.h"
#import "XHMediaFile.h"


@protocol DeleteWorkDelegate
- (void)deleteTask:(NSString *)ID;
- (void)deleteAllTask;
@end

@interface XHFileManager : NSObject

@property (weak, nonatomic) id<DeleteWorkDelegate> delegate;


/**
 文件管理实例

 */
+ (instancetype)sharedInstance;

/**
 获取所有下载的文件列表

 */
- (NSDictionary*) getJSONObject;

/**
 获取文件大小

 @param path 文件路径
 @return 文件大小的字节数
 */
- (unsigned long long)fileSizeForPath:(NSString *)path;

/**
 保存下载的文件信息

 */
- (void)saveFile:(XHMediaFile*) mf;

/**
 保存下载的文件ID

 */
- (void)saveID:(XHMediaFile*) mf;

/**
 获取文件信息

 @param ID 文件ID
 */
- (XHMediaFile*)getMediaByID:(NSString*)ID;

/**
 获取组文件信息

 @param groupID 文件组ID
 */
- (XHMediaGroup*)getMediaByGroupID:(NSString*)groupID;


- (NSArray*)getCompletedArr;
- (NSArray*)getUnompleteArr;

/**
 强制保存所有下载的数据信息到本地
 */
- (void)forceSaveAll;

/**
 获取所有正在下载的文件数

 */
- (int)runningCount;

/**
 删除数据

 @param ID 文件ID
 */
- (void)deleteByID:(NSString*)ID;

/**
 输出组数据

 @param groupID 组ID
 */
- (void)deleteByGroupID:(NSString*)groupID;

/**
 删除所有下载数据
 */
- (void)deleteAll;

@end
