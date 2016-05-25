//
//  CTVideoView+Download.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+Download.h"
#import <objc/runtime.h>
#import "CTVideoManager.h"

/* ----------------- Public methods ----------------- */

NSString * const kCTVideoViewShouldDownloadWhenNotWifi = @"kCTVideoViewShouldDownloadWhenNotWifi";

static void * CTVideoViewDownloadPrivatePropertyDownloadStrategy;
static void * CTVideoViewDownloadPrivatePropertyDownloadDelegate;

@implementation CTVideoView (Download)

@dynamic downloadStrategy;
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
}

- (void)deallocDownload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public methods
- (void)startDownload
{
    if (self.videoUrl) {
        [[CTVideoManager sharedInstance] startDownloadTaskWithUrl:self.videoUrl completion:nil];
    }
}

- (void)cancelDownload
{
    if (self.videoUrl) {
        [[CTVideoManager sharedInstance] startDownloadTaskWithUrl:self.videoUrl completion:nil];
    }
}

#pragma mark - notifications
- (void)didReceivekCTVideoManagerWillDownloadVideoNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqualToString:self.videoUrl.absoluteString]) {
        if ([self.downloadDelegate respondsToSelector:@selector(videoViewWillStartDownload:)]) {
            [self.downloadDelegate videoViewWillStartDownload:self];
        }
    }
}

- (void)didReceivekCTVideoManagerDidFinishDownloadVideoNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqualToString:self.videoUrl.absoluteString]) {
        if ([self.downloadDelegate respondsToSelector:@selector(videoViewDidFinishDownload:)]) {
            [self.downloadDelegate videoViewDidFinishDownload:self];
        }
    }
}

- (void)didReceivekCTVideoManagerDownloadVideoProgressNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqualToString:self.videoUrl.absoluteString]) {
        if ([self.downloadDelegate respondsToSelector:@selector(videoView:downloadProgress:)]) {
            [self.downloadDelegate videoView:self
                            downloadProgress:[notification.userInfo[kCTVideoManagerNotificationUserInfoKeyProgress] floatValue]];
        }
    }
}

- (void)didReceivekCTVideoManagerDidFailedDownloadVideoNotification:(NSNotification *)notification
{
    if ([notification.userInfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] isEqualToString:self.videoUrl.absoluteString]) {
        if ([self.downloadDelegate respondsToSelector:@selector(videoViewDidFailDownload:)]) {
            [self.downloadDelegate videoViewDidFailDownload:self];
        }
    }
}

#pragma mark - getters and setters
- (CTVideoViewDownloadStrategy)downloadStrategy
{
    return [objc_getAssociatedObject(self, &CTVideoViewDownloadPrivatePropertyDownloadStrategy) unsignedIntegerValue];
}

- (void)setDownloadStrategy:(CTVideoViewDownloadStrategy)downloadStrategy
{
    objc_setAssociatedObject(self, &CTVideoViewDownloadPrivatePropertyDownloadStrategy, @(downloadStrategy), OBJC_ASSOCIATION_ASSIGN);
}

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

@end
