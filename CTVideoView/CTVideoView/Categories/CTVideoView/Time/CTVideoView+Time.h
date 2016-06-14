//
//  CTVideoView+Time.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (Time)

@property (nonatomic, assign, readonly) CGFloat currentPlaySecond;
@property (nonatomic, assign, readonly) CGFloat totalDurationSeconds;
@property (nonatomic, assign, readonly) BOOL shouldObservePlayTime; // if you want - (void)videoView:didPlayToSecond: to be called, you should call - (void)setShouldObservePlayTime:withTimeGapToObserve: first.
@property (nonatomic, assign, readonly) CGFloat timeGapToObserve; // default is 100.0f for 1 second.

@property (nonatomic, assign) CGFloat currentPlaySpeed; // set 2.0 means speed of 2x, must be called after prepare finished.
@property (nonatomic, weak) id<CTVideoViewTimeDelegate> timeDelegate;

- (void)setShouldObservePlayTime:(BOOL)shouldObservePlayTime withTimeGapToObserve:(CGFloat)timeGapToObserve;
- (void)moveToSecond:(CGFloat)second shouldPlay:(BOOL)shouldPlay;

// methods for main object
- (void)initTime;
- (void)deallocTime;
- (void)willStartPlay;

// KVO callback
- (void)durationDidLoadedWithChange:(NSDictionary *)change;

@end
