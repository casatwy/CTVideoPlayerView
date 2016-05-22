//
//  SingleVideoViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "SingleVideoViewController.h"

@interface SingleVideoViewController ()

@property (nonatomic, strong) NSURL *videoUrl;

@end

@implementation SingleVideoViewController

#pragma mark - life cycle
- (instancetype)initWithVideoUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.videoUrl = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
}

@end
