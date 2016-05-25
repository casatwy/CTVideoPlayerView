//
//  DownloadThenPlayViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "DownloadThenPlayViewController.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import "CTVideoViewCommonHeader.h"

@interface DownloadThenPlayViewController () <CTVideoViewDownloadDelegate>

@property (nonatomic, strong) CTVideoView *videoView;

@end

@implementation DownloadThenPlayViewController

#pragma mark - life cycle
- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.videoView.videoUrl = [NSURL URLWithString:urlString];
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
    [self.videoView prepare];
    [self.videoView startDownload];
}

#pragma mark - CTVideoViewDownloadDelegate
- (void)videoView:(CTVideoView *)videoView willStartDownloadWithUrl:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier
{

}

- (void)videoView:(CTVideoView *)videoView downloadProgress:(CGFloat *)progress url:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier
{

}

- (void)videoView:(CTVideoView *)videoView didFinishDownloadUrl:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier
{

}

- (void)videoView:(CTVideoView *)videoView didFailDownloadUrl:(NSURL *)url fileIdentifier:(NSString *)fileIdentifier
{

}

#pragma mark - getters and setter
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
        _videoView.downloadStrategy = CTVideoViewDownloadStrategyDownloadForegroundAndBackground;
        _videoView.downloadDelegate = self;
    }
    return _videoView;
}

@end
