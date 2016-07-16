//
//  DownloadAndPlayViewController.m
//  CTVideoView
//
//  Created by casa on 16/7/17.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "DownloadAndPlayViewController.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import "CTVideoView.h"
#import "CTVideoView+Cache.h"

@interface DownloadAndPlayViewController ()

@property (nonatomic, strong) CTVideoView *videoView;

@end

@implementation DownloadAndPlayViewController

#pragma mark - life cycle
- (instancetype)initWithUrl:(NSURL *)assetUrl
{
    self = [super init];
    if (self) {
        self.videoView.videoUrl = assetUrl;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [self.videoView cacheAndPlay];
}

#pragma mark - getters and setters
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
    }
    return _videoView;
}

@end
