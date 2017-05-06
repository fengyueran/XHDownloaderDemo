////
////  DownloadingCell.m
////  Sample
////
////  Created by intern08 on 1/11/17.
////  Copyright © 2017 CyberyTech. All rights reserved.
////
//
#import "DownloadingCell.h"
#import "XHFileManager.h"
#import "XHMediaFile.h"
//#import "UIImageView+WebCache.h"
//#import "DownloadErrorCode.h"
//
@interface DownloadingCell ()
//@property (nonatomic, readonly) MediaFile* mf;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *maskView;


@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end

@implementation DownloadingCell


- (void)awakeFromNib
{
	[super awakeFromNib];

}

- (XHMediaFile*) mf {
	return [[XHFileManager sharedInstance] getMediaByID:self.ID];
}

- (void) updateStatus {
	XHMediaFile* mf = self.mf;
	if (mf == nil) {
		return;
	}

//	self.fileNameLabel.text = mf.info.name;
    NSUInteger progress = (int)(mf.progress*100);
	NSString* progressStr = [NSString stringWithFormat:@"%%%ld",progress];
	self.progressLabel.text = progressStr;
	self.progressView.progress = mf.progress;

    self.downloadStateLabel.text = [self getState:mf.state];

}

- (NSString *)getState:(MediaFileState)state {
    switch (state) {
        case MediaFileStateDownloading:
            return @"下载中";
        case MediaFileStateFailed:
        case MediaFileStateSuspended:
            return @"暂停";
        case MediaFileStatePending:
            return @"等待下载";
        case MediaFileStateCompleted:
            return @"完成";
        default:
            break;
    }
}

@end
