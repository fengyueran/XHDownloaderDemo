//
//  ViewController.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "ViewController.h"
#import "XHDownloader.h"
#import "DownloadingCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *urls;

- (IBAction)download:(id)sender;

@end

@implementation ViewController

- (NSMutableArray *)urls
{
    if (!_urls) {
        self.urls = [NSMutableArray array];
        for (int i = 1; i<=10; i++) {
            [self.urls addObject:[NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4", i]];
        }
    }
    return _urls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"XHCELL"];
}



#pragma mark 按钮状态
- (NSString *)getTitleWithDownloadState:(MediaFileState)state {
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
    return @"false";

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadingCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadingCell" owner:nil options:nil] firstObject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = self.urls[indexPath.row];
     DownloadingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[XHDownloader sharedInstance] downloadWithURL:url progress:^(long long receivedSize, long long expectedSize, NSInteger speed) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            cell.progressLabel.text = [NSString stringWithFormat:@"%f",1.0 * receivedSize/expectedSize];
           
        });
        
    } state:^(MediaFileState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.downloadStateLabel.text = [self getTitleWithDownloadState:state];
                   });
    }];
}

@end
