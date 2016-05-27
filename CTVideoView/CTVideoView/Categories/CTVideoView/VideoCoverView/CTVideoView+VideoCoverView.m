//
//  CTVideoView+VideoCoverView.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+VideoCoverView.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import <objc/runtime.h>

static void * CTVideoViewCoverPropertyShouldShowCoverViewBeforePlay;
static void * CTVideoViewCoverPropertyCoverView;

@implementation CTVideoView (VideoCoverView)

#pragma mark - life cycle
- (void)initVideoCoverView
{
    [self showCoverView];
}

- (void)deallocVideoCoverView
{
    // do nothing
}

#pragma mark - public methods
- (void)showCoverView
{
    if (self.shouldShowCoverViewBeforePlay) {
        [self addSubview:self.coverView];
        [self layoutCoverView];
    }
}

- (void)hideCoverView
{
    [self.coverView removeFromSuperview];
}

- (void)layoutCoverView
{
    [self.coverView fill];
}

#pragma mark - getters and setters
- (BOOL)shouldShowCoverViewBeforePlay
{
    NSNumber *shouldShowCoverViewBeforePlay = objc_getAssociatedObject(self, &CTVideoViewCoverPropertyShouldShowCoverViewBeforePlay);
    if ([shouldShowCoverViewBeforePlay isKindOfClass:[NSNumber class]]) {
        return [shouldShowCoverViewBeforePlay boolValue];
    }
    return NO;
}

- (void)setShouldShowCoverViewBeforePlay:(BOOL)shouldShowCoverViewBeforePlay
{
    objc_setAssociatedObject(self, &CTVideoViewCoverPropertyShouldShowCoverViewBeforePlay, @(shouldShowCoverViewBeforePlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (shouldShowCoverViewBeforePlay == YES) {
        if (self.coverView.superview == nil) {
            [self showCoverView];
        }
    }
}

- (UIView *)coverView
{
    return objc_getAssociatedObject(self, &CTVideoViewCoverPropertyCoverView);
}

- (void)setCoverView:(UIView *)coverView
{
    objc_setAssociatedObject(self, &CTVideoViewCoverPropertyCoverView, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.shouldShowCoverViewBeforePlay == YES) {
        [self showCoverView];
    }
}

@end
