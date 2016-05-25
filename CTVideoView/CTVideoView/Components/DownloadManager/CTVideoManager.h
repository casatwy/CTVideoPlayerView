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

+ (instancetype)sharedInstance;
- (void)downloadVideoWithUrl:(NSURL *)url;
- (NSURL *)naticeUrlForRemoteUrl:(NSURL *)remoteUrl;
- (void)removeAllRecord:(void (^)(void))completion;

@end
