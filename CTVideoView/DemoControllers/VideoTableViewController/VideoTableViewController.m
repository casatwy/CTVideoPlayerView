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

@interface VideoTableViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

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
        NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        [urlList enumerateObjectsUsingBlock:^(NSString * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
            [dataSource addObject:[NSURL URLWithString:url]];
        }];
        self.dataSource = dataSource;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(VideoCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[VideoCell class]]) {
            [cell.videoView play];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell *videoCell = (VideoCell *)cell;
    if ([videoCell isKindOfClass:[videoCell class]]) {
        [videoCell.videoView stopWithReleaseVideo:NO];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(VideoCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[VideoCell class]]) {
            [cell.videoView play];
        }
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(VideoCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell isKindOfClass:[VideoCell class]]) {
                [cell.videoView play];
            }
        }];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(VideoCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[VideoCell class]]) {
            [cell.videoView play];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.videoView.videoUrl = self.dataSource[indexPath.row];
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
        _tableView.rowHeight = SCREEN_WIDTH;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;

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
