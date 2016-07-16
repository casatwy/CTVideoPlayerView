//
//  CTVideoView+Cache.h
//  CTVideoView
//
//  Created by casa on 16/7/17.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView.h"

@interface CTVideoView (Cache) <AVAssetResourceLoaderDelegate>

- (void)cacheAndPlay;

@end
