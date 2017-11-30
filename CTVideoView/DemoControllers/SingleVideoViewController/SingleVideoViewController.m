//
//  SingleVideoViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "SingleVideoViewController.h"
#import "CTVideoViewCommonHeader.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface SingleVideoViewController ()

@property (nonatomic, strong) CTVideoView *videoView;

@property (nonatomic, strong) UIButton *playOrPauseButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *cleanCacheButton;

@end

@implementation SingleVideoViewController

#pragma mark - life cycle
- (instancetype)initWithVideoUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.videoView.videoUrl = [NSURL URLWithString:urlString];
        [self.videoView prepare];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.videoView];
    [self.view addSubview:self.playOrPauseButton];
    [self.view addSubview:self.stopButton];
    [self.view addSubview:self.cleanCacheButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.videoView fill];

    self.playOrPauseButton.ct_size = CGSizeMake(SCREEN_WIDTH/3.0f, 50);
    [self.playOrPauseButton bottomInContainer:50 shouldResize:NO];
    [self.playOrPauseButton leftInContainer:0 shouldResize:NO];

    [self.stopButton sizeEqualToView:self.playOrPauseButton];
    [self.stopButton topEqualToView:self.playOrPauseButton];
    [self.stopButton right:0 FromView:self.playOrPauseButton];

    [self.cleanCacheButton sizeEqualToView:self.stopButton];
    [self.cleanCacheButton topEqualToView:self.stopButton];
    [self.cleanCacheButton right:0 FromView:self.stopButton];
}

#pragma mark - event response
- (void)didTappedCleanCacheButton:(UIButton *)button
{
    // do nothing
}

- (void)didTappedPlayOrPauseButton:(UIButton *)button
{
    if (self.videoView.isPlaying) {
        [self.videoView pause];
    } else {
        [self.videoView play];
    }
}

- (void)didTappedStopButton:(UIButton *)button
{
    [self.videoView stopWithReleaseVideo:YES];
}

#pragma mark - getters and setters
- (UIButton *)playOrPauseButton
{
    if (_playOrPauseButton == nil) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_playOrPauseButton setTitle:@"Play/Pause" forState:UIControlStateNormal];
        [_playOrPauseButton addTarget:self action:@selector(didTappedPlayOrPauseButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseButton;
}

- (UIButton *)stopButton
{
    if (_stopButton == nil) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [_stopButton addTarget:self action:@selector(didTappedStopButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}

- (UIButton *)cleanCacheButton
{
    if (_cleanCacheButton == nil) {
        _cleanCacheButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cleanCacheButton setTitle:@"Clean Cache" forState:UIControlStateNormal];
        [_cleanCacheButton addTarget:self action:@selector(didTappedCleanCacheButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanCacheButton;
}

- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.shouldReplayWhenFinish = NO;
        _videoView.shouldPlayAfterPrepareFinished = NO;
        _videoView.shouldChangeOrientationToFitVideo = YES;
        [_videoView setShouldObservePlayTime:YES withTimeGapToObserve:100];
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
