//
//  CHPermissionsView.m
//  YSLive
//
//  Created by jiang deng on 2021/3/29.
//  Copyright © 2021 CH. All rights reserved.
//

#define CHPermissionsView_IconWidth         20.0f

#define CHPermissionsView_Gap               10.0f
#define CHPermissionsView_LeftGap           15.0f

#import "CHPermissionsView.h"

@implementation CHPermissionsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    self.backgroundColor = [UIColor bm_colorWithHex:0x1C1D20 alpha:0.4f];
    
    UIImageView *icon1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"permissions_cam_icon"]];
    icon1.frame = CGRectMake(CHPermissionsView_LeftGap, CHPermissionsView_Gap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    [self addSubview:icon1];
    icon1.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(icon1.bm_right + 4.0f, CHPermissionsView_Gap, 80.0f, 16.0f)];
    label1.font = [UIFont systemFontOfSize:12.0f];
    label1.textColor = UIColor.whiteColor;
    
    [self addSubview:label1];
    label1.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

    
    
    
    // permissions_cam_icon permissions_camswitch permissions_audiopause permissions_audioplay
    // permissions_beautyset permissions_beauty_icon permissions_mic_icon permissions_speaker_icon
    // permissions_unmirror permissions_mirror permissions_progress permissions_unprogress
    
    
    
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}





@end
