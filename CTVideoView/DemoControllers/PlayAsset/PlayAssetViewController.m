//
//  PlayAssetViewController.m
//  CTVideoView
//
//  Created by casa on 16/6/15.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "PlayAssetViewController.h"
#import "CTVideoViewCommonHeader.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface PlayAssetViewController ()

@property (nonatomic, strong) CTVideoView *videoView;

@end

@implementation PlayAssetViewController

#pragma mark - life cycle
- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        self.videoView.assetToPlay = asset;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.videoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.videoView fill];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoView prepare];
}

#pragma mark - getters and setters
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.shouldShowOperationButton = YES;
    }
    return _videoView;
}

@end
