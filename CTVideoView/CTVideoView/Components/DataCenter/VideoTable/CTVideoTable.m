//
//  CTVideoTable.m
//  yili
//
//  Created by casa on 15/10/21.
//  Copyright © 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "CTVideoTable.h"
#import "CTVideoRecord.h"

@implementation CTVideoTable

#pragma mark - CTPersistanceTableProtocol
- (NSString *)databaseName
{
    return @"CTVideoDataCenterList.sqlite";
}

- (NSString *)tableName
{
    return @"CTVideoTable";
}

- (NSDictionary *)columnInfo
{
    return @{
             @"identifier":@"INTEGER PRIMARY KEY AUTOINCREMENT",
             @"remoteUrl":@"TEXT",
             @"nativeUrl":@"TEXT",
             @"status":@"INTEGER",
             @"progress":@"FLOAT",
             };
}

- (Class)recordClass
{
    return [CTVideoRecord class];
}

- (NSString *)primaryKeyName
{
    return @"identifier";
}

@end
