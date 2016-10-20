//
//  UIPanGestureRecognizer+ExtraMethods.h
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CTUIPanGestureSlideDirection) {
    CTUIPanGestureSlideDirectionNotDefined,
    CTUIPanGestureSlideDirectionVertical,
    CTUIPanGestureSlideDirectionHorizontal,
};

@interface UIPanGestureRecognizer (ExtraMethods)

@property (nonatomic, assign) CTUIPanGestureSlideDirection slideDirection;

@end
