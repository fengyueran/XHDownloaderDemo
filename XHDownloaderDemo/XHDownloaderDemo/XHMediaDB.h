//
//  db.h
//  Sample
//
//  Created by lining on 08/12/2016.
//  Copyright © 2016 CyberyTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XHMediaFile;
@class XHFileManager;

@interface XHMediaDB : NSObject


/**
 初始化数据保存的根目录

 @return XHMediaDB数据库实例
 */
- (id)initWithPathRoot:(NSString *)pathRoot;


/**
 载入所有下载数据信息

 @return 所有下载数据信息的字典
 */
- (NSDictionary*)loadProject;


/**
 保存所有数据的ID

 */
- (void)saveProject:(XHFileManager*)mm;


/**
 保存数据到内存

 @param mf 需要保存的信息
 */
- (void)saveFile:(XHMediaFile*)mf;


/**
 载入特定数据信息

 @param ID 数据ID
 @return 数据信息的字典
 */
- (NSDictionary*)loadFile:(NSString*)ID;


/**
 强制保存所有数据到本地
 */
- (void)forceSaveAll;


/**
 清除特定的下载数据

 @param ID 数据ID
 */
- (void)cleanByID:(NSString*)ID;


/**
 清除所有下载数据
 */
- (void)cleanAll;

@end
