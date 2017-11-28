//
//  CTVideoView+PlayControl.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+PlayControl.h"
#import "CTVideoView+PlayControlPrivate.h"
#import <objc/runtime.h>

static void * CTVideoViewPlayControlPropertyDelegate;
static void * CTVideoViewPlayControlPropertySpeedOfSecondToMove;
static void * CTVideoViewPlayControlPropertySpeedOfVolumeChange;
static void * CTVideoViewPlayControlPropertyIsSlideFastForwardDisabled;
static void * CTVideoViewPlayControlPropertyIsSlideToChangeVolumeDisabled;
static void * CTVideoViewPlayControlPropertyVolumeView;

@implementation CTVideoView (PlayControl)

#pragma mark - getters and setters
- (BOOL)isSlideFastForwardDisabled
{
    return [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyIsSlideFastForwardDisabled) boolValue];
}

- (void)setIsSlideFastForwardDisabled:(BOOL)isSlideFastForwardDisabled
{
    if (isSlideFastForwardDisabled == YES && self.isSlideToChangeVolumeDisabled == YES) {
        [self removeGestureRecognizer:self.playControlGestureRecognizer];
    }
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyIsSlideFastForwardDisabled, @(isSlideFastForwardDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSlideToChangeVolumeDisabled
{
    return [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyIsSlideToChangeVolumeDisabled) boolValue];
}

- (void)setIsSlideToChangeVolumeDisabled:(BOOL)isSlideToChangeVolumeDisabled
{
    if (isSlideToChangeVolumeDisabled == YES && self.isSlideFastForwardDisabled == YES) {
        [self removeGestureRecognizer:self.playControlGestureRecognizer];
    }
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyIsSlideToChangeVolumeDisabled, @(isSlideToChangeVolumeDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<CTVideoViewPlayControlDelegate>)playControlDelegate
{
    id<CTVideoViewPlayControlDelegate> delegate = objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyDelegate);
    if ([delegate respondsToSelector:@selector(description)] == NO) {
        delegate = nil;
    }
    return delegate;
}

- (void)setPlayControlDelegate:(id<CTVideoViewPlayControlDelegate>)playControlDelegate
{
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyDelegate, playControlDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)speedOfSecondToMove
{
    CGFloat speedOfSecondToMove = [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertySpeedOfSecondToMove) floatValue];
    if (speedOfSecondToMove == 0) {
        speedOfSecondToMove = 300;
    }
    return speedOfSecondToMove;
}

- (void)setSpeedOfSecondToMove:(CGFloat)speedOfSecondToMove
{
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertySpeedOfSecondToMove, @(speedOfSecondToMove), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)speedOfVolumeChange
{
    CGFloat speedOfVolumeChange = [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertySpeedOfVolumeChange) floatValue];
    if (speedOfVolumeChange == 0) {
        speedOfVolumeChange = 10000.0f;
    }
    return speedOfVolumeChange;
}

- (void)setSpeedOfVolumeChange:(CGFloat)speedOfVolumeChange
{
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertySpeedOfVolumeChange, @(speedOfVolumeChange), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MPVolumeView *)volumeView
{
    MPVolumeView *volumeView = objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyVolumeView);
    if (volumeView == nil) {
        volumeView = [[MPVolumeView alloc] init];
        objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyVolumeView, volumeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return volumeView;
}

@end
