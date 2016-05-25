//
//  CTVideoView+Time.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+Time.h"
#import <objc/runtime.h>

static void * CTVideoViewTimePropertyShouldObservePlayTime;

@implementation CTVideoView (Time)

@dynamic shouldObservePlayTime;

#pragma mark - getters and setters
- (BOOL)shouldObservePlayTime
{
    return [objc_getAssociatedObject(self, &CTVideoViewTimePropertyShouldObservePlayTime) boolValue];
}

- (void)setShouldObservePlayTime:(BOOL)shouldObservePlayTime
{
    objc_setAssociatedObject(self, &CTVideoViewTimePropertyShouldObservePlayTime, @(shouldObservePlayTime), OBJC_ASSOCIATION_ASSIGN);
}

@end
