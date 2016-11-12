//
//  CTVideoView.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

@import AVFoundation;
@import CoreMedia;

#import <UIKit/UIKit.h>
#import "CTVideoViewDefinitions.h"

@interface CTVideoView : UIView

@property (nonatomic, strong) AVAsset *assetToPlay; // if this is not nil, video view will play this asset instead of playing the `videoUrl`

/**
 *  for performance concern, set videoUrl will not call `-(void)prepare`, you should call `-(void)prepare` at a good time, say `- (void)tableView:willDisplayCell:forRowAtIndexPath:` or `-(void)viewDidAppear:`.
 */
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, assign, readonly) CTVideoViewVideoUrlType videoUrlType;

@property (nonatomic, strong, readonly) NSURL *actualVideoPlayingUrl;
@property (nonatomic, assign, readonly) CTVideoViewVideoUrlType actualVideoUrlType;

@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign, readonly) CTVideoViewPrepareStatus prepareStatus;

@property (nonatomic, assign) BOOL isMuted; // set YES to mute the video playing
@property (nonatomic, assign) BOOL shouldPlayAfterPrepareFinished; // default is YES
@property (nonatomic, assign) BOOL shouldReplayWhenFinish; // default is YES
@property (nonatomic, assign) BOOL shouldChangeOrientationToFitVideo; // default is NO

@property (nonatomic, assign) CTVideoViewStalledStrategy stalledStrategy;
@property (nonatomic, assign) CTVideoViewContentMode videoContentMode;

@property (nonatomic, weak) id<CTVideoViewOperationDelegate> operationDelegate;

@property (nonatomic, assign, readonly) BOOL shouldAutoPlayRemoteVideoWhenNotWifi; // set bool value of kCTVideoViewShouldPlayRemoteVideoWhenNotWifi in NSUserDefaults to modify this property, default is NO

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;

- (void)prepare;
- (void)play;
- (void)pause;
- (void)replay;
- (void)stopWithReleaseVideo:(BOOL)shouldReleaseVideo;

// you will never use this method, it is for category only.
- (void)refreshUrl;

@end
