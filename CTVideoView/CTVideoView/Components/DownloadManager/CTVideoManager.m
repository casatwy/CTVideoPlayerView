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
#import "CTVideoViewDefinitions.h"

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
@property (nonatomic, strong) NSMutableDictionary *downloadTaskPool;

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
    if (url == nil) {
        return;
    }
    
    CTVideoRecordStatus videoStatus = [self.dataCenter statusOfRemoteUrl:url];
    
    if (videoStatus == CTVideoRecordStatusDownloading || videoStatus == CTVideoRecordStatusWaitingForDownload) {
        // do nothing
    }
    
    if (videoStatus == CTVideoRecordStatusNative) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDidFinishDownloadVideoNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kCTVideoManagerNotificationUserInfoKeyProgress:@(1.0f),
                                                                     kCTVideoManagerNotificationUserInfoKeyNativeUrl:url,
                                                                     kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url
                                                                     }];
    }
    
    if (videoStatus == CTVideoRecordStatusDownloadFinished) {
        NSURL *nativeUrl = [self.dataCenter nativeUrlWithRemoteUrl:url];
        if (nativeUrl) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDidFinishDownloadVideoNotification
                                                                object:nil
                                                              userInfo:@{
                                                                         kCTVideoManagerNotificationUserInfoKeyProgress:@(1.0f),
                                                                         kCTVideoManagerNotificationUserInfoKeyNativeUrl:nativeUrl,
                                                                         kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url
                                                                         }];
        }
    }
    
    if (videoStatus == CTVideoRecordStatusDownloadFailed) {
        [self resumeDownloadWithUrl:url];
    }
    
    if (videoStatus == CTVideoRecordStatusNotFound) {
        [self downloadWithUrl:url];
    }
    
    if (completion) {
        completion();
    }
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

#pragma mark - private methods
- (void)resumeDownloadWithUrl:(NSURL *)url
{
    NSURL *nativeUrl = [self.dataCenter nativeUrlWithRemoteUrl:url];
    NSData *fileData = [NSData dataWithContentsOfURL:nativeUrl];
    WeakSelf;
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithResumeData:fileData
                                                                                    progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                                        StrongSelf;
                                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDownloadVideoProgressNotification
                                                                                                                                            object:nil
                                                                                                                                          userInfo:@{
                                                                                                                                                     kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url,
                                                                                                                                                     kCTVideoManagerNotificationUserInfoKeyNativeUrl:nativeUrl,
                                                                                                                                                     kCTVideoManagerNotificationUserInfoKeyProgress:@((CGFloat)downloadProgress.completedUnitCount / (CGFloat)downloadProgress.totalUnitCount)
                                                                                                                                                     }];
                                                                                        [strongSelf.dataCenter updateStatus:CTVideoRecordStatusDownloading toRemoteUrl:url];
                                                                                    }
                                                                                 destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                                     return nativeUrl;
                                                                                 }
                                                                           completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                               StrongSelf;
                                                                               [strongSelf.downloadTaskPool removeObjectForKey:url];
                                                                               NSString *notificationNameToPost = nil;
                                                                               if (error) {
                                                                                   notificationNameToPost = kCTVideoManagerDidFailedDownloadVideoNotification;
                                                                                   [strongSelf.dataCenter updateStatus:CTVideoRecordStatusDownloadFailed toRemoteUrl:url];
                                                                               } else {
                                                                                   notificationNameToPost = kCTVideoManagerDidFinishDownloadVideoNotification;
                                                                                   [strongSelf.dataCenter updateStatus:CTVideoRecordStatusDownloadFinished toRemoteUrl:url];
                                                                               }
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDidFailedDownloadVideoNotification
                                                                                                                                   object:nil
                                                                                                                                 userInfo:@{
                                                                                                                                            kCTVideoManagerNotificationUserInfoKeyNativeUrl:filePath,
                                                                                                                                            kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url
                                                                                                                                            }];
                                                                           }];
    [downloadTask resume];
    self.downloadTaskPool[url] = downloadTask;
    [self.dataCenter updateStatus:CTVideoRecordStatusWaitingForDownload toRemoteUrl:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerWillDownloadVideoNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url,
                                                                 kCTVideoManagerNotificationUserInfoKeyNativeUrl:nativeUrl
                                                                 }];
}

- (void)downloadWithUrl:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    WeakSelf;
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request
                                                                                 progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                                     StrongSelf;
                                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDownloadVideoProgressNotification
                                                                                                                                         object:nil
                                                                                                                                       userInfo:@{
                                                                                                                                                  kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url,
                                                                                                                                                  kCTVideoManagerNotificationUserInfoKeyProgress:@((CGFloat)downloadProgress.completedUnitCount / (CGFloat)downloadProgress.totalUnitCount)
                                                                                                                                                  }];
                                                                                     [strongSelf.dataCenter updateStatus:CTVideoRecordStatusDownloading toRemoteUrl:url];
                                                                                 }
                                                                              destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                                  StrongSelf;
                                                                                  NSURL *libraryUrl = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL];
                                                                                  NSURL *nativeUrl = [libraryUrl URLByAppendingPathComponent:response.suggestedFilename];
                                                                                  [strongSelf.dataCenter saveWithRemoteUrl:url nativeUrl:nativeUrl];
                                                                                  return nativeUrl;
                                                                              } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                                  StrongSelf;
                                                                                  [strongSelf.downloadTaskPool removeObjectForKey:url];
                                                                                  NSString *notificationNameToPost = nil;
                                                                                  if (error) {
                                                                                      notificationNameToPost = kCTVideoManagerDidFailedDownloadVideoNotification;
                                                                                      [strongSelf.dataCenter updateStatus:CTVideoRecordStatusDownloadFailed toRemoteUrl:url];
                                                                                  } else {
                                                                                      notificationNameToPost = kCTVideoManagerDidFinishDownloadVideoNotification;
                                                                                      [strongSelf.dataCenter updateStatus:CTVideoRecordStatusDownloadFinished toRemoteUrl:url];
                                                                                  }
                                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:notificationNameToPost
                                                                                                                                      object:nil
                                                                                                                                    userInfo:@{
                                                                                                                                               kCTVideoManagerNotificationUserInfoKeyNativeUrl:filePath,
                                                                                                                                               kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url
                                                                                                                                               }];
                                                                              }];
    [downloadTask resume];
    self.downloadTaskPool[url] = downloadTask;
    [self.dataCenter updateStatus:CTVideoRecordStatusWaitingForDownload toRemoteUrl:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerWillDownloadVideoNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url
                                                                 }];
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

- (NSMutableDictionary *)downloadTaskPool
{
    if (_downloadTaskPool == nil) {
        _downloadTaskPool = [[NSMutableDictionary alloc] init];
    }
    return _downloadTaskPool;
}

@end
