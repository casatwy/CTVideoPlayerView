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
#import <MediaPlayer/MediaPlayer.h>

static void * CTVideoViewPlayControlPropertyPlayControlGestureRecognizer;
static void * CTVideoViewPlayControlPropertySecondToMove;
static void * CTVideoViewPlayControlPropertyVolumeSlider;

@implementation CTVideoView (PlayControlPrivate)

#pragma mark - methds
- (void)initPlayControlGestures
{
    [self addGestureRecognizer:self.playControlGestureRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - event response
- (void)didRecognizedPlayControlRecognizer:(UIPanGestureRecognizer *)playControlGestureRecognizer
{
    if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionHorizontal && self.isSlideFastForwardDisabled) {
        playControlGestureRecognizer.slideDirection = CTUIPanGestureSlideDirectionNotDefined;
        return;
    }
    
    if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionVertical && self.isSlideToChangeVolumeDisabled) {
        playControlGestureRecognizer.slideDirection = CTUIPanGestureSlideDirectionNotDefined;
        return;
    }
    
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
                [self.playControlDelegate videoViewShowPlayControlIndicator:self];
            }

            if (absoluteX < absoluteY) {
                // vertical
                playControlGestureRecognizer.slideDirection = CTUIPanGestureSlideDirectionVertical;
                [self.playControlDelegate videoViewHidePlayControlIndicator:self];
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
                [self.playControlDelegate videoViewHidePlayControlIndicator:self];
            }
            if (playControlGestureRecognizer.slideDirection == CTUIPanGestureSlideDirectionVertical) {
                // do nothing
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
    self.volumeSlider.value -= velocityY / self.speedOfVolumeChange;
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
    
        //
        objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyPlayControlGestureRecognizer, gestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (UISlider *)volumeSlider
{
    UISlider *volumeSlider = objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyVolumeSlider);
    if (volumeSlider == nil) {
        for (UIView *view in [self.volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeSlider = (UISlider *)view;
                objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyVolumeSlider, volumeSlider, OBJC_ASSOCIATION_ASSIGN);
                break;
            }
        }
    }
    return volumeSlider;
}

@end
