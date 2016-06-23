//
//  CTVideoRecord.h
//  yili
//
//  Created by casa on 15/10/21.
//  Copyright © 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <CTPersistance/CTPersistance.h>

typedef NS_ENUM(NSUInteger, CTVideoRecordStatus) {
    // record status when downloading
    CTVideoRecordStatusDownloading = 0,
    CTVideoRecordStatusDownloadFinished = 1,
    CTVideoRecordStatusDownloadFailed = 2,
    CTVideoRecordStatusWaitingForDownload = 3,
    
    // record status when finding
    CTVideoRecordStatusNotFound = 4,
    CTVideoRecordStatusNative = 5,
    CTVideoRecordStatusPaused = 6,
};

@interface CTVideoRecord : CTPersistanceRecord

@property (nonatomic, copy) NSNumber *identifier;
@property (nonatomic, copy) NSString *remoteUrl;
@property (nonatomic, copy) NSString *nativeUrl;
@property (nonatomic, copy) NSNumber *status;
@property (nonatomic, copy) NSNumber *progress;

@end
