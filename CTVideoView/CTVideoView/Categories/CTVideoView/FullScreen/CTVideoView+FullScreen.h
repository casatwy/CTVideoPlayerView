//
//  CTVideoView+FullScreen.h
//  CTVideoView
//
//  Created by casa on 2016/10/11.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (FullScreen)

@property (nonatomic, assign, readonly) BOOL isFullScreen;
- (void)enterFullScreen;
- (void)exitFullScreen;

@end
