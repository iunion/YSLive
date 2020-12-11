//
//  YSWarmVideoView.m
//  YSAll
//
//  Created by 马迪 on 2020/12/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSWarmVideoView.h"


@interface YSWarmVideoView ()

/** 全屏按钮 */
@property (nonatomic, strong) UIButton *fullBtn;

@end

@implementation YSWarmVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor yellowColor];
        
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
    //[_fullBtn setImage:[self imagesNamedFromCustomBundle:@"icon_video_fullscreen"] forState:UIControlStateNormal];
    [fullBtn setImage:YSSkinOnlineElementImage(@"online_video_fullscreen", @"iconNor") forState:UIControlStateNormal];
    [fullBtn addTarget:self action:@selector(videoFullAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:fullBtn];
    
    
    
    
}


- (void)videoFullAction:(UIButton *)sender
{
    
}


@end
