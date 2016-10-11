//
//  UIPanGestureRecognizer+ExtraMethods.m
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "UIPanGestureRecognizer+ExtraMethods.h"
#import <objc/runtime.h>

static void * CTUIPanGestureRecognizerCategoryPropertySlideDirection;

@implementation UIPanGestureRecognizer (ExtraMethods)

- (CTUIPanGestureSlideDirection)slideDirection
{
    return [objc_getAssociatedObject(self, &CTUIPanGestureRecognizerCategoryPropertySlideDirection) unsignedIntegerValue];
}

- (void)setSlideDirection:(CTUIPanGestureSlideDirection)slideDirection
{
    objc_setAssociatedObject(self, &CTUIPanGestureRecognizerCategoryPropertySlideDirection, @(slideDirection), OBJC_ASSOCIATION_ASSIGN);
}

@end
