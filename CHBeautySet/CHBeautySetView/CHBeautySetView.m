//
//  CHBeautySetView.m
//  YSLive
//
//  Created by jiang deng on 2021/4/1.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHBeautySetView.h"
#import "CHBeautyView.h"
#import "CHPropsView.h"

#define CHBeautySetView_BtnWidth        100.0f
#define CHBeautySetView_BtnHeight       30.0f

#define CHBeautySetView_Gap             20.0f
#define CHBeautySetView_LeftGap         20.0f

@interface CHBeautySetView ()

@property (nonatomic, weak) UIView *topView;

/// 美颜按钮
@property (nonatomic, weak) UIButton *beautyButton;

/// 动画道具按钮
@property (nonatomic, weak) UIButton *propButton;

/// 重置按钮
@property (nonatomic, weak) UIButton *resetButton;

/// 美颜设置view
@property (nonatomic, weak) CHBeautyView *beautyView;

/// 动画道具view
@property (nonatomic, weak) CHPropsView *propsView;

@end

@implementation CHBeautySetView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
        
        self.frame = frame;
    }
    
    return self;
}

- (void)setupView
{
    self.backgroundColor = UIColor.clearColor;

    UIView *topView = [[UIView alloc] init];
    [self addSubview:topView];
    self.topView = topView;

    UIButton *beautyButton = [[UIButton alloc] init];
    [beautyButton setTitle:YSLocalized(@"BeautySet.Beauty") forState:UIControlStateNormal];
    beautyButton.titleLabel.font = UI_FONT_12;
    [beautyButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [beautyButton setTitleColor:[UIColor bm_colorWithHex:0x82ABEC] forState:UIControlStateSelected];
    [beautyButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    beautyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    beautyButton.tag = 1;
    beautyButton.selected = YES;
    [self.topView addSubview:beautyButton];
    self.beautyButton = beautyButton;
    
    UIButton *propButton = [[UIButton alloc] init];
    [propButton setTitle:YSLocalized(@"BeautySet.Props") forState:UIControlStateNormal];
    propButton.titleLabel.font = UI_FONT_12;
    [propButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [propButton setTitleColor:[UIColor bm_colorWithHex:0x82ABEC] forState:UIControlStateSelected];
    [propButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    propButton.tag = 2;
    [self.topView addSubview:propButton];
    self.propButton = propButton;
    
    UIButton *resetButton = [[UIButton alloc]init];
    [resetButton setTitle:YSLocalized(@"BeautySet.Reset") forState:UIControlStateNormal];
    resetButton.titleLabel.font = UI_FONT_12;
    [resetButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [resetButton setImage:[UIImage imageNamed:@"beauty_replace"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    resetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    resetButton.tag = 3;
    [self.topView addSubview:resetButton];
    self.resetButton = resetButton;
    
    CHBeautyView *beautyView = [[CHBeautyView alloc] init];
    [self addSubview:beautyView];
    self.beautyView = beautyView;

    /// 动画道具view
    CHPropsView *propsView = [[CHPropsView alloc] initWithFrame:CGRectMake(self.bm_width, 50, self.bm_width, beautyView.bm_height)];
    [self addSubview:propsView];
    self.propsView = propsView;
}

- (void)setBeautySetModel:(CHBeautySetModel *)beautySetModel
{
    _beautySetModel = beautySetModel;
    
    self.beautyView.beautySetModel = self.beautySetModel;
    self.propsView.beautySetModel = self.beautySetModel;
    
#warning test propUrlArray
    [self performSelector:@selector(adddata) withObject:nil afterDelay:2];
}

- (void)adddata
{
    NSMutableArray *propUrlArray = [NSMutableArray array];
    
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];
    [propUrlArray addObject:@"1"];

    self.beautySetModel.propUrlArray = propUrlArray;
    self.beautySetModel.propIndex = 2;
    
    [self.propsView reloadData];
}

- (void)setFrame:(CGRect)frame
{
    CGFloat width = frame.size.width;

    self.topView.frame = CGRectMake(CHBeautySetView_LeftGap, CHBeautySetView_Gap, width-CHBeautySetView_LeftGap*2, CHBeautySetView_BtnHeight+CHBeautySetView_Gap*2);

    self.beautyButton.frame = CGRectMake(0, CHBeautySetView_Gap, CHBeautySetView_BtnWidth, CHBeautySetView_BtnHeight);
    
    self.propButton.frame = CGRectMake(0, CHBeautySetView_Gap, CHBeautySetView_BtnWidth, CHBeautySetView_BtnHeight);
    self.propButton.bm_centerX = self.topView.bm_width*0.5;
    
    self.resetButton.frame = CGRectMake(self.topView.bm_width - CHBeautySetView_BtnWidth, CHBeautySetView_Gap, CHBeautySetView_BtnWidth, CHBeautySetView_BtnHeight);
    
    self.beautyView.frame = CGRectMake(0, self.topView.bm_bottom + CHBeautySetView_Gap, self.bm_width, self.bm_height);
    
    self.propsView.frame = CGRectMake(self.bm_width, self.topView.bm_bottom + CHBeautySetView_Gap, self.bm_width, self.beautyView.bm_height);
    
    frame.size.height = self.beautyView.bm_bottom;
    
    [super setFrame:frame];
}

- (void)topButtonClick:(UIButton *)sender
{
    sender.selected = YES;
    
    switch (sender.tag)
    {
        case 1:
        {
            self.propButton.selected = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.beautyView.bm_originX = 0.0f;
                self.propsView.bm_originX = self.bm_width;
            }];
        }
            break;
            
        case 2:
        {
            self.beautyButton.selected = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.beautyView.bm_originX = -self.bm_width;
                self.propsView.bm_originX = 0.0f;
            }];
        }
            break;
            
        case 3:
        {
            self.resetButton.selected = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.beautyView.bm_originX = 0.0f;
                self.propsView.bm_originX = self.bm_width;
                self.beautyButton.selected = YES;
                self.propButton.selected = NO;
            }];
            
            [self.beautyView clearBeautyValues];
            
            [self.propsView clearPropsValue];
        }
            break;
            
        default:
            break;
    }
}

@end
