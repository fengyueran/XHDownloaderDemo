//
//  XHDownloaderConf.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 06/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHDownloaderConf.h"

@implementation XHDownloaderConf

+ (NSString *)pathRoot {
    NSString *documentPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathRoot = [documentPath stringByAppendingPathComponent:@"XHCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathRoot]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:pathRoot withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return pathRoot;
}

@end
