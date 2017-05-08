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
    if (self.shouldShowCoverViewBeforePlay && self.coverView.superview == nil) {
        [self addSubview:self.coverView];
        [self layoutCoverView];
    }
}

- (void)hideCoverView
{
    if (self.coverView.superview) {
        [UIView animateWithDuration:0.2f animations:^{
            self.coverView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.coverView removeFromSuperview];
                self.coverView.alpha = 1.0f;
            }
        }];
    }
}

- (void)layoutCoverView
{
    CGAffineTransform transform = self.transform;
    if (transform.b == 1 && transform.c == -1) {
        self.coverView.frame = CGRectMake(0, 0, self.ct_height, self.ct_width);
    } else {
        [self.coverView fill];
    }
}

#pragma mark - getters and setters
- (BOOL)shouldShowCoverViewBeforePlay
{
    return [objc_getAssociatedObject(self, &CTVideoViewCoverPropertyShouldShowCoverViewBeforePlay) boolValue];
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
