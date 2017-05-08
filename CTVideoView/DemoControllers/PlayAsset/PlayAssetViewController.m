//
//  PlayAssetViewController.m
//  CTVideoView
//
//  Created by casa on 16/6/15.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "PlayAssetViewController.h"
#import "CTVideoViewCommonHeader.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface PlayAssetViewController ()

@property (nonatomic, strong) CTVideoView *videoView;
@property (nonatomic, strong) UIButton *airplayButton;
@property (nonatomic, strong) MPVolumeView *airplayIconView;

@end

@implementation PlayAssetViewController

#pragma mark - life cycle
- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        self.videoView.assetToPlay = asset;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.videoView];
    [self.view addSubview:self.airplayButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.videoView fill];
    
    self.airplayButton.ct_size = CGSizeMake(100, 50);
    [self.airplayButton bottomInContainer:50 shouldResize:NO];
    [self.airplayButton centerXEqualToView:self.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoView prepare];
}

#pragma mark - event response
- (void)didTappedAirPlayButton:(UIButton *)button
{
    if (self.videoView.player.isExternalPlaybackActive == YES) {
        NSLog(@"should close air play");
    } else {
        NSLog(@"should start air play");
        [self.view addSubview:self.airplayIconView];
        [self.airplayIconView centerEqualToView:self.view];
    }
}

#pragma mark - getters and setters
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.shouldShowOperationButton = YES;
    }
    return _videoView;
}

- (UIButton *)airplayButton
{
    if (_airplayButton == nil) {
        _airplayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_airplayButton addTarget:self action:@selector(didTappedAirPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [_airplayButton setTitle:@"air play" forState:UIControlStateNormal];
        [_airplayButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _airplayButton.backgroundColor = [UIColor grayColor];
    }
    return _airplayButton;
}

- (MPVolumeView *)airplayIconView
{
    if (_airplayIconView == nil) {
        _airplayIconView = [[MPVolumeView alloc] init];
        _airplayIconView.showsVolumeSlider = NO;
        [_airplayIconView sizeToFit];
    }
    return _airplayIconView;
}

@end
