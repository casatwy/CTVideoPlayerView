//
//  CTVideoView+OperationButtons.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"
#import "CTVideoViewDefinitions.h"

@interface CTVideoView (OperationButtons)

- (void)initOperationButtons;
- (void)deallocOperationButtons;

@property (nonatomic, assign) BOOL shouldShowOperationButton;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, weak) id<CTVideoViewButtonDelegate> buttonDelegate;

- (void)showPlayButton;
- (void)hidePlayButton;

- (void)showRetryButton;
- (void)hideRetryButton;

- (void)layoutButtons;

@end
