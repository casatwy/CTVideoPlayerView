//
//  CTVideoView+Download.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+Download.h"
#import "CTVideoView+OperationButtons.h"
#import <objc/runtime.h>
#import "CTVideoDownloadManager.h"
#import <HandyFrame/UIView+LayoutMethods.h>

/* ----------------- Public methods ----------------- */

NSString * const kCTVideoViewShouldDownloadWhenNotWifi = @"kCTVideoViewShouldDownloadWhenNotWifi";

static void * CTVideoViewDownloadPrivatePropertyDownloadDelegate;
static void * CTVideoViewDownloadPrivatePropertyDownloadView;

@implementation CTVideoView (Download)

@dynamic downloadDelegate;

#pragma mark - life cycle
- (void)initDownload
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivekCTVideoManagerWillDownloadVideoNotification:)
                                                 name:kCTVideoManagerWillDownloadVideoNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivekCTVideoManagerDownloadVideoProgressNotification:)
                                                 name:kCTVideoManagerDownloadVideoProgressNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivekCTVideoManagerDidFailedDownloadVideoNotification:)
                                                 name:kCTVideoManagerDidFailedDownloadVideoNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivekCTVideoManagerDidFinishDownloadVideoNotification:)
                                                 name:kCTVideoManagerDidFinishDownloadVideoNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivedkCTVideoManagerDidPausedDownloadVideoNotification:)
                                                 name:kCTVideoManagerDidPausedDownloadVideoNotification
                                               object:nil];
}

- (void)deallocDownload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.downloadDelegate = nil;
}

#pragma mark - public methods
- (void)startDownloadTask
{
    if (self.videoUrl && self.videoUrlType != CTVideoViewVideoUrlTypeNative) {
        [[CTVideoDownloadManager sharedInstance] startDownloadTaskWithUrl:self.videoUrl];
        if ([self.downloadDelegate respondsToSelector:@selector(videoViewIsWaitingForDownload:)]) {
            [self.downloadDelegate videoViewIsWaitingForDownload:self];
        }
    }
}

- (void)DeleteAndCancelDownloadTask
{
    if (self.videoUrl && self.videoUrlType != CTVideoViewVideoUrlTypeNative) {
        [[CTVideoDownloadManager sharedInstance] deleteVideoWithUrl:self.videoUrl];
        if ([self.downloadDelegate respondsToSelector:@selector(videoViewDidDeletedDownloadTask:)]) {
            [self.downloadDelegate videoViewDidDeletedDownloadTask:self];
        }
    }
}

- (void)pauseDownloadTask
{
    if (self.videoUrl && self.videoUrlType != CTVideoViewVideoUrlTypeNative) {
        WeakSelf;
        [[CTVideoDownloadManager sharedInstance] pauseDownloadTaskWithUrl:self.videoUrl completion:^{
            StrongSelf;
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(videoViewDidPausedDownload:)]) {
                [strongSelf.downloadDelegate videoViewDidPausedDownload:strongSelf];
            }
        }];
    }
}

#pragma mark - notifications
- (void)didReceivekCTVideoManagerWillDownloadVideoNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqual:self.videoUrl]) {
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.downloadingView respondsToSelector:@selector(videoViewStartDownload:)]) {
                [strongSelf addSubview:strongSelf.downloadingView];
                [strongSelf.downloadingView fill];
                [strongSelf.downloadingView videoViewStartDownload:strongSelf];
            }
            
            [strongSelf hidePlayButton];
            [strongSelf hideRetryButton];
            
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(videoViewWillStartDownload:)]) {
                [strongSelf.downloadDelegate videoViewWillStartDownload:strongSelf];
            }
        });
    }
}

- (void)didReceivekCTVideoManagerDidFinishDownloadVideoNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqual:self.videoUrl]) {
        
        [self refreshUrl];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.downloadingView respondsToSelector:@selector(videoViewFinishDownload:)]) {
                [strongSelf.downloadingView videoViewFinishDownload:strongSelf];
            }
            
            [strongSelf showPlayButton];
            
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(videoViewDidFinishDownload:)]) {
                [strongSelf.downloadDelegate videoViewDidFinishDownload:strongSelf];
            }
        });
    }
}

- (void)didReceivekCTVideoManagerDownloadVideoProgressNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqual:self.videoUrl]) {
        CGFloat progress = [notification.userInfo[kCTVideoManagerNotificationUserInfoKeyProgress] floatValue];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.downloadingView respondsToSelector:@selector(videoView:progress:)]) {
                [strongSelf.downloadingView videoView:strongSelf progress:progress];
            }
            
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(videoView:downloadProgress:)]) {
                [strongSelf.downloadDelegate videoView:strongSelf
                                      downloadProgress:progress];
            }
        });
        
        
    }
}

- (void)didReceivekCTVideoManagerDidFailedDownloadVideoNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqual:self.videoUrl]) {
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.downloadingView respondsToSelector:@selector(videoViewFailedDownload:)]) {
                [strongSelf.downloadingView videoViewFailedDownload:strongSelf];
            }
            
            [strongSelf showRetryButton];
            
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(videoViewDidFailDownload:)]) {
                [strongSelf.downloadDelegate videoViewDidFailDownload:strongSelf];
            }
        });
    }
}

- (void)didReceivedkCTVideoManagerDidPausedDownloadVideoNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqual:self.videoUrl]) {
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.downloadingView respondsToSelector:@selector(videoViewPauseDownload:)]) {
                [strongSelf.downloadingView videoViewPauseDownload:strongSelf];
            }
            
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(videoViewDidPausedDownload:)]) {
                [strongSelf.downloadDelegate videoViewDidPausedDownload:strongSelf];
            }
        });
    }
}

#pragma mark - getters and setters
- (BOOL)shouldDownloadWhenNotWifi
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCTVideoViewShouldDownloadWhenNotWifi];
}

- (id<CTVideoViewDownloadDelegate>)downloadDelegate
{
    return objc_getAssociatedObject(self, &CTVideoViewDownloadPrivatePropertyDownloadDelegate);
}

- (void)setDownloadDelegate:(id<CTVideoViewDownloadDelegate>)downloadDelegate
{
    objc_setAssociatedObject(self, &CTVideoViewDownloadPrivatePropertyDownloadDelegate, downloadDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView<CTVideoPlayerDownloadingViewProtocol> *)downloadingView
{
    return objc_getAssociatedObject(self, &CTVideoViewDownloadPrivatePropertyDownloadView);
}

- (void)setDownloadingView:(UIView<CTVideoPlayerDownloadingViewProtocol> *)downloadingView
{
    objc_setAssociatedObject(self, &CTVideoViewDownloadPrivatePropertyDownloadView, downloadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTimeoutIntervalForRequest:(NSTimeInterval)timeoutIntervalForRequest
{
    [CTVideoDownloadManager sharedInstance].timeoutIntervalForRequest = timeoutIntervalForRequest;
}

- (void)setTimeoutIntervalForResource:(NSTimeInterval)timeoutIntervalForResource
{
    [CTVideoDownloadManager sharedInstance].timeoutIntervalForResource = timeoutIntervalForResource;
}

@end
