//
//  CTVideoView+Time.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+Time.h"
#import <objc/runtime.h>

/* ----------------- Private methods ----------------- */

static void * CTVideoViewTimePrivatePropertyTimeObserverToken;

@interface CTVideoView (TimePrivate)

@property (nonatomic, strong) id<NSObject> timeObserverToken;

@end

@implementation CTVideoView (TimePrivate)

@dynamic timeObserverToken;

#pragma mark - private methods
- (void)addTimeObserver
{
    if (self.timeObserverToken) {
        [self removeTimeObserver];
    }
    WeakSelf;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        StrongSelf;
        if ([strongSelf.timeDelegate respondsToSelector:@selector(videoView:didPlayToSecond:)]) {
            [strongSelf.timeDelegate videoView:strongSelf didPlayToSecond:CMTimeGetSeconds(time)];
        }
    }];
}

- (void)removeTimeObserver
{
    if (self.timeObserverToken) {
        [self.player removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
    }
}

#pragma mark - getters and setters
- (id<NSObject>)timeObserverToken
{
    return objc_getAssociatedObject(self, &CTVideoViewTimePrivatePropertyTimeObserverToken);
}

- (void)setTimeObserverToken:(id<NSObject>)timeObserverToken
{
    objc_setAssociatedObject(self, &CTVideoViewTimePrivatePropertyTimeObserverToken, timeObserverToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

/* ----------------- Public methods ----------------- */

static void * CTVideoViewTimePropertyShouldObservePlayTime;
static void * CTVideoViewTimePropertyTotalDurationSeconds;
static void * CTVideoViewTimePropertyTimeDelegate;

@implementation CTVideoView (Time)

@dynamic shouldObservePlayTime;
@dynamic totalDurationSeconds;
@dynamic timeDelegate;

#pragma mark - public methods
- (void)moveToSecond:(CGFloat)second shouldPlay:(BOOL)shouldPlay
{
    CMTime time = CMTimeMake(second, 1.0f);
    WeakSelf;
    [self.player seekToTime:CMTimeMake(second, 1.0f) completionHandler:^(BOOL finished) {
        StrongSelf;
        if (finished) {
            if ([strongSelf.timeDelegate respondsToSelector:@selector(videoView:didFinishedMoveToTime:)]) {
                [strongSelf.timeDelegate videoView:strongSelf didFinishedMoveToTime:time];
            }
            if (shouldPlay) {
                [strongSelf play];
            }
        }
    }];
}

#pragma mark - method for main object
- (void)initTime
{
    // do nothing
}

- (void)deallocTime
{
    [self removeTimeObserver];
}

- (void)durationDidLoadedWithChange:(NSDictionary *)change
{
    NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
    CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
    BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
    self.totalDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
    if (self.totalDurationSeconds > 0) {
        if ([self.timeDelegate respondsToSelector:@selector(videoViewDidLoadVideoDuration:)]) {
            [self.timeDelegate videoViewDidLoadVideoDuration:self];
        }
    }
}

#pragma mark - getters and setters
- (CGFloat)totalDurationSeconds
{
    return [objc_getAssociatedObject(self, &CTVideoViewTimePropertyTotalDurationSeconds) floatValue];
}

- (void)setTotalDurationSeconds:(CGFloat)totalDurationSeconds
{
    objc_setAssociatedObject(self, &CTVideoViewTimePropertyTotalDurationSeconds, @(totalDurationSeconds), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)shouldObservePlayTime
{
    return [objc_getAssociatedObject(self, &CTVideoViewTimePropertyShouldObservePlayTime) boolValue];
}

- (void)setShouldObservePlayTime:(BOOL)shouldObservePlayTime
{
    objc_setAssociatedObject(self, &CTVideoViewTimePropertyShouldObservePlayTime, @(shouldObservePlayTime), OBJC_ASSOCIATION_ASSIGN);
    
    if (shouldObservePlayTime == YES) {
        [self addTimeObserver];
    }
    
    if (shouldObservePlayTime == NO) {
        [self removeTimeObserver];
    }
}

- (id<CTVideoViewTimeDelegate>)timeDelegate
{
    return objc_getAssociatedObject(self, &CTVideoViewTimePropertyTimeDelegate);
}

- (void)setTimeDelegate:(id<CTVideoViewTimeDelegate>)timeDelegate
{
    objc_setAssociatedObject(self, &CTVideoViewTimePropertyTimeDelegate, timeDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setCurrentPlaySpeed:(CGFloat)currentPlaySpeed
{
    self.player.rate = 1.0 * currentPlaySpeed;
}

- (CGFloat)currentPlaySpeed
{
    return self.player.rate / 1.0f;
}

@end
