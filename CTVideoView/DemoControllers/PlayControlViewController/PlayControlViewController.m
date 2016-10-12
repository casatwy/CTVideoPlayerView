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

#pragma mark - CTVideoViewPlayControlDelegate
- (void)videoViewShowPlayControlIndicator:(CTVideoView *)videoView
{
    NSLog(@"show play");
}

- (void)videoViewHidePlayControlIndicator:(CTVideoView *)videoView
{
    NSLog(@"hide play");
}

- (void)videoView:(CTVideoView *)videoView playControlDidChangeToVolume:(CGFloat)volume
{
    NSLog(@"volume did change to %f", volume);
}

- (void)videoView:(CTVideoView *)videoView playControlDidMoveToSecond:(CGFloat)second direction:(CTVideoViewPlayControlDirection)direction
{
    NSLog(@"movie did move to %f, %lu", second, (unsigned long)direction);
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

@end
