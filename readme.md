# CTVideoPlayerView

[![Join the chat at https://gitter.im/casatwy/CTVideoPlayerView](https://badges.gitter.im/casatwy/CTVideoPlayerView.svg)](https://gitter.im/casatwy/CTVideoPlayerView?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Features

- it's an UIView
- plays local media or streams remote media over HTTP
- customizable UI and user interaction
- no size restrictions
- orientation change support
- simple API
- playback time observe, video duration
- download & native file management
- support customized cover view when downloading video, All you need to do is create a `UIView<CTVideoPlayerDownloadingViewProtocol>` and assign it to `CTVideoView.downloadingView`. check `DownloadThenPlayViewController` for more detail.
- support changing to full screen, and exit from full screen
- support horizontal slide to move to the playing second forward or backward, and vertical slide to change the volume

todo:
- cache played video which comes from a remote url
- play youtube
- play [RTSP](https://en.wikipedia.org/wiki/Real_Time_Streaming_Protocol) / [RTMP](https://en.wikipedia.org/wiki/Real_Time_Messaging_Protocol)

## CocoaPods

`pod "CTVideoPlayerView"`

## Quick Try

### 1. import header

`import <CTVideoPlayerView/CTVideoViewCommonHeader.h>`

### 2. Play

#### 2.1 play with asset

```objective-c
CTVideoView *videoView = [[CTVideoView alloc] init];
videoView.assetToPlay = [AVURLAsset assetWithURL:assetUrl];
[videoView play];
```

CTVideoView can play any AVAsset directly, but the `videoUrlType` and `actualVideoUrlType` will be set to `CTVideoViewVideoUrlTypeAsset`.

If you do care about the url type of what you are playing, you should see `play with URL` below.

#### 2.2 play with URL

Set `videoUrl` to make `CTVideoView` play with URL, the `videoUrlType` and `actualVideoUrlType` will be valued properly, if you don't care about them, just use `play with asset` above.

in short:
```objective-c
CTVideoView *videoView = [[CTVideoView alloc] init];
videoView.frame = CGRectMake(0,0,100,100);
[self.view addSubview:videoView];

videoView.videoUrl = [NSURL URLWithString:@"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_865e1fff817746d29ecc4996f93b7f74"]; // mp4 playable
[videoView play];
```

long story:

```objective-c
@interface SingleVideoViewController ()

@property (nonatomic, strong) CTVideoView *videoView;

@end

@implementation SingleVideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.videoView];

	// self.videoView.videoUrl = [NSURL URLWithString:@"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_865e1fff817746d29ecc4996f93b7f74"]; // mp4 playable
	// self.videoView.videoUrl = [NSURL URLWithString:@"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"]; // m3u8 playable
	self.videoView.videoUrl = [[NSBundle mainBundle] URLForResource:@"a" withExtension:@"mp4"]; // native url playable
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 	self.videoView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.videoView play];
}

- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
	}
    return _videoView;
}

@end
```

## More Example

### Download Video

set download strategy to `CTVideoViewDownloadStrategyDownloadOnlyForeground` or `CTVideoViewDownloadStrategyDownloadForegroundAndBackground` to enable `Download`
```objective-C
[CTVideoManager sharedInstance].downloadStrategy = CTVideoViewDownloadStrategyDownloadForegroundAndBackground;

// they works the same
[videoView startDownloadTask];
// [[CTVideoManager sharedInstance] startDownloadTaskWithUrl:url];
// [[CTVideoManager sharedInstance] startAllDownloadTask];
```

if download strategy is `CTVideoViewDownloadStrategyNoDownload`, the download task won't generate even you make a download call.

```objective-C
[CTVideoManager sharedInstance].downloadStrategy = CTVideoViewDownloadStrategyNoDownload;

[videoView startDownloadTask]; // won't start download task
[[CTVideoManager sharedInstance] startDownloadTaskWithUrl:url]; // won't start download task
[[CTVideoManager sharedInstance] startAllDownloadTask]; // won't start download task
```

after the video is downloaded, CTVideoPlayerView will remember where the native file is, and which remote url is responds to. You can call `refreshUrl` to refresh current video view's url, and then play the native video file. If you create a brand new video player view, and set `videoUrl` to a remote url, video player view will search the native file and replace it automatically.

### Download Events

you can set `downloadDelegate` to video player view for more control. 

```objective-C
@protocol CTVideoViewDownloadDelegate <NSObject>

@optional
- (void)videoViewWillStartDownload:(CTVideoView *)videoView;
- (void)videoView:(CTVideoView *)videoView downloadProgress:(CGFloat)progress;
- (void)videoViewDidFinishDownload:(CTVideoView *)videoView;
- (void)videoViewDidFailDownload:(CTVideoView *)videoView;
- (void)videoViewDidPausedDownload:(CTVideoView *)videoView;
- (void)videoViewDidDeletedDownloadTask:(CTVideoView *)videoView;
- (void)videoViewIsWaitingForDownload:(CTVideoView *)videoView;

@end
```

If you don't have a video player view instance, you can observe notifications in `CTVideoViewDefinitions.h` to get notice of the download events.

```objective-C
/**
 *  notifications
 */
extern NSString * const kCTVideoManagerWillDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidFinishDownloadVideoNotification;
extern NSString * const kCTVideoManagerDownloadVideoProgressNotification;
extern NSString * const kCTVideoManagerDidFailedDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidPausedDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidDeletedDownloadVideoNotification;

/**
 *  notification userinfo keys
 */
extern NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrlList;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyNativeUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyProgress;
```

### Manage Native Video Files

just use `CTVideoDataCenter`.

```objective-C
@interface CTVideoDataCenter : NSObject

// create
- (void)insertRecordWithRemoteUrl:(NSURL *)remoteUrl status:(CTVideoRecordStatus)status;

// read
- (NSURL *)nativeUrlWithRemoteUrl:(NSURL *)remoteUrl;
- (NSArray <id<CTPersistanceRecordProtocol>> *)recordListWithStatus:(CTVideoRecordStatus)status;
- (CTVideoRecordStatus)statusOfRemoteUrl:(NSURL *)remoteUrl;
- (id<CTPersistanceRecordProtocol>)recordOfRemoteUrl:(NSURL *)url;

// update
- (void)updateWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl;
- (void)updateWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl status:(CTVideoRecordStatus)status;

- (void)updateStatus:(CTVideoRecordStatus)status toRemoteUrl:(NSURL *)remoteUrl;
- (void)updateStatus:(CTVideoRecordStatus)status progress:(CGFloat)progress toRemoteUrl:(NSURL *)remoteUrl;
- (void)updateAllStatus:(CTVideoRecordStatus)status;

- (void)pauseAllRecordWithCompletion:(void(^)(void))completion;
- (void)pauseRecordWithRemoteUrlList:(NSArray *)remoteUrlList completion:(void(^)(void))completion;

- (void)startDownloadAllRecordWithCompletion:(void(^)(void))completion;
- (void)startDownloadRemoteUrlList:(NSArray *)remoteUrlList completion:(void(^)(void))completion;

// delete
- (void)deleteWithRemoteUrl:(NSURL *)remoteUrl;
- (void)deleteAllRecordWithCompletion:(void(^)(NSArray *deletedList))completion;
- (void)deleteAllNotFinishedVideo;

@end
```

You may want more method in this data center, you can fire an issue to tell me what method you want, or give me a pull request directly.

### Observe Time

#### 1. set `shouldObservePlayTime` to YES, and set timeGapToObserve.

if timeGapToObserve is 1, means 1/100 second.

```objective-C
[videoView setShouldObservePlayTime:YES withTimeGapToObserve:10.0f]; // calls the delegate method `- (void)videoView:didPlayToSecond:` every 0.1s during playing.
```

#### 2. set `timeDelegate`

```objective-C
videoView.timeDelegate = self;
```

#### 3. implement `- (void)videoView:didPlayToSecond:` in timeDelegate

```objective-C
- (void)videoView:(CTVideoView *)videoView didPlayToSecond:(CGFloat)second
{
	NSLog(@"%f", second);
}
```
### Customize Operation Button

#### 1. set custmized button

```objective-C
videoView.playButton = customizedPlayButton;
videoView.retryButton = customizedRetryButton;
```

#### 2. set `id<CTVideoViewButtonDelegate>` and implement methods to layout your button

If you don't do this, the buttons will be layouted as size of CGSizeMake(100, 60), and will be put in center of the video. 

use `pod "HandyFrame"` will make your layout code easy and clean.

```objective-C
#import <HandyFrame/UIView+LayoutMethods.h>
```

set the button delegate

```objective-C
videoView.buttonDelegate = self;
```

layout with [HandyFrame](https://github.com/casatwy/HandyAutoLayout)

```objective-C
- (void)videoView:(CTVideoView *)videoView layoutPlayButton:(UIButton *)playButton
{
    playButton.size = CGSizeMake(100, 60);
	[playButton rightInContainer:5 shouldResize:NO];
   	[playButton bottomInContainer:5 shouldResize:NO];
}

- (void)videoView:(CTVideoView *)videoView layoutRetryButton:(UIButton *)retryButton
{
    retryButton.size = CGSizeMake(100, 60);
	[retryButton rightInContainer:5 shouldResize:NO];
   	[retryButton bottomInContainer:5 shouldResize:NO];
}
```

### play with full screen and exit full screen
```
    if (self.videoView.isFullScreen) {
        [self.videoView exitFullScreen];
    } else {
        [self.videoView enterFullScreen];
    }
```

see the demo ![ChangeToFullScreenViewController](controller://github.com/casatwy/CTVideoPlayerView/blob/master/CTVideoView/DemoControllers/ChangeOrientationViewController/ChangeToFullScreenViewController.m)

### slide to move forward or backward

This function is enabled by default, if you do not want it, just set `isSlideFastForwardDisabled` to `YES`

```
videoView.isSlideFastForwardDisabled = YES;
```

To show the move indicator, you should set `playControlDelegate`, and use method below

```
@protocol CTVideoViewPlayControlDelegate <NSObject>

@optional

- (void)videoViewShowPlayControlIndicator:(CTVideoView *)videoView;
- (void)videoViewHidePlayControlIndicator:(CTVideoView *)videoView;
- (void)videoView:(CTVideoView *)videoView playControlDidMoveToSecond:(CGFloat)second direction:(CTVideoViewPlayControlDirection)direction;

@end
```

the delegate method `- (void)videoViewShowPlayControlIndicator:(CTVideoView *)videoView;` tells you that you can show your own customized indicator view.

the delegate method `- (void)videoViewHidePlayControlIndicator:(CTVideoView *)videoView;` tells you that you can hide your own customized indicator view.

the delegate method `- (void)videoView:(CTVideoView *)videoView playControlDidMoveToSecond:(CGFloat)second direction:(CTVideoViewPlayControlDirection)direction;` tells you the data that you can use to update the content of your own customized indicator view.

## Manual

### properties

#### Regular

##### isMuted

set video muted

##### shouldPlayAfterPrepareFinished

if you want to play video immediatly after video is prepared, set this to YES.

if you call `play` instead of `prepare`, video will play after prepare finished, even you set this property to NO.

##### shouldReplayWhenFinish

set to YES will replay the video when the video reaches to the end.

##### shouldChangeOrientationToFitVideo

set to YES will change video view's orientation automatically for video playing.

#### Download

##### shouldDownloadWhenNotWifi

this is a readonly property, if you want to change the value, set bool value of `kCTVideoViewShouldDownloadWhenNotWifi` in `NSUserDefaults` to change this value, default is NO

#### Operation Buttons

##### shouldShowOperationButton

set to YES to indicate video view should show operation button

##### playButton

the view of customized play button

##### retryButton

the view of customized retry button

#### Time

##### totalDurationSeconds

to show how long the video is in seconds

##### shouldObservePlayTime

if you want `- (void)videoView:didPlayToSecond:` of `id<CTVideoViewTimeDelegate>` to be called, you should set this property to YES.

##### currentPlaySpeed

set 2.0 means speed of 2x.

#### Video Cover View

##### shouldShowOperationButton

set to YES to indicate video view should show video cover view

##### coverView

the customized cover view
