//
//  CTVideoDataCenter.h
//  yili
//
//  Created by casa on 15/10/21.
//  Copyright © 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTVideoRecord.h"

@interface CTVideoDataCenter : NSObject

// create
- (void)insertRecordWithRemoteUrl:(NSURL *)remoteUrl status:(CTVideoRecordStatus)status;

// read
- (NSURL *)nativeUrlWithRemoteUrl:(NSURL *)remoteUrl;
- (NSArray <id<CTPersistanceRecordProtocol>> *)recordListWithStatus:(CTVideoRecordStatus)status;
- (CTVideoRecordStatus)statusOfRemoteUrl:(NSURL *)remoteUrl;
- (id<CTPersistanceRecordProtocol>)recordOfRemoteUrl:(NSURL *)url;

// update native url
- (void)updateWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl;
- (void)updateWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl status:(CTVideoRecordStatus)status;

// update status
- (void)updateStatus:(CTVideoRecordStatus)status toRemoteUrl:(NSURL *)remoteUrl;
- (void)updateStatus:(CTVideoRecordStatus)status progress:(CGFloat)progress toRemoteUrl:(NSURL *)remoteUrl;
- (void)updateAllStatus:(CTVideoRecordStatus)status;

// pause download task
- (void)pauseAllRecordWithCompletion:(void(^)(void))completion;
- (void)pauseRecordWithRemoteUrlList:(NSArray *)remoteUrlList completion:(void(^)(void))completion;

// start download task
- (void)startDownloadAllRecordWithCompletion:(void(^)(void))completion;
- (void)startDownloadRemoteUrlList:(NSArray *)remoteUrlList completion:(void(^)(void))completion;

// delete
- (void)deleteWithRemoteUrl:(NSURL *)remoteUrl;
- (void)deleteAllRecordWithCompletion:(void(^)(NSArray *deletedList))completion;
- (void)deleteAllNotFinishedVideo;
- (void)deleteAllOldEntitiesAboveCount:(NSInteger)count;

@end
