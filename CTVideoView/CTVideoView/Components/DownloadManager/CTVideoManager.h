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

// notification userinfo keys
extern NSString * const kCTVideoManagerNotificationUserInfoKeyRemoteUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyNativeUrl;
extern NSString * const kCTVideoManagerNotificationUserInfoKeyProgress;

@interface CTVideoManager : NSObject

@property (nonatomic, assign, readonly) BOOL isWifi;
@property (nonatomic, assign) NSInteger maxConcurrentDownloadCount;

+ (instancetype)sharedInstance;

- (void)startDownloadTaskWithUrl:(NSURL *)url completion:(void (^)(void))completion;
- (void)startAllDownloadTask:(void (^)(void))completion;

- (void)deleteVideoWithUrl:(NSURL *)url completion:(void (^)(void))completion;
- (void)deleteAllRecordAndVideo:(void (^)(void))completion;

- (void)pauseDownloadTaskWithUrl:(NSURL *)url completion:(void (^)(void))completion;
- (void)pauseAllDownloadTask:(void (^)(void))completion;

- (NSURL *)nativeUrlForRemoteUrl:(NSURL *)remoteUrl;

@end
