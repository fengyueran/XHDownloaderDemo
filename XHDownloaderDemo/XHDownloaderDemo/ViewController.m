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



- (IBAction)download:(id)sender {
  NSString *url = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
  //url = @"https://r1---sn-a5mlrn7k.googlevideo.com/videoplayback?mn=sn-a5mlrn7k&gir=yes&mime=video%2Fmp4&dur=4389.616&id=o-ADzn_qS1lf-UKXyF3ftKQNPgs0Ocrwzsfo-QqSK55DBj&mv=m&mt=1493959643&ms=au&source=youtube&clen=283497517&ip=96.44.183.132&beids=%5B9466591%5D&itag=18&signature=A474BC53BF7D964942052AEC57EDD95A4885372C.D81CFA79A73F64FB9E89C314359992C3E8E8D1E7&requiressl=yes&ei=SAQMWfHvG4m--gP_loZI&mm=31&key=yt6&sparams=clen%2Cdur%2Cei%2Cgir%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&pl=24&ipbits=0&initcwndbps=6535000&ratebypass=yes&expire=1493981352&lmt=1458895827733146&upn=AHnQjOt86AE&cpn=J2af5-Uph5REploU&c=MWEB&cver=1.20170503&ptk=1V0nOCMxPppmiAd0CbDOpw&oid=tLXtYW8IwOzuGVkBa5PAfw&ptchn=1V0nOCMxPppmiAd0CbDOpw&pltype=content";
  [[XHDownloader sharedInstance] downloadWithURL:url progress:^(long long receivedSize, long long expectedSize, NSInteger speed) {
      dispatch_async(dispatch_get_main_queue(), ^{
          self.progressBar.progress = 1.0 * receivedSize/expectedSize;
      });
      
  } state:^(MediaFileState state) {
      dispatch_async(dispatch_get_main_queue(), ^{
          [self.button setTitle:[self getTitleWithDownloadState:state] forState:UIControlStateNormal];
      });
  }];
 
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
