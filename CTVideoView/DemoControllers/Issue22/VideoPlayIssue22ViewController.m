//
//  VideoPlayIssue22ViewController.m
//  CTVideoView
//
//  Created by casa on 2016/11/12.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "VideoPlayIssue22ViewController.h"
#import "CTVideoViewCommonHeader.h"

@interface VideoPlayIssue22ViewController ()

@property (nonatomic, strong) CTVideoView *videoView;

@end

@implementation VideoPlayIssue22ViewController

#pragma mark - life cycle
- (instancetype)initWithVideoUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.videoView.assetToPlay = [AVURLAsset assetWithURL:[NSURL URLWithString:urlString]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.videoView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoView play];
}

#pragma mark - getters and setters
- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    }
    return _videoView;
}

@end
