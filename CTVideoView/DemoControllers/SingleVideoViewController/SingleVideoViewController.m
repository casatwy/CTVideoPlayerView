//
//  SingleVideoViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "SingleVideoViewController.h"
#import "CTVideoView.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface SingleVideoViewController ()

@property (nonatomic, strong) CTVideoView *videoView;
@property (nonatomic, strong) UIButton *cleanCacheButton;

@end

@implementation SingleVideoViewController

#pragma mark - life cycle
- (instancetype)initWithVideoUrlString:(NSString *)urlString
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
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.videoView];
    [self.view addSubview:self.cleanCacheButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.videoView.size = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
    [self.videoView centerXEqualToView:self.view];
    [self.videoView centerYEqualToView:self.view];

    self.cleanCacheButton.size = CGSizeMake(100, 50);
    [self.cleanCacheButton rightInContainer:10 shouldResize:NO];
    [self.cleanCacheButton bottomInContainer:10 shouldResize:NO];
}

#pragma mark - event response
- (void)didTappedCleanCacheButton:(UIButton *)button
{

}

#pragma mark - getters and setters
- (UIButton *)cleanCacheButton
{
    if (_cleanCacheButton == nil) {
        _cleanCacheButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cleanCacheButton setTitle:@"Clean Cache" forState:UIControlStateNormal];
        [_cleanCacheButton addTarget:self action:@selector(didTappedCleanCacheButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanCacheButton;
}

- (CTVideoView *)videoView
{
    if (_videoView == nil) {
        _videoView = [[CTVideoView alloc] init];
    }
    return _videoView;
}

@end
