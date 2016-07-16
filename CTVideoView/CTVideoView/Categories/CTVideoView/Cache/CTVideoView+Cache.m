//
//  CTVideoView+Cache.m
//  CTVideoView
//
//  Created by casa on 16/7/17.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+Cache.h"
#import "CTVideoView+Download.h"
#import <objc/runtime.h>

static void * CTVideoViewCachePrivatePropertyResourceLoader;

@implementation CTVideoView (Cache)

#pragma mark - public methods
- (void)cacheAndPlay
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.videoUrl resolvingAgainstBaseURL:YES];
    components.scheme = [NSUUID UUID].UUIDString;
    AVURLAsset *URLAsset = [AVURLAsset assetWithURL:components.URL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:URLAsset];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    self.resourceLoader = URLAsset.resourceLoader;
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    return YES;
}

#pragma mark - getters and setters
- (AVAssetResourceLoader *)resourceLoader
{
    return objc_getAssociatedObject(self, &CTVideoViewCachePrivatePropertyResourceLoader);
}

- (void)setResourceLoader:(AVAssetResourceLoader *)resourceLoader
{
    [resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    objc_setAssociatedObject(self, &CTVideoViewCachePrivatePropertyResourceLoader, resourceLoader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
