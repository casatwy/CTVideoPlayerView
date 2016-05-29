# CTVideoPlayerView

## CocoaPods

`pod "CTVideoPlayerView"`

## Quick Try

### 1. import header

`import <CTVideoPlayerView/CTVideoViewCommonHeader.h>`

### 2. play

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

set download strategy to `CTVideoViewDownloadStrategyDownloadOnlyForeground` or `CTVideoViewDownloadStrategyDownloadOnlyForeground` to enable `Download`
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

1. set `shouldObservePlayTime` to YES.

```objective-C
videoView.shouldObservePlayTime = YES;
```

2. set `timeDelegate`

```objective-C
videoView.timeDelegate = self;
```

3. implement `- (void)videoView:didPlayToSecond:` in timeDelegate

```objective-C
- (void)videoView:(CTVideoView *)videoView didPlayToSecond:(CGFloat)second
{
	NSLog(@"%f", second);
}
```

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
