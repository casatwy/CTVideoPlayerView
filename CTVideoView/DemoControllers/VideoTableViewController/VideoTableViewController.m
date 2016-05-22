//
//  VideoTableViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "VideoTableViewController.h"
#import "VideoCell.h"
#import <HandyFrame/UIView+LayoutMethods.h>

@interface VideoTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cleanCacheButton;

@end

@implementation VideoTableViewController

#pragma mark - life cycle
- (instancetype)initWithVideoUrlList:(NSArray *)urlList
{
    self = [super init];
    if (self) {
        self.dataSource = urlList;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.cleanCacheButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView fill];

    self.cleanCacheButton.size = CGSizeMake(100, 50);
    [self.cleanCacheButton rightInContainer:10 shouldResize:NO];
    [self.cleanCacheButton bottomInContainer:10 shouldResize:NO];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
}

#pragma mark - event response
- (void)didTappedCleanCacheButton:(UIButton *)button
{

}

#pragma mark - getters and setters
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 200;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[VideoCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (UIButton *)cleanCacheButton
{
    if (_cleanCacheButton == nil) {
        _cleanCacheButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cleanCacheButton setTitle:@"Clean Cache" forState:UIControlStateNormal];
        [_cleanCacheButton addTarget:self action:@selector(didTappedCleanCacheButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanCacheButton;
}

@end
