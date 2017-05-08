//
//  VideoCell.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "VideoCell.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface VideoCell () <CTVideoViewOperationDelegate>

@property (nonatomic, strong) CTVideoView *videoView;

@end

@implementation VideoCell

#pragma mark - life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.videoView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.videoView.ct_size = CGSizeMake(self.contentView.ct_width - 10, self.contentView.ct_height - 5);
    [self.videoView centerXEqualToView:self.contentView];
    [self.videoView topInContainer:5 shouldResize:NO];
}

#pragma mark - CTVideoViewOperationDelegate
- (void)videoViewDidFinishPrepare:(CTVideoView *)videoView
{
    [videoView play];
}

- (void)videoViewDidStartPlaying:(CTVideoView *)videoView
{
    if ([self.delegate respondsToSelector:@selector(scrollToInvisibleCell)]) {
        [self.delegate scrollToInvisibleCell];
    }
}

#pragma mark - getters and setters
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.shouldReplayWhenFinish = YES;
        _videoView.isMuted = YES;
        _videoView.shouldPlayAfterPrepareFinished = NO;
        _videoView.videoContentMode = CTVideoViewContentModeResizeAspectFill;
        _videoView.shouldShowOperationButton = NO;
        _videoView.stalledStrategy = CTVideoViewStalledStrategyPlay;
        _videoView.operationDelegate = self;
        _videoView.isSlideFastForwardDisabled = YES;
        _videoView.isSlideToChangeVolumeDisabled = YES;

        UILabel *coverView = [[UILabel alloc] init];
        coverView.text = @"VIDEO";
        coverView.textAlignment = NSTextAlignmentCenter;
        coverView.backgroundColor = [UIColor redColor];
        _videoView.coverView = coverView;
        _videoView.shouldShowCoverViewBeforePlay = YES;
    }
    return _videoView;
}

@end
