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

@interface CTVideoDataCenter ()

@property (nonatomic, strong) CTVideoTable *videoTable;

@end

@implementation CTVideoDataCenter

#pragma mark - public methods
- (NSArray<NSDictionary *> *)recordListWithStatus:(CTVideoRecordStatus)status
{
#warning todo
    return @[];
}

- (NSURL *)nativeUrlWithRemoteUrl:(NSURL *)remoteUrl
{
    if (remoteUrl == nil) {
        return nil;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:[remoteUrl path]]) {
        return remoteUrl;
    }
    
    NSString *whereCondition = @"`remoteUrl` = ':remoteUrlString'";
    NSString *remoteUrlString = [remoteUrl absoluteString];
    NSDictionary *params = NSDictionaryOfVariableBindings(remoteUrlString);
    
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:NULL];
    if (videoRecord == nil) {
        return nil;
    }
    
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:videoRecord.nativeUrl];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        return [NSURL fileURLWithPath:filepath];
    } else {
        [self deleteWithRemoteUrl:remoteUrl];
        return nil;
    }
    
}

- (void)saveWithRemoteUrl:(NSURL *)remoteUrl nativeUrl:(NSURL *)nativeUrl
{
    NSString *whereCondition = @"`remoteUrl` = ':remoteUrlString'";
    NSString *remoteUrlString = [remoteUrl absoluteString];
    NSDictionary *params = NSDictionaryOfVariableBindings(remoteUrlString);
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:NULL];
    
    if (videoRecord) {
        videoRecord.nativeUrl = [[nativeUrl absoluteString] lastPathComponent];
        videoRecord.status = @(CTVideoRecordStatusDownloadFinished);
        [self.videoTable updateRecord:videoRecord error:NULL];
    } else {
        videoRecord = [[CTVideoRecord alloc] init];
        videoRecord.remoteUrl = [remoteUrl absoluteString];
        videoRecord.nativeUrl = [[nativeUrl path] lastPathComponent];
        videoRecord.status = @(CTVideoRecordStatusDownloadFinished);
        [self.videoTable insertRecord:videoRecord error:NULL];
    }
}

- (void)deleteWithRemoteUrl:(NSURL *)remoteUrl
{
    NSString *whereCondition = @"`remoteUrl` = ':remoteUrlString'";
    NSString *remoteUrlString = [remoteUrl absoluteString];
    NSDictionary *params = NSDictionaryOfVariableBindings(remoteUrlString);

    NSError *error;
    CTVideoRecord *record = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:&error];
    if (error) {
        return;
    }

    if (record) {
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

- (void)deleteAllNotFinishedVideo
{
    NSString *whereCondition = [NSString stringWithFormat:@"`status` = '%lu' OR `status` = '%lu'", (unsigned long)CTVideoRecordStatusDownloading, (unsigned long)CTVideoRecordStatusDownloadFailed];
    NSArray *recordList = [self.videoTable findAllWithWhereCondition:whereCondition conditionParams:nil isDistinct:NO error:NULL];
    [self.videoTable deleteRecordList:recordList error:NULL];
}

- (CTVideoRecordStatus)statusOfRemoteUrl:(NSURL *)remoteUrl
{
    NSString *whereCondition = @"`remoteUrl` = ':remoteUrlString'";
    NSString *remoteUrlString = [remoteUrl absoluteString];
    NSDictionary *params = NSDictionaryOfVariableBindings(remoteUrlString);
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:NULL];
    if (videoRecord == nil) {
        return CTVideoRecordStatusNotFound;
    }
    return [videoRecord.status unsignedIntegerValue];
}

- (void)insertRecordWithRemoteUrl:(NSURL *)remoteUrl status:(CTVideoRecordStatus)status
{
    if ([self statusOfRemoteUrl:remoteUrl] == CTVideoRecordStatusNotFound) {
        CTVideoRecord *videoRecord = [[CTVideoRecord alloc] init];
        videoRecord.remoteUrl = [remoteUrl absoluteString];
        videoRecord.status = @(CTVideoRecordStatusDownloading);
        [self.videoTable insertRecord:videoRecord error:NULL];
    }
}

- (void)deleteAllRecordWithCompletion:(void (^)(void))completion
{
    NSArray <NSObject <CTPersistanceRecordProtocol> *> *videoRecord = [self.videoTable findAllWithWhereCondition:@"identifier > 0" conditionParams:nil isDistinct:NO error:NULL];
    [self.videoTable deleteWithWhereCondition:@"identifier > 0" conditionParams:nil error:NULL];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [videoRecord enumerateObjectsUsingBlock:^(NSObject<CTPersistanceRecordProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[CTVideoRecord class]]) {
                CTVideoRecord *videoItem = (CTVideoRecord *)obj;
                NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:videoItem.nativeUrl];
                [[NSFileManager defaultManager] removeItemAtPath:videoPath error:NULL];
            }
        }];
        if (completion) {
            completion();
        }
    });
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
