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

// notifications
NSString * const kCTVideoManagerWillDownloadVideoNotification = @"kCTVideoManagerWillDownloadVideoNotification";
NSString * const kCTVideoManagerDidFinishDownloadVideoNotification = @"kCTVideoManagerDidFinishDownloadVideoNotification";
NSString * const kCTVideoManagerDownloadVideoProgressNotification = @"kCTVideoManagerDownloadVideoProgressNotification";
NSString * const kCTVideoManagerDidFailedDownloadVideoNotification = @"kCTVideoManagerDidFailedDownloadVideoNotification";

// notification userinfo keys
NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrl = @"kCTVideoManagerNotificationUserInfoKeyRemoteUrl";
NSString * const kCTVideoManagerNotificationUserInfoKeyNativeUrl = @"kCTVideoManagerNotificationUserInfoKeyNativeUrl";
NSString * const kCTVideoManagerNotificationUserInfoKeyProgress = @"kCTVideoManagerNotificationUserInfoKeyProgress";

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
        videoManager.maxConcurrentDownloadCount = 3;
    });
    return videoManager;
}

#pragma mark - public methods
- (void)startDownloadTaskWithUrl:(NSURL *)url completion:(void (^)(void))completion
{

}

- (void)startAllDownloadTask:(void (^)(void))completion
{

}

- (void)deleteVideoWithUrl:(NSURL *)url completion:(void (^)(void))completion
{
}

- (void)deleteAllRecordAndVideo:(void (^)(void))completion
{

}

- (void)pauseAllDownloadTask:(void (^)(void))completion
{

}

- (void)pauseDownloadTaskWithUrl:(NSURL *)url completion:(void (^)(void))completion
{
    
}

- (NSURL *)nativeUrlForRemoteUrl:(NSURL *)remoteUrl
{
    return [self.dataCenter nativeUrlWithRemoteUrl:remoteUrl];
}

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

- (void)setMaxConcurrentDownloadCount:(NSInteger)maxConcurrentDownloadCount
{
    self.sessionManager.operationQueue.maxConcurrentOperationCount = maxConcurrentDownloadCount;
}

- (NSInteger)maxConcurrentDownloadCount
{
    return self.sessionManager.operationQueue.maxConcurrentOperationCount;
}

@end
