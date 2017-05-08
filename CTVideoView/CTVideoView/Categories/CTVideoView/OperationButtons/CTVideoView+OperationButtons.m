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
    self.buttonDelegate = nil;
}

#pragma mark - public methods
- (void)layoutButtons
{
    CGAffineTransform transform = self.transform;

    if (self.playButton.superview) {
        self.playButton.ct_size = CGSizeMake(100, 60);
        [self.playButton centerEqualToView:self];
        if ([self.buttonDelegate respondsToSelector:@selector(videoView:layoutPlayButton:)]) {
            [self.buttonDelegate videoView:self layoutPlayButton:self.playButton];
        }
        if (transform.b == 1 && transform.c == -1) {
            CGFloat centerX = self.playButton.ct_centerX;
            CGFloat centerY = self.playButton.ct_centerY;
            self.playButton.frame = CGRectMake(self.playButton.ct_x, self.playButton.ct_y, self.playButton.ct_height, self.playButton.ct_width);
            self.playButton.ct_centerX = centerX;
            self.playButton.ct_centerY = centerY;
        }
    }

    if (self.retryButton.superview) {
        self.retryButton.ct_size = CGSizeMake(100, 60);
        [self.retryButton centerEqualToView:self];
        if ([self.buttonDelegate respondsToSelector:@selector(videoView:layoutRetryButton:)]) {
            [self.buttonDelegate videoView:self layoutRetryButton:self.retryButton];
        }
        if (transform.b == 1 && transform.c == -1) {
            CGFloat centerX = self.retryButton.ct_centerX;
            CGFloat centerY = self.retryButton.ct_centerY;
            self.retryButton.frame = CGRectMake(self.retryButton.ct_x, self.retryButton.ct_y, self.retryButton.ct_height, self.retryButton.ct_width);
            self.retryButton.ct_centerX = centerX;
            self.retryButton.ct_centerY = centerY;
        }
    }
}

- (void)showPlayButton
{
    if (self.retryButton.superview) {
        [self.retryButton removeFromSuperview];
    }
    if (self.shouldShowOperationButton && self.playButton.superview == nil) {
        [self addSubview:self.playButton];
        [self layoutButtons];
    }
}

- (void)hidePlayButton
{
    if (self.playButton.superview) {
        [self.playButton removeFromSuperview];
    }
}

- (void)showRetryButton
{
    if (self.playButton.superview) {
        [self.playButton removeFromSuperview];
    }
    if (self.shouldShowOperationButton && self.retryButton.superview == nil) {
        [self addSubview:self.retryButton];
        [self layoutButtons];
    }
}

- (void)hideRetryButton
{
    if (self.retryButton.superview) {
        [self.retryButton removeFromSuperview];
    }
}

#pragma mark - event response
- (void)didTappedPlayButton:(UIButton *)playButton
{
    if ([self.buttonDelegate respondsToSelector:@selector(videoView:didTappedPlayButton:)]) {
        [self.buttonDelegate videoView:self didTappedPlayButton:playButton];
    }
    [self hidePlayButton];
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
    return [objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPropertyShouldShowOperationButton) boolValue];
}

- (void)setShouldShowOperationButton:(BOOL)shouldShowOperationButton
{
    objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyShouldShowOperationButton, @(shouldShowOperationButton), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (shouldShowOperationButton) {
        [self showPlayButton];
    }
}

- (UIButton *)playButton
{
    UIButton *playButton = objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPropertyPlayButton);
    if (playButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"play" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyPlayButton, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        playButton = button;
    }
    [playButton addTarget:self action:@selector(didTappedPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    playButton.layer.zPosition = 1;
    return playButton;
}

- (void)setPlayButton:(UIButton *)playButton
{
    objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyPlayButton, playButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.shouldShowOperationButton) {
        [self showPlayButton];
    }
}

- (UIButton *)retryButton
{
    UIButton *retryButton = objc_getAssociatedObject(self, &CTVideoViewOperationButtonsPropertyRetryButton);
    if (retryButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"retry" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        objc_setAssociatedObject(self, &CTVideoViewOperationButtonsPropertyRetryButton, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        retryButton = button;
    }
    [retryButton addTarget:self action:@selector(didTappedRetryButton:) forControlEvents:UIControlEventTouchUpInside];
    retryButton.layer.zPosition = 1;
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
