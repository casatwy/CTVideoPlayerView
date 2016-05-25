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

/* ----------------- Private methods ----------------- */

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
    
}

- (void)deallocDownload
{
    
}

#pragma mark - public methods
- (void)startDownload
{
    if (self.videoUrl) {
        [[CTVideoManager sharedInstance] downloadVideoWithUrl:self.videoUrl];
    }
}

- (void)cancelDownload
{
    if (self.videoUrl) {
        [[CTVideoManager sharedInstance] cancelDownloadWithUrl:self.videoUrl];
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
