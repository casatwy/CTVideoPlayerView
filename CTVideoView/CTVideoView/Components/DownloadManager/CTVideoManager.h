//
//  CTVideoViewDownloadManager.h
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <Foundation/Foundation.h>

// notifications
extern NSString * const kCTVideoManagerWillDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidFinishDownloadVideoNotification;
extern NSString * const kCTVideoManagerDownloadVideoProgressNotification;
extern NSString * const kCTVideoManagerDidFailedDownloadVideoNotification;
extern NSString * const kCTVideoManagerDidPausedDownloadVideoNotification;

// notification userinfo keys
extern NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyNativeUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyProgress;

@interface CTVideoManager : NSObject

@property (nonatomic, assign, readonly) BOOL isWifi;
@property (nonatomic, assign) NSInteger maxConcurrentDownloadCount;

+ (instancetype)sharedInstance;

- (void)startDownloadTaskWithUrl:(NSURL *)url;
- (void)startAllDownloadTask;

- (void)deleteVideoWithUrl:(NSURL *)url;
- (void)deleteAllRecordAndVideo:(void (^)(NSArray *deletedList))completion;

- (void)pauseDownloadTaskWithUrl:(NSURL *)url completion:(void (^)(void))completion;
- (void)pauseAllDownloadTask;

- (NSURL *)nativeUrlForRemoteUrl:(NSURL *)remoteUrl;

@end
