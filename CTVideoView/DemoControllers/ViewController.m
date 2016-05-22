//
//  ViewController.m
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "ViewController.h"

#import "SingleVideoViewController.h"
#import "VideoTableViewController.h"

#import <HandyFrame/UIView+LayoutMethods.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Main";
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView fill];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewControllerToPush = nil;

    NSDictionary *info = self.dataSource[indexPath.row];
    if (indexPath.row < 3) {
        viewControllerToPush = [[SingleVideoViewController alloc] initWithVideoUrlString:info[@"url"]];
    }
    if (indexPath.row == 3) {
        viewControllerToPush = [[VideoTableViewController alloc] initWithVideoUrlList:info[@"urlList"]];
    }

    if (viewControllerToPush) {
        viewControllerToPush.title = info[@"title"];
        [self.navigationController pushViewController:viewControllerToPush animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
    return cell;
}

#pragma mark - getters and setters
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;

        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = @[
                        @{
                            @"title":@"single remote video",
                            @"url":@""
                            },
                        @{
                            @"title":@"single native video",
                            @"url":@""
                            },
                        @{
                            @"title":@"single live stream video",
                            @"url":@""
                            },
                        @{
                            @"title":@"videos in tableview",
                            @"urlList":@[
                                    @"",
                                    @"",
                                    @"",
                                    @"",
                                    @"",
                                    @"",
                                    ]
                            },
                        ];
    }
    return _dataSource;
}

@end
