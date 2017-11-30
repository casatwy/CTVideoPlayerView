//
//  CTVideoView.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

#import "CTVideoView+Time.h"
#import "CTVideoView+Download.h"
#import "CTVideoView+VideoCoverView.h"
#import "CTVideoView+OperationButtons.h"
#import "CTVideoView+PlayControlPrivate.h"

#import "AVAsset+CTVideoView.h"

#import "CTVideoDownloadManager.h"

NSString * const kCTVideoViewShouldPlayRemoteVideoWhenNotWifi = @"kCTVideoViewShouldPlayRemoteVideoWhenNotWifi";

NSString * const kCTVideoViewKVOKeyPathPlayerItemStatus = @"player.currentItem.status";
NSString * const kCTVideoViewKVOKeyPathPlayerItemDuration = @"player.currentItem.duration";
NSString * const kCTVideoViewKVOKeyPathLayerReadyForDisplay = @"layer.readyForDisplay";

static void * kCTVideoViewKVOContext = &kCTVideoViewKVOContext;

@interface CTVideoView ()

@property (nonatomic, assign) BOOL isVideoUrlChanged;

@property (nonatomic, assign, readwrite) CTVideoViewPrepareStatus prepareStatus;
@property (nonatomic, assign, readwrite) CTVideoViewVideoUrlType videoUrlType;
@property (nonatomic, strong, readwrite) NSURL *actualVideoPlayingUrl;
@property (nonatomic, assign, readwrite) CTVideoViewVideoUrlType actualVideoUrlType;

@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong, readwrite) AVURLAsset *asset;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;


@end

@implementation CTVideoView

#pragma mark - life cycle
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self performInitProcess];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self performInitProcess];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self performInitProcess];
    }
    return self;
}

- (void)performInitProcess
{
    if (_prepareStatus != CTVideoViewPrepareStatusNotInitiated) {
        return;
    }
    // KVO
    [self addObserver:self
           forKeyPath:kCTVideoViewKVOKeyPathPlayerItemStatus
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:&kCTVideoViewKVOContext];
    
    [self addObserver:self
           forKeyPath:kCTVideoViewKVOKeyPathPlayerItemDuration
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:&kCTVideoViewKVOContext];

    [self addObserver:self
           forKeyPath:kCTVideoViewKVOKeyPathLayerReadyForDisplay
              options:NSKeyValueObservingOptionNew
              context:&kCTVideoViewKVOContext];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAVPlayerItemPlaybackStalledNotification:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    if ([self.playerLayer isKindOfClass:[AVPlayerLayer class]]) {
        self.playerLayer.player = self.player;
    }
    
    _shouldPlayAfterPrepareFinished = YES;
    _shouldReplayWhenFinish = YES;
    _shouldChangeOrientationToFitVideo = NO;
    _prepareStatus = CTVideoViewPrepareStatusNotPrepared;

    [self initTime];
    [self initDownload];
    [self initVideoCoverView];
    [self initOperationButtons];
    [self initPlayControlGestures];

    [self stopWithReleaseVideo:YES];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kCTVideoViewKVOKeyPathPlayerItemStatus context:kCTVideoViewKVOContext];
    [self removeObserver:self forKeyPath:kCTVideoViewKVOKeyPathPlayerItemDuration context:kCTVideoViewKVOContext];
    [self removeObserver:self forKeyPath:kCTVideoViewKVOKeyPathLayerReadyForDisplay context:kCTVideoViewKVOContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self deallocTime];
    [self deallocDownload];
    [self deallocVideoCoverView];
    [self deallocOperationButtons];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutButtons];
    [self layoutCoverView];
}

#pragma mark - methods override
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

#pragma mark - public methods
- (void)prepare
{
    if (self.isPlaying == YES && self.isVideoUrlChanged == NO) {
        return;
    }

    if (self.assetToPlay) {
        self.prepareStatus = CTVideoViewPrepareStatusPreparing;
        [self asynchronouslyLoadURLAsset:self.assetToPlay];
        return;
    }
    
    if (self.asset && self.prepareStatus == CTVideoViewPrepareStatusNotPrepared) {
        self.prepareStatus = CTVideoViewPrepareStatusPreparing;
        [self asynchronouslyLoadURLAsset:self.asset];
        return;
    }
    
    if (self.prepareStatus == CTVideoViewPrepareStatusPrepareFinished) {
        if ([self.operationDelegate respondsToSelector:@selector(videoViewDidFinishPrepare:)]) {
            [self.operationDelegate videoViewDidFinishPrepare:self];
        }
        return;
    }
}

- (void)play
{
    [self hidePlayButton];
    if (self.isPlaying) {
        [self hideCoverView];
        return;
    }
    
    if ([self.operationDelegate respondsToSelector:@selector(videoViewWillStartPlaying:)]) {
        [self.operationDelegate videoViewWillStartPlaying:self];
    }

    [self hideRetryButton];
    if (self.prepareStatus == CTVideoViewPrepareStatusPrepareFinished) {
        // hide cover view has moved to CTVideoView+Time
        [self willStartPlay];

        NSInteger currentPlaySecond = (NSInteger)(self.currentPlaySecond * 100);
        NSInteger totalDurationSeconds = (NSInteger)(self.totalDurationSeconds * 100);
        if (currentPlaySecond == totalDurationSeconds && totalDurationSeconds > 0) {
            [self replay];
        } else {
            [self.player play];
        }

    } else {
        self.shouldPlayAfterPrepareFinished = YES;
        [self prepare];
    }
}

- (void)pause
{
    [self hideCoverView];
    [self showPlayButton];
    if (self.isPlaying) {
        if ([self.operationDelegate respondsToSelector:@selector(videoViewWillPause:)]) {
            [self.operationDelegate videoViewWillPause:self];
        }
        [self.player pause];
        if ([self.operationDelegate respondsToSelector:@selector(videoViewDidPause:)]) {
            [self.operationDelegate videoViewDidPause:self];
        }
    }
}

- (void)replay
{
    [self hidePlayButton];
    [self hideRetryButton];
    [self.playerLayer.player seekToTime:kCMTimeZero];
    [self play];
}

- (void)stopWithReleaseVideo:(BOOL)shouldReleaseVideo
{
    if ([self.operationDelegate respondsToSelector:@selector(videoViewWillStop:)]) {
        [self.operationDelegate videoViewWillStop:self];
    }
    [self.player pause];
    [self showCoverView];
    [self showPlayButton];
    if (shouldReleaseVideo) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.prepareStatus = CTVideoViewPrepareStatusNotPrepared;
    }
    if ([self.operationDelegate respondsToSelector:@selector(videoViewDidStop:)]) {
        [self.operationDelegate videoViewDidStop:self];
    }
}

- (void)refreshUrl
{
    if ([[self.videoUrl pathExtension] isEqualToString:@"m3u8"]) {
        self.videoUrlType = CTVideoViewVideoUrlTypeLiveStream;
        self.actualVideoUrlType = CTVideoViewVideoUrlTypeLiveStream;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:[self.videoUrl path]]) {
        self.videoUrlType = CTVideoViewVideoUrlTypeNative;
        self.actualVideoUrlType = CTVideoViewVideoUrlTypeNative;
    } else {
        self.videoUrlType = CTVideoViewVideoUrlTypeRemote;
        self.actualVideoUrlType = CTVideoViewVideoUrlTypeRemote;
    }
    
    self.actualVideoPlayingUrl = self.videoUrl;
    if (self.actualVideoUrlType != CTVideoViewVideoUrlTypeNative) {
        NSURL *nativeUrl = [[CTVideoDownloadManager sharedInstance] nativeUrlForRemoteUrl:self.videoUrl];
        if (nativeUrl && [[NSFileManager defaultManager] fileExistsAtPath:[nativeUrl path]]) {
            self.actualVideoPlayingUrl = nativeUrl;
            self.actualVideoUrlType = CTVideoViewVideoUrlTypeNative;
        }
    }
    if (![self.asset.URL isEqual:self.actualVideoPlayingUrl]) {
        self.asset = [AVURLAsset assetWithURL:self.actualVideoPlayingUrl];
        self.prepareStatus = CTVideoViewPrepareStatusNotPrepared;
        self.isVideoUrlChanged = YES;
    }
}

#pragma mark - private methods
- (void)asynchronouslyLoadURLAsset:(AVAsset *)asset
{
    if ([self.operationDelegate respondsToSelector:@selector(videoViewWillStartPrepare:)]) {
        [self.operationDelegate videoViewWillStartPrepare:self];
    }
    WeakSelf;
    [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf;

            strongSelf.isVideoUrlChanged = NO;
            if (asset != strongSelf.asset && asset != strongSelf.assetToPlay) {
                return;
            }

            NSError *error = nil;
//            if ([asset statusOfValueForKey:@"tracks" error:&error] == AVKeyValueStatusFailed) {
//                strongSelf.prepareStatus = CTVideoViewPrepareStatusPrepareFailed;
//                [self showCoverView];
//                [self showRetryButton];
//                if ([strongSelf.operationDelegate respondsToSelector:@selector(videoViewDidFailPrepare:error:)]) {
//                    [strongSelf.operationDelegate videoViewDidFailPrepare:strongSelf error:error];
//                }
//                return;
//            }
            
            if ([asset statusOfValueForKey:@"tracks" error:&error] == AVKeyValueStatusFailed) {
                NSLog(@"%@", error);
            }
            
            if ([asset statusOfValueForKey:@"duration" error:&error] == AVKeyValueStatusFailed) {
                NSLog(@"%@", error);
            }
            
            if ([asset statusOfValueForKey:@"playable" error:&error] == AVKeyValueStatusFailed) {
                NSLog(@"%@", error);
            }
            
            if (strongSelf.shouldChangeOrientationToFitVideo) {
                CGFloat videoWidth = [[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].width;
                CGFloat videoHeight = [[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].height;
                
                if ([asset CTVideoView_isVideoPortraint]) {
                    if (videoWidth < videoHeight) {
                        if (strongSelf.transform.b != 1 || strongSelf.transform.c != -1) {
                            strongSelf.playerLayer.transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
                            strongSelf.playerLayer.frame = CGRectMake(0, 0, strongSelf.frame.size.height, strongSelf.frame.size.width);
                        }
                    }
                } else {
                    if (videoWidth > videoHeight) {
                        if (strongSelf.transform.b != 1 || strongSelf.transform.c != -1) {
                            strongSelf.playerLayer.transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
                            strongSelf.playerLayer.frame = CGRectMake(0, 0, strongSelf.frame.size.height, strongSelf.frame.size.width);
                        }
                    }
                }
            }
            
            strongSelf.playerItem = [AVPlayerItem playerItemWithAsset:asset];
            strongSelf.prepareStatus = CTVideoViewPrepareStatusPrepareFinished;

            if (strongSelf.shouldPlayAfterPrepareFinished) {
                [strongSelf play];
            }

            if ([strongSelf.operationDelegate respondsToSelector:@selector(videoViewDidFinishPrepare:)]) {
                [strongSelf.operationDelegate videoViewDidFinishPrepare:strongSelf];
            }
        });
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context != &kCTVideoViewKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([keyPath isEqualToString:kCTVideoViewKVOKeyPathPlayerItemStatus]) {
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;

        if (newStatus == AVPlayerItemStatusFailed) {
            DLog(@"%@", self.player.currentItem.error);
        }
    }
    
    if ([keyPath isEqualToString:kCTVideoViewKVOKeyPathPlayerItemDuration]) {
        [self durationDidLoadedWithChange:change];
    }

    if ([keyPath isEqualToString:kCTVideoViewKVOKeyPathLayerReadyForDisplay]) {
        if ([change[@"new"] boolValue] == YES) {
            [self setNeedsDisplay];
            if (self.prepareStatus == CTVideoViewPrepareStatusPrepareFinished) {
                if ([self.operationDelegate respondsToSelector:@selector(videoViewDidFinishPrepare:)]) {
                    [self.operationDelegate videoViewDidFinishPrepare:self];
                }
            }
        }
    }
}

#pragma mark - Notification
- (void)didReceiveAVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem) {
        if (self.shouldReplayWhenFinish) {
            [self replay];
        } else {
            [self.player seekToTime:kCMTimeZero];
            [self showPlayButton];
        }
        
        if ([self.operationDelegate respondsToSelector:@selector(videoViewDidFinishPlaying:)]) {
            [self.operationDelegate videoViewDidFinishPlaying:self];
        }
    }
}

- (void)didReceiveAVPlayerItemPlaybackStalledNotification:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem) {
        if (self.stalledStrategy == CTVideoViewStalledStrategyPlay) {
            [self play];
        }
        if (self.stalledStrategy == CTVideoViewStalledStrategyDelegateCallback) {
            if ([self.operationDelegate respondsToSelector:@selector(videoViewStalledWhilePlaying:)]) {
                [self.operationDelegate videoViewStalledWhilePlaying:self];
            }
        }
    }
}

#pragma mark - getters and setters
- (void)setAssetToPlay:(AVAsset *)assetToPlay
{
    _assetToPlay = assetToPlay;
    if (assetToPlay) {
        self.isVideoUrlChanged = YES;
        self.prepareStatus = CTVideoViewPrepareStatusNotPrepared;
        self.videoUrlType = CTVideoViewVideoUrlTypeAsset;
        self.actualVideoUrlType = CTVideoViewVideoUrlTypeAsset;
    }
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

- (void)setIsMuted:(BOOL)isMuted
{
    self.player.muted = isMuted;
}

- (BOOL)isMuted
{
    return self.player.muted;
}

- (BOOL)shouldAutoPlayRemoteVideoWhenNotWifi
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCTVideoViewShouldPlayRemoteVideoWhenNotWifi];
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    if (_videoUrl && [_videoUrl isEqual:videoUrl]) {
        self.isVideoUrlChanged = NO;
    } else {
        self.isVideoUrlChanged = YES;
        self.prepareStatus = CTVideoViewPrepareStatusNotPrepared;
    }

    _videoUrl = videoUrl;

    if (self.isVideoUrlChanged) {
        [self refreshUrl];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem != playerItem) {
        _playerItem = playerItem;
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

- (BOOL)isPlaying
{
    return self.player.rate >= 1.0;
}

- (AVPlayer *)player
{
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (void)setVideoContentMode:(CTVideoViewContentMode)videoContentMode
{
    _videoContentMode = videoContentMode;
    if (videoContentMode == CTVideoViewContentModeResize) {
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    }
    if (videoContentMode == CTVideoViewContentModeResizeAspect) {
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    if (videoContentMode == CTVideoViewContentModeResizeAspectFill) {
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

@end
