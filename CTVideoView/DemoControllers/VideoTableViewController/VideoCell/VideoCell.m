//
//  VideoCell.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "VideoCell.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface VideoCell ()

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

    self.videoView.size = CGSizeMake(self.contentView.width-10, self.contentView.height-5);
    [self.videoView centerXEqualToView:self.contentView];
    [self.videoView topInContainer:5 shouldResize:NO];
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
        _videoView.shouldShowCoverViewBeforePlay = NO;
        _videoView.stalledStrategy = CTVideoViewStalledStrategyPlay;
    }
    return _videoView;
}

@end
