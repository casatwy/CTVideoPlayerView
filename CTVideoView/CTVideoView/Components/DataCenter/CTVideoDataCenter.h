//
//  CTVideoDataCenter.h
//  yili
//
//  Created by casa on 15/10/21.
//  Copyright © 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTVideoRecord.h"

@interface CTVideoDataCenter : NSObject

// create
- (void)insertRecordWithRemoteUrl:(NSURL *)remoteUrl status:(CTVideoRecordStatus)status;

// read
- (NSURL *)nativeUrlWithRemoteUrl:(NSURL *)remoteUrl;
- (NSArray <NSDictionary *> *)recordListWithStatus:(CTVideoRecordStatus)status;
- (CTVideoRecordStatus)statusOfRemoteUrl:(NSURL *)remoteUrl;

// update
- (void)saveWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl;

- (void)pauseAllRecordWithCompletion:(void(^)(NSArray *pausedList))completion;
- (void)pauseRecordWithRemoteUrlList:(NSArray *)remoteUrlList completion:(void(^)(NSArray *pausedList))completion;

- (void)startDownloadAllRecordWithCompletion:(void(^)(NSArray *startedList))completion;
- (void)startDownloadRemoteUrlList:(NSArray *)remoteUrlList completion:(void(^)(NSArray *startedList))completion;

// delete
- (void)deleteWithRemoteUrl:(NSURL *)remoteUrl;
- (void)deleteAllRecordWithCompletion:(void(^)(NSArray *deletedList))completion;
- (void)deleteAllNotFinishedVideo;


@end
