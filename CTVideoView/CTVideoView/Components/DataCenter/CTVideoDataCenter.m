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
    
    NSString *whereCondition = @"`remoteUrl` = ':remoteUrlString'";
    NSString *remoteUrlString = [remoteUrl absoluteString];
    NSDictionary *params = NSDictionaryOfVariableBindings(remoteUrlString);
    
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:NULL];
    if (videoRecord == nil) {
        return nil;
    }
    
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:videoRecord.nativeUrl];
    
    return [NSURL fileURLWithPath:filepath];
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
    
    CTVideoRecord *record = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:NULL];
    if (record) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:record.nativeUrl];
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:filePath] error:NULL];
        [self.videoTable deleteRecord:record error:NULL];
    }
}

- (void)deleteAllNotFinishedVideo
{
    NSString *whereCondition = [NSString stringWithFormat:@"`status` = '%lu' OR `status` = '%lu'", (unsigned long)CTVideoRecordStatusDownloading, (unsigned long)CTVideoRecordStatusDownloadFailed];
    NSArray *recordList = [self.videoTable findAllWithWhereCondition:whereCondition conditionParams:nil isDistinct:NO error:NULL];
    [self.videoTable deleteRecordList:recordList error:NULL];
}

- (BOOL)isDownloadingRemoteUrl:(NSURL *)remoteUrl
{
    NSString *whereCondition = @"`remoteUrl` = ':remoteUrlString'";
    NSString *remoteUrlString = [remoteUrl absoluteString];
    NSDictionary *params = NSDictionaryOfVariableBindings(remoteUrlString);
    CTVideoRecord *videoRecord = (CTVideoRecord *)[self.videoTable findFirstRowWithWhereCondition:whereCondition conditionParams:params isDistinct:NO error:NULL];
    if (videoRecord == nil) {
        return NO;
    } else {
        if ([videoRecord.status unsignedIntegerValue] == CTVideoRecordStatusDownloadFinished) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (void)insertRecordWithRemoteUrl:(NSURL *)remoteUrl status:(CTVideoRecordStatus)status
{
    if (![self isDownloadingRemoteUrl:remoteUrl]) {
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
