//
//  XHMediaFile.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 03/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHMediaFile.h"

@implementation XHMediaFile

- (void)setState:(MediaFileState)state {
    _state = state;
    _stateBlock(_state);
    
}

@end
