//
//  CTVideoView+PlayControl.h
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CTVideoView (PlayControl)

@property (nonatomic, assign) BOOL isSlideFastForwardDisabled;
@property (nonatomic, assign) CGFloat speedOfSecondToMove;

@property (nonatomic, assign) BOOL isSlideToChangeVolumeDisabled;
@property (nonatomic, assign) CGFloat speedOfVolumeChange;

@property (nonatomic, strong, readonly) MPVolumeView *volumeView;

@property (nonatomic, weak) id<CTVideoViewPlayControlDelegate> playControlDelegate;

@end
