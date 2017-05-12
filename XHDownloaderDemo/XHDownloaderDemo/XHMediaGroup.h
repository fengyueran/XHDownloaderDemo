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

/** 文件组ID */
@property (strong, nonatomic) NSString *groupID;
/**文件组所包含的数据 */
@property (strong, nonatomic) NSMutableArray *mediaArr;
/** 文件组下载进度 */
@property (nonatomic, assign) NSUInteger progress;
/** 文件组下载状态 */
@property (nonatomic, assign) MediaFileState state;


/**
 初始化文件组

 @param mediaArr 包含文件信息的数组
 */
- (instancetype)initWithMediaArr:(NSMutableArray<XHMediaFile*> *)mediaArr;


@end
