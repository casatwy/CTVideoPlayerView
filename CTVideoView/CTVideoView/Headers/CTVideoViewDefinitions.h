//
//  CTVideoViewDefinitions.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef CTVideoViewDefinitions_h
#define CTVideoViewDefinitions_h

/**********************************************************************/

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;

#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

/**********************************************************************/

@import CoreMedia;
@class CTVideoView;

/**
 *  keys used in NSUserDefaults
 */
extern NSString * const kCTVideoViewShouldDownloadWhenNotWifi;
extern NSString * const kCTVideoViewShouldPlayRemoteVideoWhenNotWifi;

/**
 *  keys used in KVO
 */
extern NSString * const kCTVideoViewKVOKeyPathPlayerItemStatus;
extern NSString * const kCTVideoViewKVOKeyPathPlayerItemDuration;

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


/**********************************************************************/

typedef NS_ENUM(NSUInteger, CTVideoViewDownloadStrategy) {
    CTVideoViewDownloadStrategyNoDownload, // no download
    CTVideoViewDownloadStrategyDownloadOnlyForeground,
    CTVideoViewDownloadStrategyDownloadForegroundAndBackground,
};

typedef NS_ENUM(NSUInteger, CTVideoViewVideoUrlType) {
    CTVideoViewVideoUrlTypeRemote,
    CTVideoViewVideoUrlTypeNative,
    CTVideoViewVideoUrlTypeLiveStream,
    CTVideoViewVideoUrlTypeAsset,
};

typedef NS_ENUM(NSUInteger, CTVideoViewContentMode) {
    CTVideoViewContentModeResizeAspect, // default, same as AVLayerVideoGravityResizeAspect
    CTVideoViewContentModeResizeAspectFill, // same as AVLayerVideoGravityResizeAspectFill
    CTVideoViewContentModeResize, // same as same as AVLayerVideoGravityResize
};

typedef NS_ENUM(NSUInteger, CTVideoViewOperationButtonType) {
    CTVideoViewOperationButtonTypePlay,
    CTVideoViewOperationButtonTypePause,
    CTVideoViewOperationButtonTypeRetry
};

typedef NS_ENUM(NSUInteger, CTVideoViewStalledStrategy) {
    CTVideoViewStalledStrategyPlay,
    CTVideoViewStalledStrategyDelegateCallback,
};

typedef NS_ENUM(NSUInteger, CTVideoViewPrepareStatus) {
    CTVideoViewPrepareStatusNotInitiated,
    CTVideoViewPrepareStatusNotPrepared,
    CTVideoViewPrepareStatusPreparing,
    CTVideoViewPrepareStatusPrepareFinished,
    CTVideoViewPrepareStatusPrepareFailed,
};

typedef NS_ENUM(NSUInteger, CTVideoViewPlayControlDirection) {
    CTVideoViewPlayControlDirectionMoveForward,
    CTVideoViewPlayControlDirectionMoveBackward,
};

/**********************************************************************/

@protocol CTVideoViewOperationDelegate <NSObject>

@optional
- (void)videoViewWillStartPrepare:(CTVideoView *)videoView;
- (void)videoViewDidFinishPrepare:(CTVideoView *)videoView;
- (void)videoViewDidFailPrepare:(CTVideoView *)videoView error:(NSError *)error;

- (void)videoViewWillStartPlaying:(CTVideoView *)videoView;
- (void)videoViewDidStartPlaying:(CTVideoView *)videoView; // will call this method when the video is **really** playing.
- (void)videoViewStalledWhilePlaying:(CTVideoView *)videoView;
- (void)videoViewDidFinishPlaying:(CTVideoView *)videoView;

- (void)videoViewWillPause:(CTVideoView *)videoView;
- (void)videoViewDidPause:(CTVideoView *)videoView;

- (void)videoViewWillStop:(CTVideoView *)videoView;
- (void)videoViewDidStop:(CTVideoView *)videoView;

@end

/**********************************************************************/

@protocol CTVideoViewButtonDelegate <NSObject>

@optional
- (void)videoView:(CTVideoView *)videoView didTappedPlayButton:(UIButton *)playButton;
- (void)videoView:(CTVideoView *)videoView didTappedRetryButton:(UIButton *)retryButton;

- (void)videoView:(CTVideoView *)videoView layoutPlayButton:(UIButton *)playButton;
- (void)videoView:(CTVideoView *)videoView layoutRetryButton:(UIButton *)retryButton;

@end

/**********************************************************************/

@protocol CTVideoViewTimeDelegate <NSObject>

@optional
- (void)videoViewDidLoadVideoDuration:(CTVideoView *)videoView;
- (void)videoView:(CTVideoView *)videoView didFinishedMoveToTime:(CMTime)time;
- (void)videoView:(CTVideoView *)videoView didPlayToSecond:(CGFloat)second; //if you want this method to be called, you should set shouldObservePlayTime to YES.

@end

/**********************************************************************/

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

/**********************************************************************/
@protocol CTVideoViewPlayControlDelegate <NSObject>

@optional

- (void)videoViewShowPlayControlIndicator:(CTVideoView *)videoView;
- (void)videoViewHidePlayControlIndicator:(CTVideoView *)videoView;
- (void)videoView:(CTVideoView *)videoView playControlDidMoveToSecond:(CGFloat)second direction:(CTVideoViewPlayControlDirection)direction;

@end

#endif /* CTVideoViewDefinitions_h */
