//
//  CTVideoView+OperationButtons.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (OperationButtons)

- (void)initOperationButtons;
- (void)deallocOperationButtons;

/**
 *  set YES, will show play button, pause button, retry button at a properly time.
 *  set NO, will hide all button any time, even you have button views set.
 */
@property (nonatomic, assign) BOOL shouldShowOperationButton;

/**
 *  view of play button. if not set, will use default view instead. If animtion block is nil, will use default animation.
 */
@property (nonatomic, strong) UIView *playButtonView;
@property (nonatomic, copy) void (^showPlayButtonViewAnimation)(UIView *button);
@property (nonatomic, copy) void (^hidePlayButtonViewAnimation)(UIView *button);

/**
 * view of pause button. if not set, will use default view instead. If animtion block is nil, will use default animation.
 */
@property (nonatomic, strong) UIView *pauseButtonView;
@property (nonatomic, copy) void (^showPauseButtonViewAnimation)(UIView *button);
@property (nonatomic, copy) void (^hidePauseButtonViewAnimation)(UIView *button);

/**
 *  view of retry button. if not set, will use default view instead. If animtion block is nil, will use default animation.
 */
@property (nonatomic, strong) UIView *retryButtonView;
@property (nonatomic, copy) void (^showRetryButtonViewAnimation)(UIView *button);
@property (nonatomic, copy) void (^hideRetryButtonViewAnimation)(UIView *button);

/**
 *  hide operation buttons
 *
 *  @param animated  if YES, will hide operation button animted with the animation you set with block above. if the animation block is nil, will animated as default.
 */
- (void)hideOperationButtonAnimated:(BOOL)animated;

/**
 *  hide operation buttons
 *
 *  @param animated  if YES, will show operation button animted with the animation you set with block above. if the animation block is nil, will animated as default.
 */
- (void)showOperationButtonAnimated:(BOOL)animated;

@end
