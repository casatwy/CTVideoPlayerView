//
//  CTVideoView+FullScreen.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+FullScreen.h"
#import <objc/runtime.h>

static void * CTVideoViewFullScreenPropertyIsFullScreen;

@implementation CTVideoView (FullScreen)

#pragma mark - public methods
- (void)enterFullScreen
{
//    if (self.) {
//        <#statements#>
//    }
}

- (void)exitFullScreen
{
    
}

#pragma mark - getters and setters
- (BOOL)isFullScreen
{
    return [objc_getAssociatedObject(self, &CTVideoViewFullScreenPropertyIsFullScreen) boolValue];
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    objc_setAssociatedObject(self, &CTVideoViewFullScreenPropertyIsFullScreen, @(isFullScreen), OBJC_ASSOCIATION_RETAIN);
}

@end
