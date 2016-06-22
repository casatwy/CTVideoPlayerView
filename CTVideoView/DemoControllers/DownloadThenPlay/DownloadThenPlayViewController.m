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
#import "VideoDownloadingView.h"

@interface DownloadThenPlayViewController () <CTVideoViewDownloadDelegate>

@property (nonatomic, strong) CTVideoView *videoView;
@property (nonatomic, assign) BOOL hasBeenPaused;

@end

@implementation DownloadThenPlayViewController

#pragma mark - life cycle
- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        [CTVideoManager sharedInstance].downloadStrategy = CTVideoViewDownloadStrategyDownloadForegroundAndBackground;
        NSURL *videoUrl = [NSURL URLWithString:urlString];
        [[CTVideoManager sharedInstance] deleteVideoWithUrl:videoUrl];
        self.videoView.videoUrl = videoUrl;
        _hasBeenPaused = NO;
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
    DLog(@"Download Progress %.2f", progress);
    if (progress > 0.5) {
        if (self.hasBeenPaused == NO) {
            self.hasBeenPaused = YES;
            [[CTVideoManager sharedInstance] pauseDownloadTaskWithUrl:self.videoView.videoUrl completion:nil];
        }
    }
}

- (void)videoViewDidFinishDownload:(CTVideoView *)videoView
{
//    [self.videoView play];
}

- (void)videoViewDidFailDownload:(CTVideoView *)videoView
{

}

- (void)videoViewDidPausedDownload:(CTVideoView *)videoView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CTVideoManager sharedInstance] startDownloadTaskWithUrl:self.videoView.videoUrl];
    });
}

#pragma mark - getters and setter
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.downloadDelegate = self;
        _videoView.shouldReplayWhenFinish = YES;
        
        _videoView.downloadingView = [[VideoDownloadingView alloc] init];
        
        _videoView.shouldShowOperationButton = YES;
        
        _videoView.shouldShowCoverViewBeforePlay = YES;
        UILabel *coverView = [[UILabel alloc] init];
        coverView.text = @"Cover View";
        coverView.textAlignment = NSTextAlignmentCenter;
        coverView.backgroundColor = [UIColor blueColor];
        _videoView.coverView = coverView;
    }
    return _videoView;
}

@end
