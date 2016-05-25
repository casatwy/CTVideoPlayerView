//
//  CTVideoViewDownloadManager.m
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoManager.h"
#import "CTVideoDataCenter.h"
#import <AFNetworking/AFNetworking.h>

@interface CTVideoManager ()

@property (nonatomic, strong) CTVideoDataCenter *dataCenter;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;

@end

@implementation CTVideoManager

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static CTVideoManager *videoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoManager = [[CTVideoManager alloc] init];
    });
    return videoManager;
}

#pragma mark - public methods

#pragma mark - getters and setters
- (BOOL)isWifi
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

- (CTVideoDataCenter *)dataCenter
{
    if (_dataCenter == nil) {
        _dataCenter = [[CTVideoDataCenter alloc] init];
    }
    return _dataCenter;
}

- (AFURLSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _sessionManager;
}

@end
