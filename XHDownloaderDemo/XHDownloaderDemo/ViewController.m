//
//  ViewController.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 25/04/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "ViewController.h"
#import "XHDownloader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *download;
- (IBAction)download:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}



- (IBAction)download:(id)sender {
  NSString *url = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
  [[XHDownloader sharedInstance] downloadWithURL:url progress:^(NSInteger expectedSize, NSInteger receivedSize, NSInteger speed) {
      NSLog(@"downloading");
  } completed:^(BOOL finished) {
      NSLog(@"finish");
  }];
 
}

@end
