//
//  CTVideoViewDefinitions.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#ifndef CTVideoViewDefinitions_h
#define CTVideoViewDefinitions_h

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;

#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

/**
 *  keys used in NSUserDefaults
 */
extern NSString * const kCTVideoViewShouldDownloadWhenNotWifi;
extern NSString * const kCTVideoViewShouldPlayRemoteVideoWhenNotWifi;

@class CTVideoView;

@protocol CTVideoViewOperationDelegate <NSObject>

@optional
- (void)videoViewWillStartPrepare:(CTVideoView *)videoView;
- (void)videoViewDidFinishPrepare:(CTVideoView *)videoView;
- (void)videoViewDidFailPrepare:(CTVideoView *)videoView error:(NSError *)error;

- (void)videoView:(CTVideoView *)videoView willStartAtSecond:(CGFloat)second;
- (void)videoView:(CTVideoView *)videoView didPlayToSecond:(CGFloat)second; //if you want this method to be called, you should set shouldObservePlayTime to YES.
- (void)videoViewDidFinishPlaying:(CTVideoView *)videoView;

- (void)videoViewWillPause:(CTVideoView *)videoView;
- (void)videoViewDidPause:(CTVideoView *)videoView;

- (BOOL)videoViewWillStop:(CTVideoView *)videoView; // return YES to release video after stop.
- (void)videoViewDidStop:(CTVideoView *)videoView;

@end

@protocol CTVideoViewDownloadDelegate <NSObject>

@optional
- (void)videoView:(CTVideoView *)videoView willStartDownloadWithUrl:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier;
- (void)videoView:(CTVideoView *)videoView downloadProgress:(CGFloat *)progress url:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier;
- (void)videoView:(CTVideoView *)videoView didFinishDownloadUrl:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier;
- (void)videoView:(CTVideoView *)videoView didFailDownloadUrl:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier;

@end

typedef NS_ENUM(NSUInteger, CTVideoViewDownloadStrategy) {
    CTVideoViewDownloadStrategyDefault,
    CTVideoViewDownloadStrategyDownloadOnlyForeground,
    CTVideoViewDownloadStrategyDownloadForegroundAndBackground,
};

typedef NS_ENUM(NSUInteger, CTVideoViewVideoUrlType) {
    CTVideoViewVideoUrlTypeRemote,
    CTVideoViewVideoUrlTypeNative,
    CTVideoViewVideoUrlTypeLiveStream
};

/**
 *  CTVideoViewContentMode: Just a wrapper of AVPlayerLayer.videoGravity for convenient
 */
typedef NS_ENUM(NSUInteger, CTVideoViewContentMode) {
    /**
     *  default, same as AVLayerVideoGravityResizeAspect
     */
    CTVideoViewContentModeResizeAspect,
    /**
     *  same as AVLayerVideoGravityResizeAspectFill
     */
    CTVideoViewContentModeResizeAspectFill,
    /**
     *  same as AVLayerVideoGravityResize
     */
    CTVideoViewContentModeResize,
};

/**
 *  CTVideoViewOperationButtonType
 */
typedef NS_ENUM(NSUInteger, CTVideoViewOperationButtonType) {
    CTVideoViewOperationButtonTypePlay,
    CTVideoViewOperationButtonTypePause,
    CTVideoViewOperationButtonTypeRetry
};


#endif /* CTVideoViewDefinitions_h */
