//
//  LHDiceAnimationView.m
//  LHDiceAnimation
//
//  Created by ma c on 2018/6/11.
//  Copyright © 2018年 LIUHAO. All rights reserved.
//

#import "YSDiceAnimationView.h"
#import "YSDiceAnimationView+Tools.h"

//动画一次循环时长
#define AnimationTime 1.5

//图片张数
#define ImageNums 8

@interface YSDiceAnimationView()
<
    CAAnimationDelegate,
    UIGestureRecognizerDelegate
>


///关闭按钮
@property(nonatomic,strong)UIButton *cancleBtn;
///标题（骰子）
@property(nonatomic,strong) UILabel *titleLab;

@property(nonatomic,strong) UIView *lineView;
//动画图片
@property(nonatomic,strong)UIImageView *animDiceOne;
///用户名
@property(nonatomic,strong) UILabel *nameLab;

@end
@implementation YSDiceAnimationView
#pragma mark - #1初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.layer.cornerRadius = 10;
        self.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureClicked:)];
        tapGesture.delegate =self;
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapGesture];
        
        [self setupUI];
        
    }
    return self;
}
//-(void)awakeFromNib{
//    [super awakeFromNib];
//
//    [self addSubview:self.animDiceOne];
//}

- (void)setupUI
{
    [self addSubview:self.cancleBtn];
    [self addSubview:self.titleLab];
    [self addSubview:self.lineView];
    [self addSubview:self.animDiceOne];
    [self addSubview:self.nameLab];
    
    [self setControlsFrame];
}

- (void)tapGestureClicked:(UITapGestureRecognizer *)tap
{
    if (YSCurrentUser.role == CHUserType_Teacher || (YSCurrentUser.role == CHUserType_Student && YSCurrentUser.canDraw))
    {
        self.resultNum = arc4random() % 6 + 1;
        
        [[CHSessionManager sharedInstance] sendSignalingToDiceWithState:1 IRand:self.resultNum];
                
        [self diceBegainAnimals];
        self.userInteractionEnabled = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((AnimationTime + 2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.userInteractionEnabled = YES;
        });
    }
}

#pragma mark - #1开始动画
-(void)diceBegainAnimals
{
    _animDiceOne.hidden = NO;
    [_animDiceOne startAnimating];

    _animDiceOne.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.png",(long)self.resultNum]];

    BMWeakSelf
    //停止动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.animDiceOne stopAnimating];
        [weakSelf.animDiceOne.layer removeAllAnimations];
    });
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    self.nameLab.text = nickName;
}

- (void)diceCancleBtnCkick
{
//    self.hidden = YES;
    [[CHSessionManager sharedInstance] sendSignalingToDeleteDice];
}

#pragma mark - #1diceNums Set方法
-(void)setControlsFrame
{
    
    CGFloat titleTop = 5;
    CGFloat lineTop = 30;
    CGFloat diceTop = 15;
    CGFloat diceWidth = 70;
    
    if ([UIDevice bm_isiPad])
    {
        titleTop = 13;
        lineTop = 40;
        diceTop = 40;
        diceWidth = 100;
    }
    
    [self.cancleBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(titleTop);
        make.right.bmmas_equalTo(-titleTop);
        make.width.height.bmmas_equalTo(20);
    }];
    
    [self.titleLab bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(titleTop);
        make.centerX.bmmas_equalTo(0);
        make.width.bmmas_equalTo(80);
        make.height.bmmas_equalTo(17);
    }];
    
    [self.lineView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(lineTop);
        make.left.right.bmmas_equalTo(0);
        make.height.bmmas_equalTo(1.0);
    }];
    
    [self.animDiceOne bmmas_updateConstraints:^(BMMASConstraintMaker *make) {
        make.width.height.bmmas_equalTo(diceWidth);
        make.centerX.bmmas_equalTo(0);
        make.top.bmmas_equalTo(self.lineView.bmmas_bottom).bmmas_offset(diceTop);
    }];
    
    [self.nameLab bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.bottom.bmmas_equalTo(-7);
        make.right.left.bmmas_equalTo(0);
        make.height.bmmas_equalTo(15);
    }];
}

#pragma mark - #1懒加载

- (UIButton *)cancleBtn
{
    if (!_cancleBtn)
    {
        _cancleBtn = [[UIButton alloc]init];
        [_cancleBtn setImage:YSSkinDefineImage(@"close_btn_icon") forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(diceCancleBtnCkick) forControlEvents:UIControlEventTouchUpInside];
        if (YSCurrentUser.role != CHUserType_Teacher && YSCurrentUser.role != CHUserType_Assistant)
        {
            _cancleBtn.hidden = YES;
        }
    }
    return _cancleBtn;
}

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.font = UI_FONT_12;
        _titleLab.text = YSLocalized(@"title.Dice");
    }
    return _titleLab;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = YSSkinDefineColor(@"lineColor");
    }
    return _lineView;
}

-(UIImageView *)animDiceOne
{
    if(_animDiceOne == nil)
    {
        _animDiceOne = [[UIImageView alloc] init];
        _animDiceOne.animationDuration = AnimationTime;
        _animDiceOne.image = [UIImage imageNamed:@"2.png"];
        _animDiceOne.animationRepeatCount = 1;
        _animDiceOne.animationImages = [self diceAimalImages:ImageNums];
    }
    return _animDiceOne;
}

- (UILabel *)nameLab
{
    if (!_nameLab)
    {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textAlignment = NSTextAlignmentCenter;
        _nameLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
        _nameLab.backgroundColor = [UIColor clearColor];
        _nameLab.font = UI_FONT_10;
        _nameLab.text = YSLocalized(@"Role.Teacher");
    }
    return _nameLab;
}





@end
