//
//  CTVideoView.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

@import AVFoundation;
@import CoreMedia;

#import "CTVideoView.h"

#import "CTVideoView+Time.h"
#import "CTVideoView+Download.h"
#import "CTVideoView+VideoCoverView.h"
#import "CTVideoView+OperationButtons.h"

NSString * const kCTVideoViewShouldPlayRemoteVideoWhenNotWifi = @"kCTVideoViewShouldPlayRemoteVideoWhenNotWifi";

@interface CTVideoView ()

@property (nonatomic, assign) BOOL isVideoUrlChanged;
@property (nonatomic, assign) BOOL isVideoUrlPrepared;

@property (nonatomic, strong, readwrite) NSURL *actualVideoPlayingUrl;
@property (nonatomic, assign, readwrite) CTVideoViewVideoUrlType videoUrlType;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation CTVideoView

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];

        _isMuted = NO;
        _shouldPlayAfterPrepareFinished = YES;
        _shouldReplayWhenFinish = NO;
        _shouldChangeOrientationToFitVideo = NO;

        [self player];
    }
    return self;
}

- (void)dealloc
{

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

    if (self.asset) {
        [self asynchronouslyLoadURLAsset:self.asset];
    }
}

- (void)play
{
    if (self.isVideoUrlPrepared) {
        [self.player play];
    } else {
        [self prepare];
    }
}

- (void)pause
{
    
}

- (void)stop:(BOOL)shouldReleaseVideo
{
    
}

#pragma mark - private methods
- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)asset
{
    WeakSelf;
    [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf;

            strongSelf.isVideoUrlChanged = NO;
            strongSelf.isVideoUrlPrepared = YES;
            
            if (asset != strongSelf.asset) {
                return;
            }

            NSError *error = nil;
            if ([asset statusOfValueForKey:@"playable" error:&error] == AVKeyValueStatusFailed) {
                return;
            }
            strongSelf.playerItem = [AVPlayerItem playerItemWithAsset:strongSelf.asset];
        });
    }];
}

#pragma mark - getters and setters
- (BOOL)shouldPlayRemoteVideoWhenNotWifi
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCTVideoViewShouldPlayRemoteVideoWhenNotWifi];
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    if (_videoUrl && [_videoUrl isEqual:videoUrl]) {
        self.isVideoUrlChanged = NO;
    } else {
        self.isVideoUrlPrepared = NO;
        self.isVideoUrlChanged = YES;
    }

    _videoUrl = videoUrl;
    self.actualVideoPlayingUrl = videoUrl;
    
    if ([[videoUrl pathExtension] isEqualToString:@"m3u8"]) {
#warning todo check whether has downloaded this url, and set to actual video url
        self.videoUrlType = CTVideoViewVideoUrlTypeLiveStream;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:[videoUrl path]]) {
        self.videoUrlType = CTVideoViewVideoUrlTypeNative;
    } else {
#warning todo check whether has downloaded this url, and set to actual video url
        self.videoUrlType = CTVideoViewVideoUrlTypeRemote;
    }

    self.asset = [AVURLAsset assetWithURL:self.actualVideoPlayingUrl];
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

@end
