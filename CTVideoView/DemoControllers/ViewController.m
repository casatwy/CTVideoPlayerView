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
                            @"url":@"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_865e1fff817746d29ecc4996f93b7f74"
                            },
                        @{
                            @"title":@"Single Native Video",
                            @"url":[[[NSBundle mainBundle] URLForResource:@"a" withExtension:@"mp4"] absoluteString]
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
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_856a6738eefc495bbd7b0ed59beaa9fe",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_e05f72400bae4e0b8ae6825c5891af64",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_f905cb3d6a1847afb071b3aeea42eb51",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_57dad11ccfd3422cbe6f0b2674fa0ab1",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_b5b00d7e77854a2ea478cd5dd648191d",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_d7c0843949284cb79a8f4bed20111577",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_34dd3f3f36974092876efbcac1d1160d",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_42b791e5aed7463b865518378a78de6a",
                                    @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_03e0b80cc69b4f069af9b5ba88be6752",
                                    ]
                            },
                        @{
                            @"title":@"MP4 Download Then Play",
                            @"url":@"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_e05f72400bae4e0b8ae6825c5891af64"
                            },
                        @{
                            @"title":@"Air Play Native Asset",
                            @"asset":[AVURLAsset assetWithURL:[[NSBundle mainBundle] URLForResource:@"a" withExtension:@"mp4"]]
                            },
                        @{
                            @"title":@"Horizontal Full Screen Demo",
                            @"url":@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
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
                        ];
    }
    return _dataSource;
}

@end
