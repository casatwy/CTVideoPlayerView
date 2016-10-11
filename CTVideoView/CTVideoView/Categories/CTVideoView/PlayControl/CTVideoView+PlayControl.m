//
//  CTVideoView+PlayControl.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+PlayControl.h"
#import <objc/runtime.h>

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
        case UIGestureRecognizerStateBegan:
            break;
            
        case UIGestureRecognizerStateChanged:
            break;
            
        case UIGestureRecognizerStateEnded:
            break;
            
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

@end
