//
//  ViewController.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "ViewController.h"
#import "XHFileManager.h"
#import "XHDownloader.h"
#import "DownloadingCell.h"
#import "NSString+Hash.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)deleteAll:(id)sender;

@property (strong, nonatomic) NSMutableArray *urls;


@end

@implementation ViewController

- (IBAction)deleteAll:(id)sender {
    [[XHFileManager sharedInstance] deleteAll];
    [self.urls removeAllObjects];
    [self.tableView reloadData];
}

- (NSMutableArray *)urls
{
    if (!_urls) {
        self.urls = [NSMutableArray array];
        for (int i = 2; i<=10; i++) {
            [self.urls addObject:[NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4", i]];
        }
    }
    return _urls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadingCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadingCell" owner:nil options:nil] firstObject];
    cell.ID = ((NSString *)self.urls[indexPath.row]).md5String;
    [cell updateStatus];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = self.urls[indexPath.row];
    DownloadingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[XHDownloader sharedInstance] downloadWithURL:url progress:^(long long receivedSize, long long expectedSize, NSInteger speed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell updateStatus];
            
        });
        
    } state:^(MediaFileState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell updateStatus];
        });
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = self.urls[indexPath.row];
    [[XHFileManager sharedInstance]deleteByID:url.md5String];
    [self.urls removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

@end
