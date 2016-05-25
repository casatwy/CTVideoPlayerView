//
//  CTVideoDataCenter.h
//  yili
//
//  Created by casa on 15/10/21.
//  Copyright © 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTVideoRecord.h"

@interface CTVideoViewDataCenter : NSObject

// create
- (void)insertRecordWithRemoteUrl:(NSURL *)remoteUrl status:(CTVideoRecordStatus)status;

// read
- (NSURL *)nativeUrlWithRemoteUrl:(NSURL *)remoteUrl;
- (BOOL)isDownloadingRemoteUrl:(NSURL *)remoteUrl;

// update
- (void)saveWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl;

// delete
- (void)deleteWithRemoteUrl:(NSURL *)remoteUrl;
- (void)deleteAllRecordWithCompletion:(void(^)(void))completion;
- (void)deleteAllNotFinishedVideo;


@end
