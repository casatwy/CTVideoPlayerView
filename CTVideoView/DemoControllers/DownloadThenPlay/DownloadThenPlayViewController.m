//
//  DownloadThenPlayViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "DownloadThenPlayViewController.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import "CTVideoViewCommonHeader.h"
#import "VideoDownloadingView.h"

@interface DownloadThenPlayViewController () <CTVideoViewDownloadDelegate>

@property (nonatomic, strong) CTVideoView *videoView;
@property (nonatomic, assign) BOOL hasBeenPaused;

@end

@implementation DownloadThenPlayViewController

#pragma mark - life cycle
- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        [CTVideoDownloadManager sharedInstance].downloadStrategy = CTVideoViewDownloadStrategyDownloadForegroundAndBackground;
        NSURL *videoUrl = [NSURL URLWithString:urlString];
        [[CTVideoDownloadManager sharedInstance] deleteVideoWithUrl:videoUrl];
        self.videoView.videoUrl = videoUrl;
        _hasBeenPaused = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.videoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.videoView fill];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoView prepare];
    [self.videoView startDownloadTask];
    
    /* the commented code is using for test download file count limit
    NSArray *list = @[
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_856a6738eefc495bbd7b0ed59beaa9fe",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_e05f72400bae4e0b8ae6825c5891af64",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_f905cb3d6a1847afb071b3aeea42eb51",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_57dad11ccfd3422cbe6f0b2674fa0ab1",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_b5b00d7e77854a2ea478cd5dd648191d",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_d7c0843949284cb79a8f4bed20111577",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_34dd3f3f36974092876efbcac1d1160d",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_42b791e5aed7463b865518378a78de6a",
                      @"http://7xs8ft.com2.z0.glb.qiniucdn.com/rcd_vid_03e0b80cc69b4f069af9b5ba88be6752",
                      ];
    
    for (NSString *urlString in list) {
        NSURL *url = [NSURL URLWithString:urlString];
        [[CTVideoManager sharedInstance] startDownloadTaskWithUrl:url];
    }
     */
    
}

#pragma mark - CTVideoViewDownloadDelegate
- (void)videoViewWillStartDownload:(CTVideoView *)videoView
{

}

- (void)videoView:(CTVideoView *)videoView downloadProgress:(CGFloat)progress
{
    DLog(@"Download Progress %.2f", progress);
    if (progress > 0.5) {
        if (self.hasBeenPaused == NO) {
            self.hasBeenPaused = YES;
            [[CTVideoDownloadManager sharedInstance] pauseDownloadTaskWithUrl:self.videoView.videoUrl completion:nil];
        }
    }
}

- (void)videoViewDidFinishDownload:(CTVideoView *)videoView
{
//    [self.videoView play];
}

- (void)videoViewDidFailDownload:(CTVideoView *)videoView
{

}

- (void)videoViewDidPausedDownload:(CTVideoView *)videoView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CTVideoDownloadManager sharedInstance] startDownloadTaskWithUrl:self.videoView.videoUrl];
    });
}

#pragma mark - getters and setter
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.downloadDelegate = self;
        _videoView.shouldReplayWhenFinish = YES;
        
        _videoView.downloadingView = [[VideoDownloadingView alloc] init];
        
        _videoView.shouldShowOperationButton = YES;
        
        _videoView.shouldShowCoverViewBeforePlay = YES;
        UILabel *coverView = [[UILabel alloc] init];
        coverView.text = @"Cover View";
        coverView.textAlignment = NSTextAlignmentCenter;
        coverView.backgroundColor = [UIColor blueColor];
        _videoView.coverView = coverView;
    }
    return _videoView;
}

@end
