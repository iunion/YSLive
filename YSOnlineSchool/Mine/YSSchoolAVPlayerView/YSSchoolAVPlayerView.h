//
//  YSSchoolAVPlayerView.h
//  YSSchoolAVPlayerView
//
//  Created by 宁杰英 on 2020/2/7.
//  Copyright © 2020 YS. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface YSSchoolAVPlayerView : UIView
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *avPlayer;

- (void)settingPlayerItemWithUrl:(NSURL *)playerUrl;

@end
