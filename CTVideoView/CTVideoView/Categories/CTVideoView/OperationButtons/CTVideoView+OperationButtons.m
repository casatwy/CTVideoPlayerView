//
//  CTVideoView+OperationButtons.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+OperationButtons.h"
#import <objc/runtime.h>
#import <HandyFrame/UIView+LayoutMethods.h>

static void * CTVideoViewOperationButtonsPropertyShouldShowOperationButton;
static void * CTVideoViewOperationButtonsPropertyPlayButton;
static void * CTVideoViewOperationButtonsPropertyRetryButton;
static void * CTVideoViewOperationButtonsPropertyButtonDelegate;

@implementation CTVideoView (OperationButtons)

@dynamic shouldShowOperationButton;
@dynamic playButton;
@dynamic retryButton;
@dynamic buttonDelegate;

#pragma mark - life cycle
- (void)initOperationButtons
{
    [self showPlayButton];
}

- (void)deallocOperationButtons
{
    // do nothing
}

#pragma mark - public methods
- (void)layoutButtons
{
    if (self.playButton.superview) {
        self.playButton.size = CGSizeMake(60, 60);
        [self.playButton centerEqualToView:self];
        if ([self.buttonDelegate respondsToSelector:@selector(videoView:layoutPlayButton:)]) {
            [self.buttonDelegate videoView:self layoutPlayButton:self.playButton];
        }
    }
    
    if (self.retryButton.superview) {
        self.retryButton.size = CGSizeMake(60, 60);
        [self.retryButton centerEqualToView:self];
        if ([self.buttonDelegate respondsToSelector:@selector(videoView:layoutRetryButton:)]) {
            [self.buttonDelegate videoView:self layoutRetryButton:self.retryButton];
        }
    }
}

- (void)showPlayButton
{
    [self.retryButton removeFromSuperview];
    if (self.shouldShowOperationButton) {
        [self addSubview:self.playButton];
        [self layoutButtons];
    }
}

- (void)hidePlayButton
{
    [self.playButton removeFromSuperview];
}

- (void)showRetryButton
{
    [self.playButton removeFromSuperview];
    if (self.shouldShowOperationButton) {
        [self addSubview:self.retryButton];
        [self layoutButtons];
    }
}

- (void)hideRetryButton
{
    [self.retryButton removeFromSuperview];
}

#pragma mark - event response
- (void)didTappedPlayButton:(UIButton *)playButton
{
    if ([self.buttonDelegate respondsToSelector:@selector(videoView:didTappedPlayButton:)]) {
        [self.buttonDelegate videoView:self didTappedPlayButton:playButton];
    }
    [self play];
}

- (void)didTappedRetryButton:(UIButton *)retryButton
{
    if ([self.buttonDelegate respondsToSelector:@selector(videoView:didTappedRetryButton:)]) {
        [self.buttonDelegate videoView:self didTappedRetryButton:retryButton];
    }
    [self prepare];
}

#pragma mark - getters and setters
- (BOOL)shouldShowOperationButton
{
    NSNumber *shouldShowOperationButton = objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPropertyShouldShowOperationButton);
    if ([shouldShowOperationButton isKindOfClass:[NSNumber class]]) {
        return [shouldShowOperationButton boolValue];
    }
    return NO;
}

- (void)setShouldShowOperationButton:(BOOL)shouldShowOperationButton
{
    objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyShouldShowOperationButton, @(shouldShowOperationButton), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIButton *)playButton
{
    UIButton *playButton = objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPropertyPlayButton);
    if (playButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"play" forState:UIControlStateNormal];
        objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyPlayButton, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        playButton = button;
    }
    [playButton addTarget:self action:@selector(didTappedPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    return playButton;
}

- (void)setPlayButton:(UIButton *)playButton
{
    objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyPlayButton, playButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIButton *)retryButton
{
    UIButton *retryButton = objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPropertyRetryButton);
    if (retryButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"retry" forState:UIControlStateNormal];
        objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyRetryButton, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        retryButton = button;
    }
    [retryButton addTarget:self action:@selector(didTappedRetryButton:) forControlEvents:UIControlEventTouchUpInside];
    return retryButton;
}

- (void)setRetryButton:(UIButton *)retryButton
{
    objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyRetryButton, retryButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setButtonDelegate:(id<CTVideoViewButtonDelegate>)buttonDelegate
{
    objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyButtonDelegate, buttonDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CTVideoViewButtonDelegate>)buttonDelegate
{
    return objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPropertyButtonDelegate);
}

@end
