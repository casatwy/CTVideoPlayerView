//
//  AVAsset+CTVideoView.m
//  CTVideoView
//
//  Created by casa on 16/5/25.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "AVAsset+CTVideoView.h"

@implementation AVAsset (CTVideoView)

- (BOOL)CTVideoView_isVideoPortraint
{
    BOOL isPortrait = NO;
    NSArray *trackList = [self tracksWithMediaType:AVMediaTypeVideo];
    if (trackList.count > 0) {
        AVAssetTrack *track = [trackList firstObject];
        
        CGAffineTransform t = track.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = NO;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = NO;
        }
    }
    return isPortrait;
}

@end
