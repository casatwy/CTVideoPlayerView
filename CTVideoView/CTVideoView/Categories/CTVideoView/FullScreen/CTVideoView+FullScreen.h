//
//  CTVideoView+FullScreen.h
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@protocol CTVideoViewFullScreenDelegate;

@interface CTVideoView (FullScreen)

@property (nonatomic, assign, readonly) BOOL isFullScreen;
@property (nonatomic, weak) NSObject<CTVideoViewFullScreenDelegate> *fullScreenDelegate;

- (void)enterFullScreen;
- (void)exitFullScreen;

@end

@protocol CTVideoViewFullScreenDelegate

@optional
- (void)videoViewLayoutSubviewsWhenEnterFullScreen:(CTVideoView *)videoView;
- (void)videoVidewDidFinishEnterFullScreen:(CTVideoView *)videoView;

- (void)videoViewLayoutSubviewsWhenExitFullScreen:(CTVideoView *)videoView;
- (void)videoVidewDidFinishExitFullScreen:(CTVideoView *)videoView;

@end
