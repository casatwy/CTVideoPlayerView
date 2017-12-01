//
//  ChangeOrientationViewController.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "ChangeToFullScreenViewController.h"
#import "CTVideoViewCommonHeader.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface ChangeToFullScreenViewController () <CTVideoViewOperationDelegate, CTVideoViewFullScreenDelegate>

@property (nonatomic, strong) CTVideoView *videoView;
@property (nonatomic, strong) UIButton *fullScreenButton;

@property (nonatomic, strong) UIView *sliderView;
@end

@implementation ChangeToFullScreenViewController

#pragma mark - life cycle
- (instancetype)initWithVideoUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.videoView.videoUrl = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.videoView];
    [self.videoView addSubview:self.fullScreenButton];
    [self.videoView addSubview:self.sliderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.videoView.ct_size = CGSizeMake(100, 200);
    [self.videoView centerEqualToView:self.view];
    
    self.fullScreenButton.ct_size = CGSizeMake(100, 100);
    [self.fullScreenButton centerEqualToView:self.videoView];
    
    [self.sliderView fillWidth];
    self.sliderView.ct_height = 20;
    [self.sliderView bottomInContainer:0 shouldResize:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoView prepare];
}

#pragma mark - CTVideoViewOperationDelegate
- (void)videoViewDidFinishPrepare:(CTVideoView *)videoView
{
    [videoView play];
}

- (void)videoViewDidFinishPlaying:(CTVideoView *)videoView
{
    [videoView replay];
}

#pragma mark - CTVideoViewFullScreenDelegate
- (void)videoViewLayoutSubviewsWhenExitFullScreen:(CTVideoView *)videoView
{
    self.fullScreenButton.ct_size = CGSizeMake(100, 100);
    [self.fullScreenButton centerEqualToView:self.videoView];
    
    [self.sliderView fillWidth];
    self.sliderView.ct_height = 20;
    [self.sliderView bottomInContainer:0 shouldResize:NO];
}

- (void)videoViewLayoutSubviewsWhenEnterFullScreen:(CTVideoView *)videoView
{
    self.fullScreenButton.ct_size = CGSizeMake(100, 100);
    [self.fullScreenButton centerEqualToView:self.videoView];
    
    [self.sliderView fillWidth];
    self.sliderView.ct_height = 20;
    [self.sliderView bottomInContainer:0 shouldResize:NO];
}

#pragma mark - Event Response
- (void)didTappedFullScreenButton:(UIButton *)fullScreenButton
{
    if (self.videoView.isFullScreen) {
        [self.videoView exitFullScreen];
    } else {
        [self.videoView enterFullScreen];
    }
}

#pragma mark - getters and setters
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.operationDelegate = self;
        _videoView.fullScreenDelegate = self;
    }
    return _videoView;
}

- (UIButton *)fullScreenButton
{
    if (_fullScreenButton == nil) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_fullScreenButton addTarget:self
                              action:@selector(didTappedFullScreenButton:)
                    forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenButton setTitle:@"Full Screen" forState:UIControlStateNormal];
        [_fullScreenButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _fullScreenButton;
}

- (UIView *)sliderView
{
    if (_sliderView == nil) {
        _sliderView = [[UIView alloc] init];
        _sliderView.backgroundColor = [UIColor blackColor];
    }
    return _sliderView;
}

@end
