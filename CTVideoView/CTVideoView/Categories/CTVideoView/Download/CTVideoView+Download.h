//
//  CTVideoView+Download.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (Download)

- (void)initDownload;
- (void)deallocDownload;

@property (nonatomic, assign, readonly) BOOL shouldDownloadWhenNotWifi; // set bool value of kCTVideoViewShouldDownloadWhenNotWifi in NSUserDefaults to modify this property, default is NO

@property (nonatomic, weak) id<CTVideoViewDownloadDelegate> downloadDelegate;

- (void)startDownloadTask;
- (void)DeleteAndCancelDownloadTask;
- (void)pauseDownloadTask;

@end
