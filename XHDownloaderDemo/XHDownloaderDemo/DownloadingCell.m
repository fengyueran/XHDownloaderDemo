////
////  DownloadingCell.m
////  Sample
////
////  Created by intern08 on 1/11/17.
////  Copyright © 2017 CyberyTech. All rights reserved.
////
//
#import "DownloadingCell.h"
//#import "CommonHelper.h"
//#import "MediaManager.h"
//#import "MediaFile.h"
//#import "UIImageView+WebCache.h"
//#import "DownloadErrorCode.h"
//
@interface DownloadingCell ()
//@property (nonatomic, readonly) MediaFile* mf;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadStateLabel;
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
//
//- (MediaFile*) mf {
//	return [[MediaManager sharedInstance] getMediaByID:self.ID];
//}
//
//- (void) updateStatus {
//	MediaFile* mf = self.mf;
//	if (mf == nil) {
//		return;
//	}
//
//	self.fileNameLabel.text = mf.info.name;
//
//    if (!_thumbnailSet && mf.thumbnailURL) {
//        if (mf.info.poster.absoluteString.length > 0) {
//            [self.thumbnailImageView sd_setImageWithURL:mf.info.poster completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                if (!image) {
//                    [self.thumbnailImageView sd_setImageWithURL:mf.thumbnailURL placeholderImage:[UIImage imageNamed:@"thumbnail.png"]];
//                }
//            }];
//        } else {
//            [self.thumbnailImageView sd_setImageWithURL:mf.thumbnailURL placeholderImage:[UIImage imageNamed:@"thumbnail.png"]];
//        }
//        _thumbnailSet = YES;
//    }
//    
//	NSString* progressStr = [CommonHelper getProgressString:mf.info.progress];
//	self.progressLabel.text = [CommonHelper getFileSizeString:mf.info.sinfo.downloadedBytes];
//	self.progressView.progress = mf.info.progress;
//
//	if (_lastState != mf.state) {
//		_lastState = mf.state;
//		self.speedLabel.text = @"";
//
//		switch (mf.state) {
//			case 0:
//				self.downloadStateLabel.text = [NSString stringWithFormat:@"%@ (%@)", TRANS(@"Pause"), progressStr];
//				self.maskView.hidden = NO;
//				break;
//			case 1:
//				self.maskView.hidden = YES;
//				break;
//			case 2:
//				self.downloadStateLabel.text = TRANS(@"Queueing");
//				self.maskView.hidden = YES;
//				break;
//			case 3:
//				self.downloadStateLabel.text = TRANS(@"Play");
//				break;
//			default:
//				self.downloadStateLabel.text = @"";
//				break;
//		}
//	}
//
//	if (mf.state == 1) {
//		self.downloadStateLabel.text = [NSString stringWithFormat:@"%@ (%@)", TRANS(@"Downloading"), progressStr];
//		self.speedLabel.text = [CommonHelper getSpeedString:[mf calculateDownloadSpeed]];
//	}
//
//	if (mf.info.lastErrorCode == DownloadErrorCode404) {
//		self.downloadStateLabel.text = TRANS(@"Video link is dead");
//		self.fileNameLabel.textColor = self.downloadStateLabel.textColor;
//		self.downloadStateLabel.textColor = [UIColor redColor];
//	}
//
//}
//

@end
