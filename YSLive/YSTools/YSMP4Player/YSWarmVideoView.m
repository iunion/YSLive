//
//  YSWarmVideoView.m
//  YSAll
//
//  Created by 马迪 on 2020/12/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSWarmVideoView.h"


@interface YSWarmVideoView ()



@end

@implementation YSWarmVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
//        self.backgroundColor = [UIColor clearColor];
        
//        _isDragSlider = NO;
//        _isWiFi = YES;
//        _showFullBtn = YES;
        
        [self setUI];
        
//        [self initCAGradientLayer];
//
//        [self cofigGestureRecognizer];
    }
    return self;
}

-(void)setUI
{
    UIButton * fullBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bm_width-50, self.bm_height - 50, 30, 30)];
//    [fullBtn setBackgroundColor:UIColor.clearColor];
    //[_fullBtn setImage:[self imagesNamedFromCustomBundle:@"icon_video_fullscreen"] forState:UIControlStateNormal];
    [fullBtn setImage:YSSkinOnlineElementImage(@"online_video_fullscreen", @"iconNor") forState:UIControlStateNormal];
    [fullBtn addTarget:self action:@selector(videoFullAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:fullBtn];
    
    self.fullBtn = fullBtn;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (frame.size.height == BMUI_SCREEN_HEIGHT)
    {
        self.fullBtn.frame = CGRectMake(50, self.bm_height - 50, 30, 30);
    }
    else
    {
        self.fullBtn.frame = CGRectMake(self.bm_width-50, self.bm_height - 50, 30, 30);
    }
}

- (void)videoFullAction:(UIButton *)sender
{
    
    sender.selected = !sender.selected;
    if (_warmViewFullBtnClick)
    {
        _warmViewFullBtnClick(sender);
    }
}


@end
