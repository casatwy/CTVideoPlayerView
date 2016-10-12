//
//  CTVideoView+PlayControlPrivate.m
//  CTVideoView
//
//  Created by casa on 2016/10/12.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+PlayControlPrivate.h"
#import "CTVideoView+PlayControl.h"
#import "CTVideoView+Time.h"
#import "UIPanGestureRecognizer+ExtraMethods.h"
#import <objc/runtime.h>

static void * CTVideoViewPlayControlPropertyPlayControlGestureRecognizer;
static void * CTVideoViewPlayControlPropertySecondToMove;

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
                self.secondToMove = self.currentPlaySecond;
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
                [self moveToSecondWithVelocityX:velocityPoint.x];
            }
            if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionVertical) {
                [self changeVolumeWithVelocityY:velocityPoint.y];
            }
            break;
        }

        case UIGestureRecognizerStateEnded:{
            if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionHorizontal) {
                [self.player play];
                [self.playControlDelegate videoViewHidePlayControlIndicator:self playControlType:CTVideoViewPlayControlTypePlay];
            }
            if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionVertical) {
                [self.playControlDelegate videoViewHidePlayControlIndicator:self playControlType:CTVideoViewPlayControlTypeVolume];
            }
            break;
        }

        default:
            break;
    }
}

#pragma mark - private methods
- (void)moveToSecondWithVelocityX:(CGFloat)velocityX
{
    CTVideoViewPlayControlDirection direction = CTVideoViewPlayControlDirectionMoveForward;
    if (velocityX < 0) {
        direction = CTVideoViewPlayControlDirectionMoveBackward;
    }

    self.secondToMove += velocityX / self.speedOfSecondToMove;
    if (self.secondToMove > self.totalDurationSeconds) {
        self.secondToMove = self.totalDurationSeconds;
    }
    if (self.secondToMove < 0) {
        self.secondToMove = 0;
    }
    [self moveToSecond:self.secondToMove shouldPlay:NO];
    if ([self.playControlDelegate respondsToSelector:@selector(videoView:playControlDidMoveToSecond:direction:)]) {
        [self.playControlDelegate videoView:self playControlDidMoveToSecond:self.secondToMove direction:direction];
    }
}

- (void)changeVolumeWithVelocityY:(CGFloat)velocityY
{

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

- (CGFloat)secondToMove
{
    return [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertySecondToMove) floatValue];
}

- (void)setSecondToMove:(CGFloat)secondToMove
{
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertySecondToMove, @(secondToMove), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
