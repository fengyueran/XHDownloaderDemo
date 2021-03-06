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

@property (strong, nonatomic) NSMutableDictionary *mediaFiles;
@property (strong, nonatomic) NSMutableDictionary *groupMediaFiles;
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
        _mediaFiles = [self getMediaInfoWithDB:_db];
        _groupMediaFiles = [NSMutableDictionary dictionary];
    }
    return self;
}

//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    long long fileSize = 0;
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
    [self.mediaFiles setObject:mf forKey:mf.ID];
}

- (void)forceSaveAll {
    [self.db forceSaveAll];
}

- (XHMediaFile*)getMediaByID:(NSString*)ID {
    return self.mediaFiles[ID];
}

- (XHMediaGroup*)getMediaByGroupID:(NSString*)groupID {
    NSMutableArray *array = [NSMutableArray array];
    for (XHMediaFile * mf in self.mediaFiles.allValues) {
        if ([mf.groupID isEqualToString:groupID]) {
            [array addObject:mf];
        }
    }
    XHMediaGroup *group = [[XHMediaGroup alloc]initWithMediaArr:array];
    return group;
}


- (NSArray*)getCompletedArr {
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (XHMediaFile *mf in self.mediaFiles.allValues) {
        if (mf.completed) {
            [tmpArr addObject:mf];
        }
    }
    return [tmpArr copy];
}

- (NSArray*)getUnompleteArr {
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (XHMediaFile *mf in self.mediaFiles.allValues) {
        if (!mf.completed) {
            [tmpArr addObject:mf];
        }
    }
    return [tmpArr copy];
}

- (int)runningCount {
    int count = 0;
    for (NSString* key in self.mediaFiles) {
        XHMediaFile* mf = [self.mediaFiles objectForKey:key];
        if (mf.state == MediaFileStateDownloading) {
            count++;
        }
    }
    return count;
}

- (void)deleteByID:(NSString*)ID {
    [self.mediaFiles removeObjectForKey:ID];
    [self.db saveProject:self];
    [self.db cleanByID:ID];
    [self.delegate deleteTask:ID];

}

- (void)deleteByGroupID:(NSString*)groupID {
    for (XHMediaFile *mf in self.mediaFiles.allValues) {
        if ([mf.groupID isEqualToString:groupID]) {
            [self deleteByID:mf.ID];
        }

    }
    
}

- (void)deleteAll {
    self.mediaFiles = [NSMutableDictionary new];
    [self.db cleanAll];
    [self.delegate deleteAllTask];
}

- (NSMutableDictionary *)getMediaInfoWithDB:(XHMediaDB *)db {
    NSDictionary* all = [db loadProject];
    NSArray* items = all[@"list"];
    NSMutableDictionary *mediaFiles = [NSMutableDictionary new];
    
    for(NSString* ID in items) {
        NSDictionary* value = [db loadFile:ID];
        if (value != nil) {
            XHMediaFile* mf = [[XHMediaFile alloc]initWithDictionary:value];
            if (mf == nil) continue;
            [mediaFiles setObject:mf forKey:ID];
        }
    }
    return mediaFiles;
    
}

- (NSDictionary*) getJSONObject {
    NSMutableDictionary* all = [NSMutableDictionary new];
    if (self.mediaFiles) {
        [all setObject:self.mediaFiles.allKeys  forKey:@"list"];
    }
    
    return all;
}

@end
