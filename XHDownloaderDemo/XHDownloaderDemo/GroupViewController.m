//
//  ViewController.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "GroupViewController.h"
#import "XHFileManager.h"
#import "XHDownloader.h"
#import "DownloadingCell.h"
#import "NSString+Hash.h"
#import "XHMediaGroup.h"

@interface GroupViewController ()<UITableViewDelegate,UITableViewDataSource,DownloadDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary* cellMap;

- (IBAction)deleteAll:(id)sender;

@property (strong, nonatomic) NSMutableArray *urls;


@end

@implementation GroupViewController

- (NSMutableDictionary*) cellMap {
    if (!_cellMap) {
        _cellMap = [[NSMutableDictionary alloc]init];
    }
    return _cellMap;
}


- (IBAction)deleteAll:(id)sender {
    [[XHFileManager sharedInstance] deleteAll];
    [self.urls removeAllObjects];
    [self.tableView reloadData];
}

- (NSMutableArray *)urls
{
    if (!_urls) {
        _urls = [NSMutableArray array];
        for (int i = 1; i<=10; i=i+2) {
            NSMutableArray *group = [NSMutableArray array];
            [group addObject:[NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4", i]];
            [group addObject:[NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4", i+1]];
            [_urls addObject:group];
        }
    }
    return _urls;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XHDownloader sharedInstance].delegate = self;
    
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
    DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Downloading"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadingCell" owner:nil options:nil] firstObject];
    }
    
    cell.ID = ((NSString *)self.urls[indexPath.row][0]).md5String;
    [self.cellMap setObject:cell forKey:cell.ID];

    [cell updateStatusWithGroup];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *urlArr = self.urls[indexPath.row];
    
    DownloadingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [[XHDownloader sharedInstance]downloadWithArr:urlArr downloadDelegate:self];
    
//    [[XHDownloader sharedInstance] downloadWithArr:urlArr progress:^(NSString *ID) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [cell updateStatusWithGroup];
//            
//        });
//        
//    } state:^(MediaFileState state) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [cell updateStatusWithGroup];
//        });
//    }];

    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = self.urls[indexPath.row][0];
    [[XHFileManager sharedInstance]deleteByGroupID:url.md5String];
    [self.urls removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)refreshCellWithID:(NSString *)ID {
    //DownloadingCell *cell =  [self.cellMap valueForKey:ID];
    dispatch_async(dispatch_get_main_queue(), ^{
        DownloadingCell *cell =  [self.cellMap valueForKey:ID];
        [cell updateStatusWithGroup];
        
    });
    
}



@end
