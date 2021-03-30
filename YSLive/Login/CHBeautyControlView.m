//
//  CHBeauty.m
//  testDemo
//
//  Created by 马迪 on 2021/3/26.
//

#import "CHBeautyControlView.h"
#import "CHBeautyView.h"
#import "CHPropsView.h"


#define viewHeight 376
#define buttonW 100
#define buttonH 20
#define buttonTop 15
#define lefeMargin 20

@interface CHBeautyControlView ()

/// 美颜按钮
@property(nonatomic,weak)UIButton *beautyButton;

/// 动画道具按钮
@property(nonatomic,weak)UIButton *propButton;

/// 重置按钮
@property(nonatomic,weak)UIButton *replaceButton;

/// 返回按钮
@property(nonatomic,weak)UIButton *backButton;


/// 美颜设置view
@property(nonatomic,weak)CHBeautyView *beautyView;

/// 动画道具view
@property(nonatomic,weak)CHPropsView *propsView;

@end

@implementation CHBeautyControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [YSSkinDefineColor(@"Color2") bm_changeAlpha:0.4];
        [self setupView];
        
        self.frame = frame;
    }
    
    return self;
}

- (void)setupView
{
    UIButton *beautyButton = [[UIButton alloc]init];
    [beautyButton setTitle:YSLocalized(@"BeautySet.Beauty") forState:UIControlStateNormal];
    beautyButton.titleLabel.font = UI_FONT_12;
    [beautyButton setTitleColor:YSSkinDefineColor(@"WhiteColor") forState:UIControlStateNormal];
    [beautyButton setTitleColor:YSSkinDefineColor(@"Color4") forState:UIControlStateSelected];
    [beautyButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    beautyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    beautyButton.tag = 1;
    [self addSubview:beautyButton];
    self.beautyButton = beautyButton;
    
    beautyButton.selected = YES;
    
    UIButton *propButton = [[UIButton alloc]init];
    [propButton setTitle:YSLocalized(@"BeautySet.Props") forState:UIControlStateNormal];
    propButton.titleLabel.font = UI_FONT_12;
    [propButton setTitleColor:YSSkinDefineColor(@"WhiteColor") forState:UIControlStateNormal];
    [propButton setTitleColor:YSSkinDefineColor(@"Color4") forState:UIControlStateSelected];
    [propButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    propButton.tag = 2;
    [self addSubview:propButton];
    self.propButton = propButton;
    
    UIButton *replaceButton = [[UIButton alloc]init];
    [replaceButton setTitle:YSLocalized(@"BeautySet.Reset") forState:UIControlStateNormal];
    replaceButton.titleLabel.font = UI_FONT_12;
    [replaceButton setTitleColor:YSSkinDefineColor(@"WhiteColor") forState:UIControlStateNormal];
    [replaceButton setImage:[UIImage imageNamed:@"beauty_replace"] forState:UIControlStateNormal];
    [replaceButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    replaceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    replaceButton.tag = 3;
    [self addSubview:replaceButton];
    self.replaceButton = replaceButton;
    
    CHBeautyView *beautyView = [[CHBeautyView alloc]init];
    [self addSubview:beautyView];
    self.beautyView = beautyView;

    /// 动画道具view
    CHPropsView *propsView = [[CHPropsView alloc]initWithFrame:CGRectMake(self.bm_width, 50, self.bm_width, beautyView.bm_height)];
    propsView.dataArray = @[@"返回",@"返回",@"返回",@"返回",@"返回",@"返回",@"返回",@"返回",@"返回",@"返回",@"返回",@"返回",@"返回"];
    [self addSubview:propsView];
    self.propsView = propsView;
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, 30)];
    [backButton setBackgroundColor:[YSSkinDefineColor(@"Color2") bm_changeAlpha:0.7]];
    backButton.layer.cornerRadius = backButton.bm_height/2;
    [backButton setTitle:YSLocalized(@"BeautySet.Back") forState:UIControlStateNormal];
    backButton.titleLabel.font = UI_FONT_12;
    [backButton setTitleColor:YSSkinDefineColor(@"WhiteColor") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 4;
    [self addSubview:backButton];
    self.backButton = backButton;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.height = 50 + self.beautyView.bm_height + 60;
    
    [super setFrame:frame];
    
    self.beautyButton.frame = CGRectMake(lefeMargin, buttonTop, buttonW, buttonH);
    
    self.propButton.frame = CGRectMake((self.bm_width - buttonW)/2, buttonTop, buttonW, buttonH);
    
    self.replaceButton.frame = CGRectMake(self.bm_width - lefeMargin - buttonW, buttonTop, buttonW, buttonH);
    
    self.beautyView.frame = CGRectMake(0, 50, self.bm_width, self.beautyView.bm_height);
    
    self.propsView.frame = CGRectMake(self.bm_width, 50, self.bm_width, self.beautyView.bm_height);
    
    self.backButton.frame = CGRectMake((self.bm_width - 100)/2, self.bm_height-40, 100, 30);
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
                self.beautyView.bm_originX = 0;
                self.propsView.bm_originX = self.bm_width;
            }];
        }
            break;
        case 2:
        {
            self.beautyButton.selected = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.beautyView.bm_originX = -self.bm_width;
                self.propsView.bm_originX = 0;
            }];
        }
            break;
        case 3:
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.beautyView.bm_originX = 0;
                self.propsView.bm_originX = self.bm_width;
            }];
            [self.beautyView clearBeautyValues];
        }
            break;
        case 4:
        {            
            if (_beautyControlViewBackBtnClick)
            {
                _beautyControlViewBackBtnClick();
            }
        }
            break;
            
        default:
            break;
    }
}


@end
