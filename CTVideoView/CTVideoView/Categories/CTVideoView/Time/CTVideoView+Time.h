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
@property (nonatomic, assign, readonly) CGFloat currentPlaySpeed;

/**
 *  if you want - (void)videoView:didPlayToSecond: to be called, you should set shouldObservePlayTime to YES.
 */
@property (nonatomic, assign) BOOL shouldObservePlayTime;

- (void)moveToSecond:(CGFloat)second shouldPlay:(BOOL)shouldPlay;
- (void)setSpeed:(CGFloat)speed shouldPlay:(BOOL)shouldPlay;

@end
