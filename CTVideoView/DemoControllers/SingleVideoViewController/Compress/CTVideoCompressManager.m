//
//  CTVideoCompressManager.m
//  CTVideoView
//
//  Created by casa on 2017/11/30.
//  Copyright © 2017年 casa. All rights reserved.
//

#import "CTVideoCompressManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation CTVideoCompressManager

- (void)compress
{
    NSString *outputPath = [NSString stringWithFormat:@"%@/compressed.mov", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    NSURL *inputURL = [[NSBundle mainBundle] URLForResource:@"origin" withExtension:@"mov"];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@", outputURL);
    }];
}


@end
