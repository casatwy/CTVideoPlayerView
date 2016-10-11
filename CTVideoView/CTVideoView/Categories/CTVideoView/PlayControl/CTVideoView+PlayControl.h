//
//  CTVideoView+PlayControl.h
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

// public category, you should only use things in this category
@interface CTVideoView (PlayControl)

@property (nonatomic, assign) BOOL isSlideFastForwardDisabled;
@property (nonatomic, assign) BOOL isSlideToChangeVolumeDisabled;

@property (nonatomic, weak) id<CTVideoViewPlayControlDelegate> playControlDelegate;

@end

// private category, used only by CTVideoView, you should never call these methods by your self
@interface CTVideoView (PlayControlPrivate) <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *playControlGestureRecognizer;
- (void)initPlayControlGestures;

@end
