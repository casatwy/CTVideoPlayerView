//
//  CTVideoView+OperationButtons.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+OperationButtons.h"
#import <objc/runtime.h>

static void * CTVideoViewOperationButtonsPrivatePropertyShouldShowOperationButton;

@implementation CTVideoView (OperationButtons)

@dynamic shouldShowOperationButton;

#pragma mark - life cycle
- (void)initOperationButtons
{
    
}

- (void)deallocOperationButtons
{
    
}

#pragma mark - getters and setters
- (BOOL)shouldShowOperationButton
{
    return [objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPrivatePropertyShouldShowOperationButton) boolValue];
}

- (void)setShouldShowOperationButton:(BOOL)shouldShowOperationButton
{
    objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPrivatePropertyShouldShowOperationButton, @(shouldShowOperationButton), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
