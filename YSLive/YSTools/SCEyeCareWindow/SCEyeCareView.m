//
//  SCEyeCareView.m
//  YSAll
//
//  Created by jiang deng on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCEyeCareView.h"

@interface SCEyeCareView ()

@property (nonatomic, assign) BOOL needRotation;

/// 白色展示区
@property (nonatomic, strong) UIView *whiteView;

/// 白色展示区核心提示lab
@property (nonatomic, strong) UILabel *centerLabel;
/// 提示动画
@property (nonatomic, strong) UIImageView *animateView;


@end

@implementation SCEyeCareView

- (instancetype)initWithFrame:(CGRect)frame needRotation:(BOOL)needRotation
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.needRotation = needRotation;
        [self setupUI];
    }

    return self;
}

- (CGFloat)getWidthWithWidth:(CGFloat)width
{
    if (self.needRotation)
    {
        CGFloat maxWidth = UI_SCREEN_HEIGHT;
        CGFloat maxHeight = UI_SCREEN_WIDTH;

        if (maxWidth > maxHeight)
        {
            return (UI_SCREEN_HEIGHT/667) * (width);
        }
        
        return (UI_SCREEN_HEIGHT/375) * (width);
    }
    else
    {
        CGFloat maxWidth = UI_SCREEN_WIDTH;
        CGFloat maxHeight = UI_SCREEN_HEIGHT;

        if (maxWidth > maxHeight)
        {
            return (UI_SCREEN_WIDTH/667) * (width);
        }
        
        return (UI_SCREEN_WIDTH/375) * (width);
    }
}

- (CGFloat)getHeightWithHeight:(CGFloat)height
{
    if (self.needRotation)
    {
        CGFloat maxWidth = UI_SCREEN_HEIGHT;
        CGFloat maxHeight = UI_SCREEN_WIDTH;
        
        if (maxWidth > maxHeight)
        {
            return (UI_SCREEN_WIDTH/335) * (height);
        }
        
        return (UI_SCREEN_WIDTH/667) * (height);
    }
    else
    {
        CGFloat maxWidth = UI_SCREEN_WIDTH;
        CGFloat maxHeight = UI_SCREEN_HEIGHT;

        if (maxWidth > maxHeight)
        {
            return (UI_SCREEN_HEIGHT/335) * (height);
        }
        
        return (UI_SCREEN_HEIGHT/667) * (height);
    }
}

- (void)setupUI
{
    /// 白色展示区
    CGFloat height = [self getHeightWithHeight:180.0f];
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self getWidthWithWidth:270.0f], height)];
    whiteView.backgroundColor = UIColor.whiteColor;
    [whiteView bm_connerWithRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(height*0.3, height*0.3)];
    [self addSubview:whiteView];
    self.whiteView = whiteView;

    /// 提示动画
    UIImageView *animateView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 145)];
    [self addSubview:animateView];
    animateView.bm_top = whiteView.bm_height*0.5f;
    animateView.animationImages = @[[UIImage imageNamed:@"Permissions1"],[UIImage imageNamed:@"Permissions2"],[UIImage imageNamed:@"Permissions3"],[UIImage imageNamed:@"Permissions4"]];
    animateView.animationDuration = 1.0;
    animateView.animationRepeatCount = 0;
    [animateView startAnimating];
    self.animateView = animateView;
    whiteView.bm_left = animateView.bm_right-10;
    
    /// 提示文字
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(height*0.2, height*0.2, whiteView.bm_width-height*0.4, 80.0f)];
    centerLabel.numberOfLines = 0;
    centerLabel.adjustsFontSizeToFitWidth = YES;
    centerLabel.minimumScaleFactor = 0.5f;
    centerLabel.text = YSLocalized(@"EyeProtection.CoverMsg");
    centerLabel.font = UI_FONT_20;
    centerLabel.textColor = [UIColor bm_colorWithHex:0x6D7278];
//    CGFloat centerLabelHeight = [centerLabel bm_labelSizeToFitWidth:centerLabel.bm_width].height;
//    centerLabel.bm_height = centerLabelHeight + 2.0f;
    [whiteView addSubview:centerLabel];
    self.centerLabel = centerLabel;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(whiteView.bm_width*0.25, whiteView.bm_height - 60, whiteView.bm_width*0.5, 50)];
    [btn setTitle:YSLocalized(@"EyeProtection.BtnKnow") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    btn.titleLabel.font = UI_FONT_18;
    [btn bm_roundedRect:25.0f borderWidth:4.0f borderColor:[UIColor bm_colorWithHex:0x9DB7E7]];
    btn.backgroundColor = [UIColor bm_colorWithHex:0x648CD6];
    [btn addTarget:self action:@selector(onClickOk:) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:btn];

    CGRect frame = self.frame;
    frame.size.width = whiteView.bm_right;
    frame.size.height = animateView.bm_bottom;
    
    self.frame = frame;
    //self.backgroundColor = [UIColor redColor];
}

- (void)onClickOk:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(eyeCareViewClose)])
    {
        [self.delegate eyeCareViewClose];
    }
}

@end
