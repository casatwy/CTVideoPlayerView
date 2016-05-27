//
//  CTVideoView+VideoCoverView.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (VideoCoverView)

- (void)initVideoCoverView;
- (void)deallocVideoCoverView;

@property (nonatomic, assign) BOOL shouldShowCoverViewBeforePlay;
@property (nonatomic, strong) UIView *coverView;

- (void)showCoverView;
- (void)hideCoverView;

- (void)layoutCoverView;

@end
