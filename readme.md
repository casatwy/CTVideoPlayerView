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

