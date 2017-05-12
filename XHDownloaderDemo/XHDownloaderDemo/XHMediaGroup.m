//
//  XHMediaGroup.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 09/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHMediaGroup.h"

@implementation XHMediaGroup

- (instancetype)initWithMediaArr:(NSMutableArray<XHMediaFile*> *)mediaArr {
    self = [super init];
    if (self) {
        _mediaArr = mediaArr;
        if (mediaArr.count > 0) {
            [self updateStatus];
        } else {
            return nil;
        }

    }
    return self;
}

- (void)updateStatus {
    int count = 0;
    int cacheCompletedNum = 0;
    int pendingFileNum = 0;
    _progress = 0;
    for (XHMediaFile *mf in _mediaArr) {
        _progress += mf.progress;
        
        count ++;
        if (mf.state == MediaFileStateDownloading) {
            _state = MediaFileStateDownloading;
        } else if (mf.state == MediaFileStateCompleted) {
            cacheCompletedNum ++;
        } else if (mf.state == MediaFileStatePending){
            pendingFileNum ++;
        }
    }
    if (count == cacheCompletedNum) {
        _state = MediaFileStateCompleted;
    } else if (count == pendingFileNum) {
        _state = MediaFileStatePending;
    }
    _progress =(int)((_progress * 1.0)/count);
    NSLog(@"progress=%ld",_progress);
}


@end
