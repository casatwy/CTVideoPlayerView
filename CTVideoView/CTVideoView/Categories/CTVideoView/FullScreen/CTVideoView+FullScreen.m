//
//  CTVideoView+FullScreen.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+FullScreen.h"
#import "AVAsset+CTVideoView.h"
#import <objc/runtime.h>

static void * CTVideoViewFullScreenPropertyIsFullScreen;
static void * CTVideoViewFullScreenPropertyOriginVideoViewFrame;

@implementation CTVideoView (FullScreen)

#pragma mark - public methods
- (void)enterFullScreen
{
    self.isFullScreen = YES;
    
    CGFloat videoWidth = [[[self.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].width;
    CGFloat videoHeight = [[[self.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].height;
    
    CATransform3D transform = CATransform3DMakeRotation(0.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
    if ([self.asset CTVideoView_isVideoPortraint]) {
        if (videoWidth < videoHeight) {
            if (self.transform.b != 1 || self.transform.c != -1) {
                transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
            }
        }
    } else {
        if (videoWidth > videoHeight) {
            if (self.transform.b != 1 || self.transform.c != -1) {
                transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
            }
        }
    }
    [self animateToFullScreenWithTransform:transform];
}

- (void)exitFullScreen
{
    self.isFullScreen = NO;
    [self animateExitFullScreen];
}

#pragma mark - private methods
- (void)animateToFullScreenWithTransform:(CATransform3D)transform
{
    NSValue *originFrameValue = [NSValue valueWithCGRect:self.frame];
    objc_setAssociatedObject(self, &CTVideoViewFullScreenPropertyOriginVideoViewFrame, originFrameValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [UIView animateWithDuration:0.3f animations:^{
        self.playerLayer.transform = transform;
        self.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
    }];
}

- (void)animateExitFullScreen
{
    [UIView animateWithDuration:0.3f animations:^{
        self.playerLayer.transform = CATransform3DMakeRotation(0.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
        self.frame = [self originVideoViewFrame];
    }];
}

#pragma mark - getters and setters
- (BOOL)isFullScreen
{
    return [objc_getAssociatedObject(self, &CTVideoViewFullScreenPropertyIsFullScreen) boolValue];
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    objc_setAssociatedObject(self, &CTVideoViewFullScreenPropertyIsFullScreen, @(isFullScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)originVideoViewFrame
{
    CGRect frame = [objc_getAssociatedObject(self, &CTVideoViewFullScreenPropertyOriginVideoViewFrame) CGRectValue];
    return frame;
}

@end
