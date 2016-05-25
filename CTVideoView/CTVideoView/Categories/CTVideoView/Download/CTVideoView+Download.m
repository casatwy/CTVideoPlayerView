//
//  CTVideoView+Download.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+Download.h"
#import <objc/runtime.h>

/* ----------------- Private methods ----------------- */

/* ----------------- Public methods ----------------- */

NSString * const kCTVideoViewShouldDownloadWhenNotWifi = @"kCTVideoViewShouldDownloadWhenNotWifi";

static void * CTVideoViewDownloadPrivatePropertyDownloadStrategy;

@implementation CTVideoView (Download)

@dynamic downloadStrategy;

#pragma mark - life cycle
- (void)initDownload
{
    
}

- (void)deallocDownload
{
    
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

@end
