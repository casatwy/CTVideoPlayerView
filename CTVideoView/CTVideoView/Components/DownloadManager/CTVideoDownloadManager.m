//
//  CTVideoViewDownloadManager.m
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoDownloadManager.h"
#import "CTVideoDataCenter.h"
#import <AFNetworking/AFNetworking.h>
#import "CTVideoViewDefinitions.h"

// notifications
NSString * const kCTVideoManagerWillDownloadVideoNotification = @"kCTVideoManagerWillDownloadVideoNotification";
NSString * const kCTVideoManagerDidFinishDownloadVideoNotification = @"kCTVideoManagerDidFinishDownloadVideoNotification";
NSString * const kCTVideoManagerDownloadVideoProgressNotification = @"kCTVideoManagerDownloadVideoProgressNotification";
NSString * const kCTVideoManagerDidFailedDownloadVideoNotification = @"kCTVideoManagerDidFailedDownloadVideoNotification";
NSString * const kCTVideoManagerDidPausedDownloadVideoNotification = @"kCTVideoManagerDidPausedDownloadVideoNotification";
NSString * const kCTVideoManagerDidDeletedDownloadVideoNotification = @"kCTVideoManagerDidDeletedDownloadVideoNotification";

// notification userinfo keys
NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrl = @"kCTVideoManagerNotificationUserInfoKeyRemoteUrl";
NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrlList = @"kCTVideoManagerNotificationUserInfoKeyRemoteUrlList";
NSString * const kCTVideoManagerNotificationUserInfoKeyNativeUrl = @"kCTVideoManagerNotificationUserInfoKeyNativeUrl";
NSString * const kCTVideoManagerNotificationUserInfoKeyProgress = @"kCTVideoManagerNotificationUserInfoKeyProgress";

@interface CTVideoDownloadManager ()

@property (nonatomic, strong) CTVideoDataCenter *dataCenter;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *downloadTaskPool;

@end

@implementation CTVideoDownloadManager

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static CTVideoDownloadManager *videoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoManager = [[CTVideoDownloadManager alloc] init];
        videoManager.timeoutIntervalForRequest = 10.0f;
        videoManager.timeoutIntervalForResource = 10.0f;
        videoManager.totalDownloadedFileCountLimit = 50;
        videoManager.maxConcurrentDownloadCount = 3;
    });
    return videoManager;
}

#pragma mark - public methods
- (void)startDownloadTaskWithUrl:(NSURL *)url
{
    if (url == nil) {
        return;
    }
    
    CTVideoRecordStatus videoStatus = [self.dataCenter statusOfRemoteUrl:url];
    
    if (videoStatus == CTVideoRecordStatusDownloading || videoStatus == CTVideoRecordStatusWaitingForDownload) {
        NSURLSessionDownloadTask *downloadTask = self.downloadTaskPool[url];
        if (downloadTask == nil) {
            videoStatus = CTVideoRecordStatusDownloadFailed;
            [self.dataCenter updateStatus:CTVideoRecordStatusDownloadFailed toRemoteUrl:url];
        }
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
        [self resumeDownloadWithUrl:url];
    }

    if (videoStatus == CTVideoRecordStatusPaused) {
        [self resumeDownloadWithUrl:url];
    }
}

- (void)startAllDownloadTask
{
    NSMutableArray *recordList = [[self.dataCenter recordListWithStatus:CTVideoRecordStatusPaused] mutableCopy];
    [recordList addObjectsFromArray:[self.dataCenter recordListWithStatus:CTVideoRecordStatusWaitingForDownload]];
    [recordList addObjectsFromArray:[self.dataCenter recordListWithStatus:CTVideoRecordStatusDownloadFailed]];

    [recordList enumerateObjectsUsingBlock:^(CTVideoRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *remoteUrl = [NSURL URLWithString:record.remoteUrl];
        if (remoteUrl) {
            NSURLSessionDownloadTask *task = self.downloadTaskPool[remoteUrl];
            if (task == nil) {
                [self resumeDownloadWithUrl:remoteUrl];
            }
        }
    }];
}

- (void)deleteVideoWithUrl:(NSURL *)url
{
    if (url == nil) {
        return;
    }

    NSURLSessionDownloadTask *task = self.downloadTaskPool[url];
    if (task) {
        [task cancel];
        [self.downloadTaskPool removeObjectForKey:url];
    }

    [self.dataCenter deleteWithRemoteUrl:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDidDeletedDownloadVideoNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url
                                                                 }];

}

- (void)deleteAllRecordAndVideo:(void (^)(NSArray *deletedList))completion
{
    [self.downloadTaskPool enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull remoteUrl, NSURLSessionDownloadTask * _Nonnull downloadTask, BOOL * _Nonnull stop) {
        [downloadTask cancel];
    }];
    [self.downloadTaskPool removeAllObjects];
    [self.dataCenter deleteAllRecordWithCompletion:completion];
}

- (void)pauseAllDownloadTask
{
    NSMutableArray *recordList = [[self.dataCenter recordListWithStatus:CTVideoRecordStatusPaused] mutableCopy];
    [recordList addObjectsFromArray:[self.dataCenter recordListWithStatus:CTVideoRecordStatusWaitingForDownload]];
    [recordList addObjectsFromArray:[self.dataCenter recordListWithStatus:CTVideoRecordStatusDownloadFailed]];
    [recordList addObjectsFromArray:[self.dataCenter recordListWithStatus:CTVideoRecordStatusDownloading]];
    [recordList enumerateObjectsUsingBlock:^(CTVideoRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.dataCenter updateStatus:CTVideoRecordStatusPaused toRemoteUrl:[NSURL URLWithString:record.remoteUrl]];
    }];

    [self.downloadTaskPool enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull remoteUrl, NSURLSessionDownloadTask * _Nonnull downloadTask, BOOL * _Nonnull stop) {
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (resumeData) {
                NSURL *nativeUrl = [self.dataCenter nativeUrlWithRemoteUrl:remoteUrl];
                NSURL *resumeUrl = [nativeUrl URLByAppendingPathExtension:@"resume"];
                [resumeData writeToURL:resumeUrl atomically:YES];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDidPausedDownloadVideoNotification
                                                                object:nil
                                                              userInfo:@{
                                                                         kCTVideoManagerNotificationUserInfoKeyRemoteUrl:remoteUrl,
                                                                         kCTVideoManagerNotificationUserInfoKeyProgress:@((CGFloat)downloadTask.countOfBytesReceived / (CGFloat)downloadTask.countOfBytesExpectedToReceive)
                                                                         }];
        }];
    }];
    [self.downloadTaskPool removeAllObjects];
}

- (void)pauseDownloadTaskWithUrl:(NSURL *)url completion:(void (^)(void))completion
{
    [self.dataCenter updateStatus:CTVideoRecordStatusPaused toRemoteUrl:url];
    NSURLSessionDownloadTask *downloadTask = self.downloadTaskPool[url];
    if (downloadTask) {
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (resumeData) {
                NSURL *nativeUrl = [self.dataCenter nativeUrlWithRemoteUrl:url];
                NSURL *resumeUrl = [nativeUrl URLByAppendingPathExtension:@"resume"];
                [resumeData writeToURL:resumeUrl atomically:YES];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDidPausedDownloadVideoNotification
                                                                object:nil
                                                              userInfo:@{
                                                                         kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url,
                                                                         kCTVideoManagerNotificationUserInfoKeyProgress:@((CGFloat)downloadTask.countOfBytesReceived / (CGFloat)downloadTask.countOfBytesExpectedToReceive)
                                                                         }];
            if (completion) {
                completion();
            }
        }];

    }
    [self.downloadTaskPool removeObjectForKey:url];
}

- (NSURL *)nativeUrlForRemoteUrl:(NSURL *)remoteUrl
{
    return [self.dataCenter nativeUrlWithRemoteUrl:remoteUrl];
}

#pragma mark - private methods
- (void)resumeDownloadWithUrl:(NSURL *)url
{
    if (self.downloadStrategy == CTVideoViewDownloadStrategyNoDownload) {
        return;
    }

    NSURL *nativeUrl = [self.dataCenter nativeUrlWithRemoteUrl:url];
    NSURL *resumeUrl = [nativeUrl URLByAppendingPathExtension:@"resume"];
    NSData *fileData = [NSData dataWithContentsOfURL:resumeUrl];
    if (fileData == nil) {
        [self downloadWithUrl:url];
        return;
    } else {
        [[NSFileManager defaultManager] removeItemAtURL:resumeUrl error:NULL];
    }
    WeakSelf;
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithResumeData:fileData
                                                                                    progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                                        StrongSelf;
                                                                                        [strongSelf handleProgress:downloadProgress url:url nativeUrl:nativeUrl];
                                                                                    }
                                                                                 destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                                     return nativeUrl;
                                                                                 }
                                                                           completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                               StrongSelf;
                                                                               [strongSelf handleCompletionWithUrl:url response:response filePath:filePath error:error];
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
    if (self.downloadStrategy == CTVideoViewDownloadStrategyNoDownload) {
        return;
    }

    NSURL *nativeUrl = [self.dataCenter nativeUrlWithRemoteUrl:url];
    if (nativeUrl == nil) {
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
        nativeUrl = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName]];
    }
    [self.dataCenter updateWithRemoteUrl:url nativeUrl:nativeUrl status:CTVideoRecordStatusWaitingForDownload];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    WeakSelf;
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request
                                                                                 progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                                     StrongSelf;
                                                                                     [strongSelf handleProgress:downloadProgress url:url nativeUrl:nativeUrl];
                                                                                 }
                                                                              destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                                  return nativeUrl;
                                                                              }
                                                                        completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                            StrongSelf;
                                                                            [strongSelf handleCompletionWithUrl:url response:response filePath:filePath error:error];
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

#pragma mark - private methods
- (void)handleCompletionWithUrl:(NSURL *)url response:(NSURLResponse *)response filePath:(NSURL *)filePath error:(NSError *)error
{
    NSString *notificationNameToPost = nil;
    [self.downloadTaskPool removeObjectForKey:url];

    if (error || filePath == nil) {
        notificationNameToPost = kCTVideoManagerDidFailedDownloadVideoNotification;
        [self.dataCenter updateStatus:CTVideoRecordStatusDownloadFailed toRemoteUrl:url];
    } else {
        notificationNameToPost = kCTVideoManagerDidFinishDownloadVideoNotification;
        [self.dataCenter updateStatus:CTVideoRecordStatusDownloadFinished toRemoteUrl:url];
    }

    [self.dataCenter deleteAllOldEntitiesAboveCount:self.totalDownloadedFileCountLimit];

    NSMutableDictionary *userinfo = [[NSMutableDictionary alloc] init];
    userinfo[kCTVideoManagerNotificationUserInfoKeyNativeUrl] = filePath;
    userinfo[kCTVideoManagerNotificationUserInfoKeyRemoteUrl] = url;
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationNameToPost
                                                        object:nil
                                                      userInfo:userinfo];
}

- (void)handleProgress:(NSProgress *)downloadProgress url:(NSURL *)url nativeUrl:(NSURL *)nativeUrl
{
    CGFloat progress = (CGFloat)downloadProgress.completedUnitCount / (CGFloat)downloadProgress.totalUnitCount;
    if (progress <= 1.0f) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDownloadVideoProgressNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kCTVideoManagerNotificationUserInfoKeyRemoteUrl:url,
                                                                     kCTVideoManagerNotificationUserInfoKeyNativeUrl:nativeUrl,
                                                                     kCTVideoManagerNotificationUserInfoKeyProgress:@(progress)
                                                                     }];
    }
    [self.dataCenter updateStatus:CTVideoRecordStatusDownloading toRemoteUrl:url];
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

- (void)setDownloadStrategy:(CTVideoViewDownloadStrategy)downloadStrategy
{
    _downloadStrategy = downloadStrategy;
    self.sessionManager = nil;
}

- (AFURLSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        if (self.downloadStrategy == CTVideoViewDownloadStrategyNoDownload) {
            return nil;
        }
        if (self.downloadStrategy == CTVideoViewDownloadStrategyDownloadOnlyForeground) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.timeoutIntervalForRequest = self.timeoutIntervalForRequest;
            configuration.timeoutIntervalForResource = self.timeoutIntervalForResource;
            _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        }
        if (self.downloadStrategy == CTVideoViewDownloadStrategyDownloadForegroundAndBackground) {
            NSString *identifier = [NSString stringWithFormat:@"CTVideoDownloadTask - %@", [NSUUID UUID].UUIDString];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
            configuration.sessionSendsLaunchEvents = YES;
            configuration.discretionary = YES;
            configuration.timeoutIntervalForRequest = self.timeoutIntervalForRequest;
            configuration.timeoutIntervalForResource = self.timeoutIntervalForResource;
            _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        }
    }
    return _sessionManager;
}

- (void)setTimeoutIntervalForResource:(NSTimeInterval)timeoutIntervalForResource
{
    _timeoutIntervalForResource = timeoutIntervalForResource;
    self.sessionManager = nil;
}

- (void)setTimeoutIntervalForRequest:(NSTimeInterval)timeoutIntervalForRequest
{
    _timeoutIntervalForRequest = timeoutIntervalForRequest;
    self.sessionManager = nil;
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
