//
//  CTVideoView+PlayControl.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+PlayControl.h"
#import <objc/runtime.h>
#import "UIPanGestureRecognizer+ExtraMethods.h"

static void * CTVideoViewPlayControlPropertyDelegate;
static void * CTVideoViewPlayControlPropertySpeedOfSecondToMove;
static void * CTVideoViewPlayControlPropertyIsSlideFastForwardDisabled;
static void * CTVideoViewPlayControlPropertyIsSlideToChangeVolumeDisabled;

@implementation CTVideoView (PlayControl)

#pragma mark - getters and setters
- (BOOL)isSlideFastForwardDisabled
{
    return [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyIsSlideFastForwardDisabled) boolValue];
}

- (void)setIsSlideFastForwardDisabled:(BOOL)isSlideFastForwardDisabled
{
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyIsSlideFastForwardDisabled, @(isSlideFastForwardDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSlideToChangeVolumeDisabled
{
    return [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyIsSlideToChangeVolumeDisabled) boolValue];
}

- (void)setIsSlideToChangeVolumeDisabled:(BOOL)isSlideToChangeVolumeDisabled
{
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

@end
