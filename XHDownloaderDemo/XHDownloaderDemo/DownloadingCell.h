//
//  DownloadingCell.h
//  Sample
//
//  Created by intern08 on 1/11/17.
//  Copyright © 2017 CyberyTech. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MediaFileInfo.h"

@interface DownloadingCell : UITableViewCell

@property (nonatomic, copy) NSString* ID;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadStateLabel;
- (void)updateStatus;
- (void) updateStatusWithGroup;

@end
