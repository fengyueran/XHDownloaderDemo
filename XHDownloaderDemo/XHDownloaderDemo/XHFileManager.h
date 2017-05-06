//
//  XHFileManager.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 06/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHMediaFile.h"

@protocol DeleteWorkDelegate
- (void)deleteTask:(NSString *)ID;
- (void)deleteAllTask;
@end

@interface XHFileManager : NSObject

@property (weak, nonatomic) id<DeleteWorkDelegate> delegate;

+ (instancetype)sharedInstance;
- (NSDictionary*) getJSONObject;
- (unsigned long long)fileSizeForPath:(NSString *)path;
- (void)saveFile:(XHMediaFile*) mf;
- (void)saveID:(XHMediaFile*) mf;
- (XHMediaFile*)getMediaByID:(NSString*)ID;
- (void)forceSaveAll;
- (int)runningCount;
- (void)deleteByID:(NSString*)ID;
- (void)deleteAll;

@end
