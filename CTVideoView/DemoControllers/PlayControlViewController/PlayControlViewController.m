//
//  PlayControlViewController.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "PlayControlViewController.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import "CTVideoViewCommonHeader.h"

@interface PlayControlViewController () <CTVideoViewOperationDelegate, CTVideoViewPlayControlDelegate>

@property (nonatomic, strong) CTVideoView *videoView;
@property (nonatomic, strong) UILabel *simplePlayControlIndicator;

@end

@implementation PlayControlViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.videoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.videoView fill];
}

#pragma mark - CTVideoViewOperationDelegate
- (void)videoViewDidFinishPrepare:(CTVideoView *)videoView
{
    [videoView play];
}

- (void)videoViewDidFinishPlaying:(CTVideoView *)videoView
{
    NSLog(@"video did finish playing");
}

#pragma mark - CTVideoViewPlayControlDelegate
- (void)videoViewShowPlayControlIndicator:(CTVideoView *)videoView
{
    self.simplePlayControlIndicator.text = [NSString stringWithFormat:@"current:%.2f total:%.2f", videoView.currentPlaySecond, videoView.totalDurationSeconds];
    [self.simplePlayControlIndicator sizeToFit];
    self.simplePlayControlIndicator.alpha = 0.0f;
    [videoView addSubview:self.simplePlayControlIndicator];
    [self.simplePlayControlIndicator centerEqualToView:videoView];
    [UIView animateWithDuration:0.3f animations:^{
        self.simplePlayControlIndicator.alpha = 1.0f;
    }];
}

- (void)videoViewHidePlayControlIndicator:(CTVideoView *)videoView
{
    [UIView animateWithDuration:0.3f animations:^{
        self.simplePlayControlIndicator.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.simplePlayControlIndicator removeFromSuperview];
    }];
}

- (void)videoView:(CTVideoView *)videoView playControlDidMoveToSecond:(CGFloat)second direction:(CTVideoViewPlayControlDirection)direction
{
    if (direction == CTVideoViewPlayControlDirectionMoveForward) {
        self.simplePlayControlIndicator.text = [NSString stringWithFormat:@"current:%.2f total:%.2f >> ", second, videoView.totalDurationSeconds];
    }
    if (direction == CTVideoViewPlayControlDirectionMoveBackward) {
        self.simplePlayControlIndicator.text = [NSString stringWithFormat:@"current:%.2f total:%.2f << ", second, videoView.totalDurationSeconds];
    }
    [self.simplePlayControlIndicator sizeToFit];
}

#pragma mark - getters and setters
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.operationDelegate = self;
        _videoView.playControlDelegate = self;
        _videoView.backgroundColor = [UIColor whiteColor];
        _videoView.shouldReplayWhenFinish = YES;
    }
    return _videoView;
}

- (UILabel *)simplePlayControlIndicator
{
    if (_simplePlayControlIndicator == nil) {
        _simplePlayControlIndicator = [[UILabel alloc] init];
        _simplePlayControlIndicator.textColor = [UIColor blackColor];
        _simplePlayControlIndicator.backgroundColor = [UIColor whiteColor];
    }
    return _simplePlayControlIndicator;
}

@end
