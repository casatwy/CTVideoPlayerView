//
//  CTVideoView+PlayControlPrivate.h
//  CTVideoView
//
//  Created by casa on 2016/10/12.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (PlayControlPrivate) <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat secondToMove;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *playControlGestureRecognizer;
@property (nonatomic, strong, readonly) UISlider *volumeSlider;

- (void)initPlayControlGestures;

@end
