//
//  SCAnswerPageView.m
//  YSLive
//
//  Created by fzxm on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCAnswerPageView.h"

@interface SCAnswerPageView ()
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIButton *leftTurnBtn;
@property (nonatomic, strong) UIButton *rightTurnBtn;
/// 总页数
@property (nonatomic, assign) NSInteger totalPage;
/// 当前页
@property (nonatomic, assign) NSInteger currentPage;
@end


@implementation SCAnswerPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.allowPaging = YES;
    self.totalPage = 1;
    self.currentPage = 1;
    
    self.backgroundColor = [UIColor colorWithRed:222/255.0 green:234/255.0 blue:255/255.0 alpha:0.8];
    
    [self addSubview:self.pageLabel];
    
    [self addSubview:self.leftTurnBtn];
    [self.leftTurnBtn addTarget:self action:@selector(leftTurnBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.rightTurnBtn];
    [self.rightTurnBtn addTarget:self action:@selector(rightTurnBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BMWeakSelf
    [self.leftTurnBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(5);
        make.centerY.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(25);
    }];
    
    [self.rightTurnBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.centerY.bmmas_equalTo(0);
        make.right.bmmas_equalTo(-5);
        make.width.height.bmmas_equalTo(25);
    }];
    [self.pageLabel bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.leftTurnBtn.bmmas_right).bmmas_offset(5);
        make.centerY.bmmas_equalTo(0);
        make.right.bmmas_equalTo(weakSelf.rightTurnBtn.bmmas_left).bmmas_offset(-5);
    }];
}

-(void)scAnswer_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage
{
    _totalPage = total;
    if (_totalPage < 1)
    {
        _totalPage = 1;
    }
    
    _currentPage = currentPage;
    if (_currentPage < 1)
    {
        _currentPage = 1;
    }
    _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",(long)_currentPage,(long)self.totalPage];
    self.leftTurnBtn.enabled = _currentPage != 1 ;
    self.rightTurnBtn.enabled = _currentPage < _totalPage;
}

- (void)leftTurnBtnClicked:(UIButton *)btn
{
    self.leftTurnBtn.enabled = _currentPage != 1 ;
    self.rightTurnBtn.enabled = _currentPage < _totalPage;
    //左翻页
    if (self.pageBlock)
    {
        self.pageBlock(_currentPage, 1);
    }
}

- (void)rightTurnBtnClicked:(UIButton *)btn
{
    self.leftTurnBtn.enabled = _currentPage != 1 ;
    self.rightTurnBtn.enabled = _currentPage < _totalPage;
    //右翻页
    if (self.pageBlock)
    {
        self.pageBlock(_currentPage, 2);
    }
}
#pragma mark - lazy
- (UILabel *)pageLabel
{
    if (!_pageLabel)
    {
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.font = [UIFont systemFontOfSize:12];
    }
    
    return _pageLabel;
}

- (UIButton *)leftTurnBtn
{
    if (!_leftTurnBtn)
    {
        _leftTurnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_leftTurn_normal"] forState:UIControlStateNormal];
        [_leftTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_leftTurn_highlighted"] forState:UIControlStateHighlighted];
        [_leftTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_leftTurn_disabled"] forState:UIControlStateDisabled];
    }
    return _leftTurnBtn;
}

- (UIButton *)rightTurnBtn
{
    if (!_rightTurnBtn)
    {
        _rightTurnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_rightTurn_normal"] forState:UIControlStateNormal];
        [_rightTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_rightTurn_highlighted"] forState:UIControlStateHighlighted];
        [_rightTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_rightTurn_disabled"] forState:UIControlStateDisabled];
    }
    return _rightTurnBtn;
}
@end
