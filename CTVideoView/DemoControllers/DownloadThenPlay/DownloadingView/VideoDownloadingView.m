//
//  VideoDownloadingView.m
//  CTVideoView
//
//  Created by casa on 16/6/22.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "VideoDownloadingView.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface VideoDownloadingView () <CTVideoPlayerDownloadingViewProtocol>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation VideoDownloadingView

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.activityIndicatorView];
        [self addSubview:self.progressLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.activityIndicatorView.ct_size = CGSizeMake(40, 40);
    [self.activityIndicatorView centerEqualToView:self];
    
    [self.progressLabel sizeToFit];
    [self.progressLabel top:3 FromView:self.activityIndicatorView];
    [self.progressLabel centerXEqualToView:self];
    [self.progressLabel fillWidth];
}

#pragma mark - CTVideoPlayerDownloadingViewProtocol
- (void)videoViewStartDownload:(CTVideoView *)videoView
{
    self.alpha = 1.0f;
    self.progressLabel.text = @"0%";
    [self.activityIndicatorView startAnimating];
}

- (void)videoViewFinishDownload:(CTVideoView *)videoView
{
    [self.activityIndicatorView stopAnimating];
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)videoViewFailedDownload:(CTVideoView *)videoView
{
    [self.activityIndicatorView stopAnimating];
    self.progressLabel.text = @"failed";
}

- (void)videoViewPauseDownload:(CTVideoView *)videoView
{
    [self.activityIndicatorView stopAnimating];
    self.progressLabel.text = @"paused";
}

- (void)videoView:(CTVideoView *)videoView progress:(CGFloat)progress
{
    NSInteger intProgress = (NSInteger)(progress * 100);
    self.progressLabel.text = [NSString stringWithFormat:@"%ld%%", (long)intProgress];
}

#pragma mark - getters and setters
- (UIActivityIndicatorView *)activityIndicatorView
{
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}

- (UILabel *)progressLabel
{
    if (_progressLabel == nil) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor = [UIColor blackColor];
        _progressLabel.text = @"0%";
        _progressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _progressLabel;
}

@end
