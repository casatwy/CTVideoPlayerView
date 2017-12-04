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
static void * CTVideoViewFullScreenPropertyOriginSuperView;
static void * CTVideoViewFullScreenPropertyFullScreenDelegate;

@interface CTVideoView (FillScreen_Private)

@property (nonatomic, weak) UIView *originSuperView;

@end

@implementation CTVideoView (FullScreen)

#pragma mark - public methods
- (void)enterFullScreen
{
    self.isFullScreen = YES;
    
    CGFloat videoWidth = [[[self.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].width;
    CGFloat videoHeight = [[[self.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].height;
    
    CATransform3D transform = CATransform3DMakeRotation(0.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
    CGRect scaleFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    if ([self.asset CTVideoView_isVideoPortraint]) {
        if (videoWidth < videoHeight) {
            if (self.transform.b != 1 || self.transform.c != -1) {
                transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
                scaleFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
            }
        }
    } else {
        if (videoWidth > videoHeight) {
            if (self.transform.b != 1 || self.transform.c != -1) {
                transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
                scaleFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
            }
        }
    }
    [self animateToFullScreenWithTransform:transform scaleFrame:scaleFrame];
}

- (void)exitFullScreen
{
    self.isFullScreen = NO;
    [self animateExitFullScreen];
}

#pragma mark - private methods
- (void)animateToFullScreenWithTransform:(CATransform3D)transform scaleFrame:(CGRect)scaleFrame
{
    NSValue *originFrameValue = [NSValue valueWithCGRect:self.frame];
    objc_setAssociatedObject(self, &CTVideoViewFullScreenPropertyOriginVideoViewFrame, originFrameValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGRect convertToWindowFrame = [self.superview convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow];
    
    self.originSuperView = self.superview;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.frame = convertToWindowFrame;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3f animations:^{
        weakSelf.frame = scaleFrame;
        weakSelf.center = [UIApplication sharedApplication].keyWindow.center;
        
        if ([weakSelf.fullScreenDelegate respondsToSelector:@selector(videoViewLayoutSubviewsWhenEnterFullScreen:)]) {
            [weakSelf.fullScreenDelegate videoViewLayoutSubviewsWhenEnterFullScreen:weakSelf];
        }
        weakSelf.layer.transform = transform;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([weakSelf.fullScreenDelegate respondsToSelector:@selector(videoVidewDidFinishEnterFullScreen:)]) {
                [weakSelf.fullScreenDelegate videoVidewDidFinishEnterFullScreen:weakSelf];
            }
        }
    }];
}

- (void)animateExitFullScreen
{
    [self.originSuperView addSubview:self];
    self.originSuperView = nil;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3f animations:^{
        weakSelf.playerLayer.transform = CATransform3DMakeRotation(0.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
        weakSelf.frame = [self originVideoViewFrame];
        if ([weakSelf.fullScreenDelegate respondsToSelector:@selector(videoViewLayoutSubviewsWhenExitFullScreen:)]) {
            [weakSelf.fullScreenDelegate videoViewLayoutSubviewsWhenExitFullScreen:weakSelf];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            if ([weakSelf.fullScreenDelegate respondsToSelector:@selector(videoVidewDidFinishExitFullScreen:)]) {
                [weakSelf.fullScreenDelegate videoVidewDidFinishExitFullScreen:weakSelf];
            }
        }
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

- (void)setOriginSuperView:(UIView *)originSuperView
{
    objc_setAssociatedObject(self, &CTVideoViewFullScreenPropertyOriginSuperView, originSuperView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)originSuperView
{
    return objc_getAssociatedObject(self, &CTVideoViewFullScreenPropertyOriginSuperView);
}

- (void)setFullScreenDelegate:(id<CTVideoViewFullScreenDelegate>)fullScreenDelegate
{
    objc_setAssociatedObject(self, &CTVideoViewFullScreenPropertyFullScreenDelegate, fullScreenDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (NSObject<CTVideoViewFullScreenDelegate> *)fullScreenDelegate
{
    return objc_getAssociatedObject(self, &CTVideoViewFullScreenPropertyFullScreenDelegate);
}

@end
