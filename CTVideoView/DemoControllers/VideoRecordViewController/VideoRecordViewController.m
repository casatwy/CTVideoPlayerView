//
//  VideoRecordViewController.m
//  CTVideoView
//
//  Created by casa on 2017/11/30.
//  Copyright © 2017年 casa. All rights reserved.
//

#import "VideoRecordViewController.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoRecordViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIButton *recordButton;

@end

@implementation VideoRecordViewController

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.recordButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.recordButton sizeToFit];
    [self.recordButton centerEqualToView:self.view];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@", info);
}

#pragma mark - event response
- (void)didTappedRecordButton:(UIButton *)recordButton
{
    UIImagePickerController *viewController = [[UIImagePickerController alloc] init];
    viewController.delegate = self;
    viewController.sourceType = UIImagePickerControllerSourceTypeCamera;
    viewController.mediaTypes = @[(NSString *)kUTTypeMovie];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - getters and setters
- (UIButton *)recordButton
{
    if (_recordButton == nil) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_recordButton setTitle:@"record video" forState:UIControlStateNormal];
        [_recordButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_recordButton addTarget:self action:@selector(didTappedRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

@end
