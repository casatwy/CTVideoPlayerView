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

@property (nonatomic, assign, readonly) BOOL isLiveStreamingVideo;
@property (nonatomic, copy, readonly) NSURL *actualVideoPlayingUrl;

@property (nonatomic, assign) BOOL isMuted; // set YES to mute the video playing

@property (nonatomic, strong) NSURL *customizedVideoCoverImageUrl; // if nil, will show the first frame of video. if set, will show the image of this url as a cover before playing video. Default is nil.


/*  ==================================  Time  ==================================  */

@property (nonatomic, assign, readonly) CGFloat totalDurationSeconds;
@property (nonatomic, assign, readonly) CGFloat currentPlaySpeed;

/**
 *  if you want - (void)videoView:didPlayToSecond: to be called, you should set shouldObservePlayTime to YES.
 */
@property (nonatomic, assign) BOOL shouldObservePlayTime;

- (void)moveToSecond:(CGFloat)second shouldPlay:(BOOL)shouldPlay;
- (void)setSpeed:(CGFloat)speed shouldPlay:(BOOL)shouldPlay;



/*  ==================================  Video Operations  ==================================  */

@property (nonatomic, assign) BOOL shouldPlayAfterPrepareFinished; // default is YES
@property (nonatomic, assign) BOOL shouldReplayWhenFinish; // default is NO
@property (nonatomic, assign) BOOL shouldChangeOrientationToFitVideo; // default is NO
@property (nonatomic, assign, readonly) BOOL shouldPlayRemoteVideoWhenNotWifi; // set bool value of kCTVideoViewShouldPlayRemoteVideoWhenNotWifi in NSUserDefaults to modify this property, default is NO

@property (nonatomic, weak) id<CTVideoViewOperationDelegate> operationDelegate;

/**
 *  for performance concern, set videoUrl will not call `-(void)prepare`, you should call `-(void)prepare` at a good time, say `- (void)tableView:willDisplayCell:forRowAtIndexPath:` or `-(void)viewDidAppear:`.
 */
@property (nonatomic, strong) NSURL *videoUrl;

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



/*  ==================================  Download  ==================================  */

@property (nonatomic, assign) CTVideoViewDownloadStrategy downloadStrategy;
@property (nonatomic, assign, readonly) BOOL shouldDownloadWhenNotWifi; // set bool value of kCTVideoViewShouldDownloadWhenNotWifi in NSUserDefaults to modify this property, default is NO

@property (nonatomic, weak) id<CTVideoViewDownloadDelegate> downloadDelegate;

- (void)startDownload;
- (void)cancelDownload;



/*  ==================================  Operation Buttons  ==================================  */

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
