//
//  CTVideoView+Time.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+Time.h"
#import "CTVideoView+OperationButtons.h"
#import "CTVideoView+VideoCoverView.h"
#import <objc/runtime.h>

/* ----------------- Private methods ----------------- */

static void * CTVideoViewTimePrivatePropertyTimeObserverToken;
static void * CTVideoViewTimePrivatePropertyVideoStartTimeObserverToken;

@interface CTVideoView (TimePrivate)

@property (nonatomic, strong) id<NSObject> timeObserverToken;
@property (nonatomic, strong) id<NSObject> videoStartTimeObserverToken;

@end

@implementation CTVideoView (TimePrivate)

@dynamic timeObserverToken;
@dynamic videoStartTimeObserverToken;

#pragma mark - private methods
- (void)addTimeObserver
{
    if (self.timeObserverToken) {
        [self removeTimeObserver];
    }
    WeakSelf;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(self.timeGapToObserve, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        StrongSelf;
        if ([strongSelf.timeDelegate respondsToSelector:@selector(videoView:didPlayToSecond:)]) {
            [strongSelf.timeDelegate videoView:strongSelf didPlayToSecond:CMTimeGetSeconds(time)];
        }
    }];
}

- (void)addVideoStartTimeObserver
{
    if (self.videoStartTimeObserverToken) {
        [self removeVideoStartTimeObserver];
    }
    WeakSelf;
    self.videoStartTimeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        StrongSelf;
        CGFloat seconds = CMTimeGetSeconds(time);
        if (strongSelf.isPlaying && seconds > 0 && seconds < 0.1) {
            if ([strongSelf.operationDelegate respondsToSelector:@selector(videoViewDidStartPlaying:)]) {
                [strongSelf.operationDelegate videoViewDidStartPlaying:strongSelf];
            }
            [strongSelf hidePlayButton];
            [strongSelf hideCoverView];
            [strongSelf removeVideoStartTimeObserver];
        }
        if (seconds > 0.1) {
            [strongSelf removeVideoStartTimeObserver];
        }
    }];
}

- (void)removeVideoStartTimeObserver
{
    if (self.videoStartTimeObserverToken) {
        [self.player removeTimeObserver:self.videoStartTimeObserverToken];
        self.videoStartTimeObserverToken = nil;
    }
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

- (id<NSObject>)videoStartTimeObserverToken
{
    return objc_getAssociatedObject(self, &CTVideoViewTimePrivatePropertyVideoStartTimeObserverToken);
}

- (void)setVideoStartTimeObserverToken:(id<NSObject>)videoStartTimeObserverToken
{
    objc_setAssociatedObject(self, &CTVideoViewTimePrivatePropertyVideoStartTimeObserverToken, videoStartTimeObserverToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

/* ----------------- Public methods ----------------- */

static void * CTVideoViewTimePropertyShouldObservePlayTime;
static void * CTVideoViewTimePropertyTotalDurationSeconds;
static void * CTVideoViewTimePropertyTimeDelegate;
static void * CTVideoViewTimePropertyTimeGapToObserve;

@implementation CTVideoView (Time)

@dynamic shouldObservePlayTime;
@dynamic totalDurationSeconds;
@dynamic timeDelegate;

#pragma mark - public methods
- (void)moveToSecond:(CGFloat)second shouldPlay:(BOOL)shouldPlay
{
    CMTime time = CMTimeMake(second, 1.0f);
    WeakSelf;
    [self.player seekToTime:CMTimeMakeWithSeconds(second, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
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

- (void)setShouldObservePlayTime:(BOOL)shouldObservePlayTime withTimeGapToObserve:(CGFloat)timeGapToObserve
{
    self.timeGapToObserve = timeGapToObserve;
    self.shouldObservePlayTime = shouldObservePlayTime;
}

#pragma mark - method for main object
- (void)initTime
{
    [self addVideoStartTimeObserver];
}

- (void)deallocTime
{
    [self removeTimeObserver];
    [self removeVideoStartTimeObserver];
    self.timeDelegate = nil;
}

- (void)willStartPlay
{
    [self addVideoStartTimeObserver];
}

- (void)durationDidLoadedWithChange:(NSDictionary *)change
{
    if ([change[@"new"] isEqual:[NSNull null]]) {
        [self addVideoStartTimeObserver];
    }
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
- (CGFloat)currentPlaySecond
{
    return CMTimeGetSeconds(self.playerItem.currentTime);
}

- (CGFloat)timeGapToObserve
{
    CGFloat timeGapToObserve = [objc_getAssociatedObject(self, &CTVideoViewTimePropertyTimeGapToObserve) floatValue];
    if (timeGapToObserve == 0) {
        timeGapToObserve = 100.0f;
        [self setTimeGapToObserve:timeGapToObserve];
    }
    return timeGapToObserve;
}

- (void)setTimeGapToObserve:(CGFloat)timeGapToObserve
{
    objc_setAssociatedObject(self, &CTVideoViewTimePropertyTimeGapToObserve, @(timeGapToObserve), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)totalDurationSeconds
{
    return [objc_getAssociatedObject(self, &CTVideoViewTimePropertyTotalDurationSeconds) floatValue];
}

- (void)setTotalDurationSeconds:(CGFloat)totalDurationSeconds
{
    objc_setAssociatedObject(self, &CTVideoViewTimePropertyTotalDurationSeconds, @(totalDurationSeconds), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldObservePlayTime
{
    return [objc_getAssociatedObject(self, &CTVideoViewTimePropertyShouldObservePlayTime) boolValue];
}

- (void)setShouldObservePlayTime:(BOOL)shouldObservePlayTime
{
    objc_setAssociatedObject(self, &CTVideoViewTimePropertyShouldObservePlayTime, @(shouldObservePlayTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

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
