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

#import "AVAsset+CTVideoView.h"

#import "CTVideoManager.h"

NSString * const kCTVideoViewShouldPlayRemoteVideoWhenNotWifi = @"kCTVideoViewShouldPlayRemoteVideoWhenNotWifi";

NSString * const kCTVideoViewKVOKeyPathPlayerItemStatus = @"player.currentItem.status";
NSString * const kCTVideoViewKVOKeyPathPlayerItemDuration = @"player.currentItem.duration";

static void * kCTVideoViewKVOContext = &kCTVideoViewKVOContext;

@interface CTVideoView ()

@property (nonatomic, assign) BOOL isVideoUrlChanged;
@property (nonatomic, assign) BOOL isPreparedForPlay;
@property (nonatomic, assign) CTVideoViewPrepareStatus prepareStatus;

@property (nonatomic, assign, readwrite) CTVideoViewVideoUrlType videoUrlType;
@property (nonatomic, strong, readwrite) NSURL *actualVideoPlayingUrl;
@property (nonatomic, assign, readwrite) CTVideoViewVideoUrlType actualVideoUrlType;

@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong, readwrite) AVURLAsset *asset;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;

@end

@implementation CTVideoView

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // KVO
        [self addObserver:self
               forKeyPath:kCTVideoViewKVOKeyPathPlayerItemStatus
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                  context:&kCTVideoViewKVOContext];
        
        [self addObserver:self
               forKeyPath:kCTVideoViewKVOKeyPathPlayerItemDuration
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                  context:&kCTVideoViewKVOContext];
        
        // Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAVPlayerItemPlaybackStalledNotification:) name:AVPlayerItemPlaybackStalledNotification object:nil];

        _shouldPlayAfterPrepareFinished = YES;
        _shouldReplayWhenFinish = NO;
        _shouldChangeOrientationToFitVideo = NO;
        _isPreparedForPlay = NO;

        if ([self.playerLayer isKindOfClass:[AVPlayerLayer class]]) {
            self.playerLayer.player = self.player;
        }
        
        [self initTime];
        [self initDownload];
        [self initVideoCoverView];
        [self initOperationButtons];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kCTVideoViewKVOKeyPathPlayerItemStatus context:kCTVideoViewKVOContext];
    [self removeObserver:self forKeyPath:kCTVideoViewKVOKeyPathPlayerItemDuration context:kCTVideoViewKVOContext];
    
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

    if (self.asset && self.prepareStatus == CTVideoViewPrepareStatusNotPrepared) {
        self.prepareStatus = CTVideoViewPrepareStatusPreparing;
        [self asynchronouslyLoadURLAsset:self.asset];
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
        [self.player play];
    } else {
        self.isPreparedForPlay = YES;
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
        NSURL *nativeUrl = [[CTVideoManager sharedInstance] nativeUrlForRemoteUrl:self.videoUrl];
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
- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)asset
{
    if ([self.operationDelegate respondsToSelector:@selector(videoViewWillStartPrepare:)]) {
        [self.operationDelegate videoViewWillStartPrepare:self];
    }
    WeakSelf;
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf;

            strongSelf.isVideoUrlChanged = NO;
            if (asset != strongSelf.asset) {
                return;
            }

            NSError *error = nil;
            if ([asset statusOfValueForKey:@"tracks" error:&error] == AVKeyValueStatusFailed) {
                strongSelf.prepareStatus = CTVideoViewPrepareStatusPrepareFailed;
                [self showCoverView];
                [self showRetryButton];
                if ([strongSelf.operationDelegate respondsToSelector:@selector(videoViewDidFailPrepare:error:)]) {
                    [strongSelf.operationDelegate videoViewDidFailPrepare:strongSelf error:error];
                }
                return;
            }
            
            if (strongSelf.shouldChangeOrientationToFitVideo) {
                AVAsset *asset = strongSelf.asset;
                CGFloat videoWidth = [[[strongSelf.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].width;
                CGFloat videoHeight = [[[strongSelf.asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize].height;
                
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
            
            strongSelf.playerItem = [AVPlayerItem playerItemWithAsset:strongSelf.asset];
            strongSelf.prepareStatus = CTVideoViewPrepareStatusPrepareFinished;

            if ([strongSelf.operationDelegate respondsToSelector:@selector(videoViewDidFinishPrepare:)]) {
                [strongSelf.operationDelegate videoViewDidFinishPrepare:strongSelf];
            }
            
            if (strongSelf.shouldPlayAfterPrepareFinished) {

                // always play native video
                if (strongSelf.actualVideoUrlType == CTVideoViewVideoUrlTypeNative) {
                    [strongSelf play];
                    return;
                }

                // always play video under wifi
                if ([CTVideoManager sharedInstance].isWifi) {
                    [strongSelf play];
                    return;
                }

                // even user is not in wifi, we still play video if user allows us to play remote video when not wifi
                if (self.shouldAutoPlayRemoteVideoWhenNotWifi == YES) {
                    [strongSelf play];
                    return;
                }
            }
            
            if (strongSelf.isPreparedForPlay) {
                // because user tapped play button, video plays anyway, no matter whether user is in wifi.
                strongSelf.isPreparedForPlay = NO;
                [strongSelf play];
                return;
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
}

#pragma mark - Notification
- (void)didReceiveAVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem) {
        if (self.shouldReplayWhenFinish) {
            [self replay];
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
