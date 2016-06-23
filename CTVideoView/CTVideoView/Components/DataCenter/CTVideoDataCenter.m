//
//  CTVideoDataCenter.m
//  yili
//
//  Created by casa on 15/10/21.
//  Copyright © 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "CTVideoDataCenter.h"
#import "CTVideoRecord.h"
#import "CTVideoTable.h"
#import <UIKit/UIKit.h>
#import "CTVideoViewDefinitions.h"

@interface CTVideoDataCenter ()

@property (nonatomic, strong) CTVideoTable *videoTable;

@end

@implementation CTVideoDataCenter

#pragma mark - create
- (void)insertRecordWithRemoteUrl:(NSURL *)remoteUrl status:(CTVideoRecordStatus)status
{
    if ([self statusOfRemoteUrl:remoteUrl] == CTVideoRecordStatusNotFound) {
        CTVideoRecord *videoRecord = [[CTVideoRecord alloc] init];
        videoRecord.remoteUrl = [remoteUrl absoluteString];
        videoRecord.status = @(CTVideoRecordStatusDownloading);
        [self.videoTable insertRecord:videoRecord error:NULL];
    }
}

#pragma mark - read
- (NSURL *)nativeUrlWithRemoteUrl:(NSURL *)remoteUrl
{
    if (remoteUrl == nil) {
        return nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[remoteUrl path]]) {
        return remoteUrl;
    }
    
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self recordOfRemoteUrl:remoteUrl];
    if (videoRecord == nil) {
        return nil;
    }
    
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:videoRecord.nativeUrl];
    return [NSURL fileURLWithPath:filepath];
}

- (NSArray<id<CTPersistanceRecordProtocol>> *)recordListWithStatus:(CTVideoRecordStatus)status
{
    return [self.videoTable findAllWithKeyName:@"status" value:@(status) error:NULL];
}

- (CTVideoRecordStatus)statusOfRemoteUrl:(NSURL *)remoteUrl
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[remoteUrl path]]) {
        return CTVideoRecordStatusNative;
    }
    
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self recordOfRemoteUrl:remoteUrl];
    if (videoRecord == nil) {
        return CTVideoRecordStatusNotFound;
    }
    return [videoRecord.status unsignedIntegerValue];
}

- (id<CTPersistanceRecordProtocol>)recordOfRemoteUrl:(NSURL *)url
{
    NSString *whereCondition = @"`remoteUrl` = ':remoteUrlString'";
    NSString *remoteUrlString = [url absoluteString];
    NSDictionary *params = NSDictionaryOfVariableBindings(remoteUrlString);
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:NULL];
    return videoRecord;
}

#pragma mark - update url
- (void)updateWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl
{
    [self updateWithRemoteUrl:remoteUrl nativeUrl:nativeUrl status:CTVideoRecordStatusDownloading];
}

- (void)updateWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl status:(CTVideoRecordStatus)status
{
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self recordOfRemoteUrl:remoteUrl];
    
    if (videoRecord) {
        videoRecord.nativeUrl = [nativeUrl lastPathComponent];
        videoRecord.status = @(status);
        [self.videoTable updateRecord:videoRecord error:NULL];
    } else {
        videoRecord = [[CTVideoRecord alloc] init];
        videoRecord.remoteUrl = [remoteUrl absoluteString];
        videoRecord.nativeUrl = [nativeUrl lastPathComponent];
        videoRecord.status = @(status);
        [self.videoTable insertRecord:videoRecord error:NULL];
    }
}

#pragma mark - update status
- (void)updateStatus:(CTVideoRecordStatus)status toRemoteUrl:(NSURL *)remoteUrl
{
    CTVideoRecord *record = (CTVideoRecord *)[self recordOfRemoteUrl:remoteUrl];
    if (record) {
        record.status = @(status);
        [self.videoTable updateRecord:record error:NULL];
    } else {
        record = [[CTVideoRecord alloc] init];
        record.status = @(status);
        record.remoteUrl = [remoteUrl absoluteString];
        [self.videoTable insertRecord:record error:NULL];
    }
}

- (void)updateStatus:(CTVideoRecordStatus)status progress:(CGFloat)progress toRemoteUrl:(NSURL *)remoteUrl
{
    CTVideoRecord *record = (CTVideoRecord *)[self recordOfRemoteUrl:remoteUrl];
    if (record) {
        record.status = @(status);
        record.progress = @(progress);
        [self.videoTable updateRecord:record error:NULL];
    } else {
        record = [[CTVideoRecord alloc] init];
        record.status = @(status);
        record.progress = @(progress);
        record.remoteUrl = [remoteUrl absoluteString];
        [self.videoTable insertRecord:record error:NULL];
    }
}

- (void)updateAllStatus:(CTVideoRecordStatus)status
{
    [self.videoTable updateValue:@(status) forKey:@"status" whereCondition:nil whereConditionParams:nil error:NULL];
}

#pragma mark - pause download task
- (void)pauseAllRecordWithCompletion:(void (^)(void))completion
{
    [self updateAllStatus:CTVideoRecordStatusPaused];
    if (completion) {
        completion();
    }
}

- (void)pauseRecordWithRemoteUrlList:(NSArray *)remoteUrlList completion:(void (^)(void))completion
{
    [self.videoTable updateValue:@(CTVideoRecordStatusPaused) forKey:@"status" whereKey:@"remoteUrl" inList:remoteUrlList error:NULL];
    if (completion) {
        completion();
    }
}

#pragma mark - start download task
- (void)startDownloadAllRecordWithCompletion:(void (^)(void))completion
{
    [self updateAllStatus:CTVideoRecordStatusWaitingForDownload];
    if (completion) {
        completion();
    }
}

- (void)startDownloadRemoteUrlList:(NSArray *)remoteUrlList completion:(void (^)(void))completion
{
    [self.videoTable updateValue:@(CTVideoRecordStatusWaitingForDownload) forKey:@"status" whereKey:@"remoteUrl" inList:remoteUrlList error:NULL];
    if (completion) {
        completion();
    }
}

#pragma mark - delete
- (void)deleteWithRemoteUrl:(NSURL *)remoteUrl
{
    CTVideoRecord *record = (CTVideoRecord *)[self recordOfRemoteUrl:remoteUrl];
    if (record) {
        NSError *error;
        [self.videoTable deleteRecord:record error:&error];
        if (error) {
            return;
        }

        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:record.nativeUrl];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:filePath] error:&error];
            if (error) {
                return;
            }
        }
    }
}

- (void)deleteAllRecordWithCompletion:(void (^)(NSArray *))completion
{
    NSArray <NSObject <CTPersistanceRecordProtocol> *> *videoRecord = [self.videoTable findAllWithWhereCondition:@"identifier > 0" conditionParams:nil isDistinct:NO error:NULL];
    [self.videoTable deleteWithWhereCondition:@"identifier > 0" conditionParams:nil error:NULL];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *recordList = [[NSMutableArray alloc] init];
        [videoRecord enumerateObjectsUsingBlock:^(NSObject<CTPersistanceRecordProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[CTVideoRecord class]]) {
                CTVideoRecord *videoItem = (CTVideoRecord *)obj;
                NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:videoItem.nativeUrl];
                [[NSFileManager defaultManager] removeItemAtPath:videoPath error:NULL];
                [recordList addObject:[videoItem dictionaryRepresentationWithTable:self.videoTable]];
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCTVideoManagerDidDeletedDownloadVideoNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kCTVideoManagerNotificationUserInfoKeyRemoteUrlList:recordList
                                                                     }];
        if (completion) {
            completion(recordList);
        }
    });
}

- (void)deleteAllNotFinishedVideo
{
    NSString *whereCondition = [NSString stringWithFormat:@"`status` = '%lu' OR `status` = '%lu'", (unsigned long)CTVideoRecordStatusDownloading, (unsigned long)CTVideoRecordStatusDownloadFailed];
    NSArray *recordList = [self.videoTable findAllWithWhereCondition:whereCondition conditionParams:nil isDistinct:NO error:NULL];
    [self.videoTable deleteRecordList:recordList error:NULL];
    [recordList enumerateObjectsUsingBlock:^(CTVideoRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CTVideoRecord class]]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:obj.nativeUrl]) {
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:obj.nativeUrl] error:NULL];
            }
        }
    }];
}

- (void)deleteAllOldEntitiesAboveCount:(NSInteger)count
{
    NSString *whereCondition = [NSString stringWithFormat:@"`status` = '%lu'", (unsigned long)CTVideoRecordStatusDownloadFinished];
    NSArray <CTVideoRecord *> *result = (NSArray <CTVideoRecord *> *)[self.videoTable findAllWithWhereCondition:whereCondition conditionParams:nil isDistinct:NO error:NULL];
    NSInteger gapCount = result.count - count;
    if (gapCount > 0) {
        NSMutableArray *remoteURLList = [[NSMutableArray alloc] init];
        while (gapCount --> 0) {
            [remoteURLList addObject:[NSURL URLWithString:result[gapCount].remoteUrl]];
        }
        for (NSURL *urlToDelete in remoteURLList) {
            [self deleteWithRemoteUrl:urlToDelete];
        }
    }
}

#pragma mark - getters and setters
- (CTVideoTable *)videoTable
{
    if (_videoTable == nil) {
        _videoTable = [[CTVideoTable alloc] init];
    }
    return _videoTable;
}

@end
