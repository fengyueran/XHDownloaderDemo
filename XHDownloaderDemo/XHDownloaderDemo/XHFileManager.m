//
//  XHFileManager.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 06/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHFileManager.h"

#import "XHMediaDB.h"
#import "XHDownloaderConf.h"

@interface XHFileManager ()

@property (strong, nonatomic) NSMutableDictionary *mediaInfo;
@property (strong, nonatomic) XHMediaDB *db;

@end

@implementation XHFileManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XHFileManager *downloader;
    dispatch_once(&onceToken, ^{
        downloader = [[XHFileManager alloc]init];
    });
    return downloader;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _db = [[XHMediaDB alloc]initWithPathRoot:[XHDownloaderConf pathRoot]];
        _mediaInfo = [self getMediaInfoWithDB:_db];
        
    }
    return self;
}

//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

- (void)saveFile:(XHMediaFile *)mf {
    if (mf) {
        [self.db saveFile:mf];
    }

}
- (void)saveID:(XHMediaFile*) mf {
    [self.db saveProject:self];
    [self.mediaInfo setObject:mf forKey:mf.ID];
}

- (NSMutableDictionary *)getMediaInfoWithDB:(XHMediaDB *)db {
    NSDictionary* all = [db loadProject];
    NSArray* items = all[@"list"];
    NSMutableDictionary *mediaInfo = [NSMutableDictionary new];
    
    for(NSString* ID in items) {
        NSDictionary* value = [db loadFile:ID];
        if (value != nil) {
            [mediaInfo setObject:value forKey:ID];
        }
    }
    return mediaInfo;
    
}

- (NSDictionary*) getJSONObject {
    NSMutableDictionary* all = [NSMutableDictionary new];
    [all setObject:self.mediaInfo.allKeys  forKey:@"list"];
    return all;
}

@end
