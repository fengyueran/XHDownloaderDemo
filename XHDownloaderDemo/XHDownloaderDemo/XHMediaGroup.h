//
//  XHMediaGroup.h
//  XHDownloaderDemo
//
//  Created by xinghun meng on 09/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

@class XHMediaFile;
#import <Foundation/Foundation.h>
#import "XHDownloader.h"

@interface XHMediaGroup : NSObject

@property (strong, nonatomic) NSString *groupID;
@property (nonatomic, assign) float progress;
/** 文件状态 */
@property (nonatomic, assign) MediaFileState state;

- (instancetype)initWithMediaArr:(NSMutableArray<XHMediaFile*> *)mediaArr;


@end
