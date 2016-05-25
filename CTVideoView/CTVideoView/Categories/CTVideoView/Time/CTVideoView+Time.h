//
//  CTVideoView+Time.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (Time)

@property (nonatomic, assign, readonly) CGFloat totalDurationSeconds;

/**
 *  if you want - (void)videoView:didPlayToSecond: to be called, you should set shouldObservePlayTime to YES.
 */
@property (nonatomic, assign) BOOL shouldObservePlayTime;
@property (nonatomic, weak) id<CTVideoViewTimeDelegate> timeDelegate;
@property (nonatomic, assign) CGFloat currentPlaySpeed; // set 2.0 means speed of 2x

- (void)moveToSecond:(CGFloat)second shouldPlay:(BOOL)shouldPlay;

// methods for main object
- (void)initTime;
- (void)deallocTime;
- (void)durationDidLoadedWithChange:(NSDictionary *)change;

@end
