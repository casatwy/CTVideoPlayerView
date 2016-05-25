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

@property (nonatomic, strong) NSURL *customizedVideoCoverImageUrl; // if nil, will show the first frame of video. if set, will show the image of this url as a cover before playing video. Default is nil.
- (void)loadCoverImage;

@property (nonatomic, strong) UIView *coverView;
- (void)showCoverView;
- (void)hideCoverView;

@end
