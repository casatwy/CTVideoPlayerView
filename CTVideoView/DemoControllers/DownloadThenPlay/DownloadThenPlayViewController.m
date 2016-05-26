//
//  DownloadThenPlayViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "DownloadThenPlayViewController.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import "CTVideoViewCommonHeader.h"

@interface DownloadThenPlayViewController () <CTVideoViewDownloadDelegate>

@property (nonatomic, strong) CTVideoView *videoView;

@end

@implementation DownloadThenPlayViewController

#pragma mark - life cycle
- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.videoView.videoUrl = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.videoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.videoView fill];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoView prepare];
    [self.videoView startDownloadTask];
}

#pragma mark - CTVideoViewDownloadDelegate
- (void)videoViewWillStartDownload:(CTVideoView *)videoView
{

}

- (void)videoView:(CTVideoView *)videoView downloadProgress:(CGFloat)progress
{
    DLog(@"progress %.2f", progress);
}

- (void)videoViewDidFinishDownload:(CTVideoView *)videoView
{
    if (self.videoView.actualVideoUrlType != CTVideoViewVideoUrlTypeNative) {
        [self.videoView refreshUrl];
    }
    [self.videoView play];
}

- (void)videoViewDidFailDownload:(CTVideoView *)videoView
{

}

#pragma mark - getters and setter
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.downloadStrategy = CTVideoViewDownloadStrategyDownloadForegroundAndBackground;
        _videoView.downloadDelegate = self;
        _videoView.shouldReplayWhenFinish = YES;
    }
    return _videoView;
}

@end
