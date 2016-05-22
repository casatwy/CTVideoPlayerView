//
//  CTVideoView.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTVideoViewDefinitions.h"
#import "CTOtherObjectsDefinition.h"

@interface CTVideoView : UIView

/**
 *  for performance concern, set videoUrl will not call `-(void)prepare`, you should call `-(void)prepare` at a good time, say `- (void)tableView:willDisplayCell:forRowAtIndexPath:` or `-(void)viewDidAppear:`.
 */
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, assign) BOOL isMuted; // set YES to mute the video playing
@property (nonatomic, assign) BOOL shouldPlayAfterPrepareFinished; // default is YES
@property (nonatomic, assign) BOOL shouldReplayWhenFinish; // default is NO
@property (nonatomic, assign) BOOL shouldChangeOrientationToFitVideo; // default is NO

@property (nonatomic, weak) id<CTVideoViewOperationDelegate> operationDelegate;

@property (nonatomic, assign, readonly) BOOL isLiveStreamingVideo;
@property (nonatomic, copy, readonly) NSURL *actualVideoPlayingUrl;
@property (nonatomic, assign, readonly) BOOL shouldPlayRemoteVideoWhenNotWifi; // set bool value of kCTVideoViewShouldPlayRemoteVideoWhenNotWifi in NSUserDefaults to modify this property, default is NO

- (void)prepare;
- (void)play;
- (void)pause;
- (void)stop:(BOOL)shouldReleaseVideo;

/**
 *  replace current playing video with new video url.
 *
 *  @param url new video url. If set nil, the current video will stop and release.
 */
- (void)replaceWithVideoUrl:(NSURL *)url;

@end
