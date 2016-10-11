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

static void * CTVideoViewPlayControlPropertyPlayControlGestureRecognizer;

@implementation CTVideoView (PlayControlPrivate)

#pragma mark - methds
- (void)initPlayControlGestures
{
    [self addGestureRecognizer:self.playControlGestureRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL result = YES;
    if (self.isSlideToChangeVolumeDisabled && self.isSlideFastForwardDisabled) {
        result = NO;
    }
    return result;
}

#pragma mark - event response
- (void)didRecognizedPlayControlRecognizer:(UIPanGestureRecognizer *)playControlGestureRecognizer
{
    CGPoint velocityPoint = [playControlGestureRecognizer velocityInView:self];
    
    switch (playControlGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            CGFloat absoluteX = fabs(velocityPoint.x);
            CGFloat absoluteY = fabs(velocityPoint.y);

            if (absoluteX > absoluteY) {
                // horizontal
                playControlGestureRecognizer.slideDirection = CTUIPanGestureSlideDirectionHorizontal;
                [self.player pause]; // 这里用[self pause]会使得play button展示出来
                [self.playControlDelegate videoViewShowPlayControlIndicator:self playControlType:CTVideoViewPlayControlTypePlay];
                [self.playControlDelegate videoViewHidePlayControlIndicator:self playControlType:CTVideoViewPlayControlTypeVolume];
            }

            if (absoluteX < absoluteY) {
                // vertical
                playControlGestureRecognizer.slideDirection = CTUIPanGestureSlideDirectionVertical;
                [self.playControlDelegate videoViewShowPlayControlIndicator:self playControlType:CTVideoViewPlayControlTypeVolume];
                [self.playControlDelegate videoViewHidePlayControlIndicator:self playControlType:CTVideoViewPlayControlTypePlay];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionHorizontal) {
            }
            if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionVertical) {
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - getters and setters
- (UIPanGestureRecognizer *)playControlGestureRecognizer
{
    UIPanGestureRecognizer *gestureRecognizer = objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyPlayControlGestureRecognizer);
    if (gestureRecognizer == nil) {
        gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedPlayControlRecognizer:)];
        gestureRecognizer.maximumNumberOfTouches = 1;
        gestureRecognizer.minimumNumberOfTouches = 1;
        gestureRecognizer.delegate = self;
    }
    return gestureRecognizer;
}

@end

/* ----------------- Public methods ----------------- */

static void * CTVideoViewPlayControlPropertyIsSlideFastForwardDisabled;
static void * CTVideoViewPlayControlPropertyIsSlideToChangeVolumeDisabled;
static void * CTVideoViewPlayControlPropertyDelegate;

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

@end
