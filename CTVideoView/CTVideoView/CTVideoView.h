//
//  CTVideoView.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTVideoView : UIView

@property (nonatomic, assign) BOOL shouldChangeOrientationToFitVideo;
@property (nonatomic, assign) BOOL isMuted;

@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, copy) NSURL *customizedVideoCoverImageUrl;
@property (nonatomic, copy, readonly) NSURL *actualPlayingUrl;

@end
