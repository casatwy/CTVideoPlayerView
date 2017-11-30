//
//  ViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "ViewController.h"

#import "SingleVideoViewController.h"
#import "VideoTableViewController.h"
#import "DownloadThenPlayViewController.h"
#import "PlayAssetViewController.h"
#import "ChangeToFullScreenViewController.h"
#import "PlayControlViewController.h"
#import "VideoPlayIssue22ViewController.h"
#import "VideoRecordViewController.h"

#import <HandyFrame/UIView+LayoutMethods.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Main";
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView fill];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewControllerToPush = nil;

    NSDictionary *info = self.dataSource[indexPath.row];
    if (indexPath.row < 4) {
        viewControllerToPush = [[SingleVideoViewController alloc] initWithVideoUrlString:info[@"url"]];
    }
    if (indexPath.row == 4) {
        viewControllerToPush = [[VideoTableViewController alloc] initWithVideoUrlList:info[@"urlList"]];
    }
    if (indexPath.row == 5) {
        viewControllerToPush = [[DownloadThenPlayViewController alloc] initWithUrlString:info[@"url"]];
    }
    if (indexPath.row == 6) {
        viewControllerToPush = [[PlayAssetViewController alloc] initWithAsset:info[@"asset"]];
    }
    if (indexPath.row == 7 || indexPath.row == 8) {
        viewControllerToPush = [[ChangeToFullScreenViewController alloc] initWithVideoUrlString:info[@"url"]];
    }
    if (indexPath.row == 9) {
        viewControllerToPush = [[PlayControlViewController alloc] initWithVideoUrlString:info[@"url"]];
    }
    if (indexPath.row == 10) {
        viewControllerToPush = [[VideoPlayIssue22ViewController alloc] initWithVideoUrlString:info[@"url"]];
    }
    if (indexPath.row == 11) {
        viewControllerToPush = [[VideoRecordViewController alloc] init];
    }

    if (viewControllerToPush) {
        viewControllerToPush.title = info[@"title"];
        [self.navigationController pushViewController:viewControllerToPush animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
    return cell;
}

#pragma mark - getters and setters
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;

        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = @[
                        @{
                            @"title":@"Single Remote Video",
                            @"url":@"https://backend.flicklink.com:1337/parse/files/flicklinkAppId/a2d8aec7a78231c8c73eb2a8002283a7_PF-VID-2017-11-23T22-06-10AEDT.mov"
                            },
                        @{
                            @"title":@"Single Native Video",
                            @"url":[[[NSBundle mainBundle] URLForResource:@"b" withExtension:@"mov"] absoluteString]
                            },
                        @{
                            @"title":@"Short Single Live Stream Video",
                            @"url":@"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
                            },
                        @{
                            @"title":@"Long Single Live Stream Video",
                            @"url":@"http://devstreaming.apple.com/videos/wwdc/2015/502sufwcpog/502/hls_vod_mvp.m3u8"
                            },
                        @{
                            @"title":@"Videos in Tableview",
                            @"urlList":@[
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    @"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4",
                                    ]
                            },
                        @{
                            @"title":@"MP4 Download Then Play",
                            @"url":@"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4"
                            },
                        @{
                            @"title":@"Air Play Native Asset",
                            @"asset":[AVURLAsset assetWithURL:[[NSBundle mainBundle] URLForResource:@"a" withExtension:@"mp4"]]
                            },
                        @{
                            @"title":@"Horizontal Full Screen Demo",
                            @"url":@"https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4"
                            },
                        @{
                            @"title":@"Vertical Full Screen Demo",
                            @"url":[[[NSBundle mainBundle] URLForResource:@"a" withExtension:@"mp4"] absoluteString]
                            },
                        @{
                            @"title":@"Slide Play Control",
                            @"url":[[[NSBundle mainBundle] URLForResource:@"a" withExtension:@"mp4"] absoluteString]
                            },
                        @{
                            @"title":@"Issue #22",
                            @"url":[[[NSBundle mainBundle] URLForResource:@"a" withExtension:@"mp4"] absoluteString]
                            },
                        @{
                            @"title":@"Record Video"
                            },
                        ];
    }
    return _dataSource;
}

@end
