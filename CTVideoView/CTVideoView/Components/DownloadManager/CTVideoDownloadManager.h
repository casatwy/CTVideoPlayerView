//
//  CTVideoViewDownloadManager.h
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTVideoViewDefinitions.h"

// notifications
extern NSString * const kCTVideoManagerWillDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidFinishDownloadVideoNotification;
extern NSString * const kCTVideoManagerDownloadVideoProgressNotification;
extern NSString * const kCTVideoManagerDidFailedDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidPausedDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidDeletedDownloadVideoNotification;

// notification userinfo keys
extern NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrlList;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyNativeUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyProgress;

@interface CTVideoDownloadManager : NSObject

@property (nonatomic, assign, readonly) BOOL isWifi;
@property (nonatomic, assign) NSInteger maxConcurrentDownloadCount;
@property (nonatomic, assign) CTVideoViewDownloadStrategy downloadStrategy;
@property (nonatomic, assign) NSUInteger totalDownloadedFileCountLimit;

/* default timeout for requests.  This will cause a timeout if no data is transmitted for the given timeout value, and is reset whenever data is transmitted. */
@property (nonatomic, assign) NSTimeInterval timeoutIntervalForRequest;
/* default timeout for requests.  This will cause a timeout if a resource is not able to be retrieved within a given timeout. */
@property (nonatomic, assign) NSTimeInterval timeoutIntervalForResource;

+ (instancetype)sharedInstance;

- (void)startDownloadTaskWithUrl:(NSURL *)url;
- (void)startAllDownloadTask;

- (void)deleteVideoWithUrl:(NSURL *)url;
- (void)deleteAllRecordAndVideo:(void (^)(NSArray *deletedList))completion;

- (void)pauseDownloadTaskWithUrl:(NSURL *)url completion:(void (^)(void))completion;
- (void)pauseAllDownloadTask;

- (NSURL *)nativeUrlForRemoteUrl:(NSURL *)remoteUrl; // this native url is read from database, that means the file may not exists. The file exists physically only after video download finished, and this native url is designed to indicate where to save the downloaded video file. So, you should check whether it is exists in file system before you use the file.

@end
