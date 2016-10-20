//
//  VideoCell.h
//  CTVideoView
//
//  Created by casa on 16/5/23.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTVideoViewCommonHeader.h"

@protocol VideoCellDelegate <NSObject>

@optional
- (void)scrollToInvisibleCell;

@end


@interface VideoCell : UITableViewCell

@property (nonatomic, strong, readonly) CTVideoView *videoView;
@property (nonatomic, weak) id<VideoCellDelegate> delegate;

@end
