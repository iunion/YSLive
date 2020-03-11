//
//  SCBoardControlView.m
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCBoardControlView.h"

@interface SCBoardControlView ()

@property (nonatomic, strong) UIButton *allScreenBtn;
@property (nonatomic, strong) UIButton *leftTurnBtn;
@property (nonatomic, strong) UIButton *rightTurnBtn;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIButton *augmentBtn;
@property (nonatomic, strong) UIButton *reduceBtn;
/// 总页数
@property (nonatomic, assign) NSInteger totalPage;
/// 当前页
@property (nonatomic, assign) NSInteger currentPage;

/// 缩放比例
@property (nonatomic, assign) CGFloat zoomScale;

@end


@implementation SCBoardControlView

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
    self.isAllScreen = NO;
    self.allowPaging = YES;
    self.allowScaling = YES;
    self.totalPage = 1;
    self.currentPage = 1;
    self.zoomScale = 1;
    
    self.backgroundColor = [UIColor colorWithRed:222/255.0 green:234/255.0 blue:255/255.0 alpha:0.8];
    [self addSubview:self.allScreenBtn];
    [self.allScreenBtn addTarget:self action:@selector(allScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.leftTurnBtn];
    [self.leftTurnBtn addTarget:self action:@selector(leftTurnBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.rightTurnBtn];
    [self.rightTurnBtn addTarget:self action:@selector(rightTurnBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.pageLabel];
    
    [self addSubview:self.augmentBtn];
    [self.augmentBtn addTarget:self action:@selector(augmentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.reduceBtn];
    [self.reduceBtn addTarget:self action:@selector(reduceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.augmentBtn.enabled = YES;
    self.reduceBtn.enabled  = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BMWeakSelf
    [self.allScreenBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(3);
        make.centerY.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(30);
    }];
    
    [self.leftTurnBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.allScreenBtn.bmmas_right).bmmas_offset(8);
        make.centerY.bmmas_equalTo(0);
        make.width.bmmas_equalTo(17);
        make.height.bmmas_equalTo(25);
    }];
    
    [self.pageLabel bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.leftTurnBtn.bmmas_right).bmmas_offset(5);
        make.centerY.bmmas_equalTo(0);
//        make.right.mas_equalTo(weakSelf.rightTurnBtn.mas_left).offset(-5);
        make.width.bmmas_equalTo(70);
    }];
    
    [self.rightTurnBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.pageLabel.bmmas_right).bmmas_offset(5);
        make.centerY.bmmas_equalTo(0);
        make.width.bmmas_equalTo(17);
        make.height.bmmas_equalTo(25);
    }];
    
    [self.augmentBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.rightTurnBtn.bmmas_right).bmmas_offset(8);
        make.centerY.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(30);
    }];
    
    [self.reduceBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.centerY.bmmas_equalTo(0);
        make.left.bmmas_equalTo(weakSelf.augmentBtn.bmmas_right).bmmas_offset(20);
        make.width.height.bmmas_equalTo(30);
    }];
}


#pragma mark -setter

- (void)sc_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage isWhiteBoard:(BOOL)isWhiteBoard
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
    if (self.allowPaging)
    {
        self.leftTurnBtn.enabled = (_currentPage > 1);
        if (isWhiteBoard)
        {
            self.rightTurnBtn.enabled = YES;
        }
        else
        {
            self.rightTurnBtn.enabled = _currentPage < _totalPage;
        }
    }
    
}

- (void)sc_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage canPrevPage:(BOOL)canPrevPage canNextPage:(BOOL)canNextPage isWhiteBoard:(BOOL)isWhiteBoard
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
    if (self.allowPaging)
    {
        self.leftTurnBtn.enabled = canPrevPage;
        if (isWhiteBoard)
        {
            self.rightTurnBtn.enabled = YES;
        }
        else
        {
            self.rightTurnBtn.enabled =canNextPage;
        }
    }
    
}

- (void)setIsAllScreen:(BOOL)isAllScreen
{
    _isAllScreen = isAllScreen;
    if (isAllScreen)
    {
        [_allScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_normalScreen_normal"] forState:UIControlStateNormal];
        [_allScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_normalScreen_highlighted"] forState:UIControlStateHighlighted];
    }
    else
    {
        [_allScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_allScreen_normal"] forState:UIControlStateNormal];
        [_allScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_allScreen_highlighted"] forState:UIControlStateHighlighted];
    }
}

- (void)setAllowPaging:(BOOL)allowPaging
{
    _allowPaging = allowPaging;
    if (allowPaging)
    {
        self.leftTurnBtn.enabled = (_currentPage > 1);
        self.rightTurnBtn.enabled = _currentPage < _totalPage;
    }
    else
    {
        self.leftTurnBtn.enabled = NO;
        self.rightTurnBtn.enabled = NO;
    }
}

- (void)setAllowScaling:(BOOL)allowScaling
{
    _allowScaling = allowScaling;
    self.augmentBtn.enabled = allowScaling;
    self.reduceBtn.enabled = allowScaling;
}


#pragma mark - SEL

- (void)allScreenBtnClicked:(UIButton *)btn
{
    //全屏 复原
    self.isAllScreen = !self.isAllScreen;
    if ([self.delegate respondsToSelector:@selector(boardControlProxyfullScreen:)])
    {
        [self.delegate boardControlProxyfullScreen:self.isAllScreen];
    }
}

- (void)leftTurnBtnClicked:(UIButton *)btn
{
    self.leftTurnBtn.enabled = (_currentPage > 1);
    self.rightTurnBtn.enabled = _currentPage < _totalPage;
    //左翻页
    if ([self.delegate respondsToSelector:@selector(boardControlProxyPrePage)])
    {
        [self.delegate boardControlProxyPrePage];
    }
}

- (void)rightTurnBtnClicked:(UIButton *)btn
{
    self.leftTurnBtn.enabled = (_currentPage > 1);
    self.rightTurnBtn.enabled = _currentPage < _totalPage;
    //右翻页
    if ([self.delegate respondsToSelector:@selector(boardControlProxyNextPage)])
    {
        [self.delegate boardControlProxyNextPage];
    }
}

- (void)augmentBtnClicked:(UIButton *)btn
{
    // 加
    if ([self.delegate respondsToSelector:@selector(boardControlProxyEnlarge)])
    {
        [self.delegate boardControlProxyEnlarge];
//        self.zoomScale += 0.5f;
//        self.zoomScale = (NSInteger)(ceil(self.zoomScale / 0.5f))*0.5f;
//
//        if (self.zoomScale > LargeNarrowLevelMax)
//        {
//            self.zoomScale = LargeNarrowLevelMax;
//            self.augmentBtn.enabled = NO;
//        }
//        else
//        {
//            self.reduceBtn.enabled = YES;
//            [self.delegate boardControlProxyEnlarge];
//        }
    }
}

- (void)reduceBtnClicked:(UIButton *)btn
{
    // 减
    if ([self.delegate respondsToSelector:@selector(boardControlProxyNarrow)])
    {
        [self.delegate boardControlProxyNarrow];
//        self.zoomScale -= 0.5f;
//        self.zoomScale = (NSInteger)(ceil(self.zoomScale / 0.5f))*0.5f;
//
//        if (self.zoomScale < LargeNarrwoLevelMin)
//        {
//            self.zoomScale = LargeNarrwoLevelMin;
//            self.reduceBtn.enabled = NO;
//        }
//        else
//        {
//            self.augmentBtn.enabled = YES;
//            [self.delegate boardControlProxyNarrow];
//        }
    }
}

- (void)resetBtnStates
{
    self.augmentBtn.enabled = YES;
    self.reduceBtn.enabled = NO;
    [self changeZoomScale:YSWHITEBOARD_MINZOOMSCALE];
}

- (void)changeZoomScale:(CGFloat)zoomScale
{
    if (!self.allowScaling)
    {
        return;
    }
    
    self.zoomScale = zoomScale;

    self.augmentBtn.enabled = YES;
    self.reduceBtn.enabled = YES;
    
    if (self.zoomScale >= YSWHITEBOARD_MAXZOOMSCALE)
    {
        self.zoomScale = YSWHITEBOARD_MAXZOOMSCALE;
        self.augmentBtn.enabled = NO;
    }
    else if (self.zoomScale <= YSWHITEBOARD_MINZOOMSCALE)
    {
        self.zoomScale = YSWHITEBOARD_MINZOOMSCALE;
        self.reduceBtn.enabled  = NO;
    }
}

#pragma mark - Lazy
- (UIButton *)allScreenBtn
{
    if (!_allScreenBtn)
    {
        _allScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_allScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_allScreen_normal"] forState:UIControlStateNormal];
        [_allScreenBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_allScreen_highlighted"] forState:UIControlStateHighlighted];
    }
    return _allScreenBtn;
}

- (UIButton *)leftTurnBtn
{
    if (!_leftTurnBtn)
    {
        _leftTurnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_leftTurn_normal"] forState:UIControlStateNormal];
        [_leftTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_leftTurn_highlighted"] forState:UIControlStateHighlighted];
        [_leftTurnBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_leftTurn_disabled"] forState:UIControlStateDisabled];
        _leftTurnBtn.enabled = NO;
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
        _rightTurnBtn.enabled = NO;
    }
    return _rightTurnBtn;
}

- (UILabel *)pageLabel
{
    if (!_pageLabel)
    {
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.font = [UIFont systemFontOfSize:16];
    }
    
    return _pageLabel;
}

- (UIButton *)augmentBtn
{
    if (!_augmentBtn)
    {
        _augmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_augmentBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_augment_normal"] forState:UIControlStateNormal];
        [_augmentBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_augment_highlighted"] forState:UIControlStateHighlighted];
        [_augmentBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_augment_disabled"] forState:UIControlStateDisabled];
    }
    return _augmentBtn;
}

- (UIButton *)reduceBtn
{
    if (!_reduceBtn)
    {
        _reduceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reduceBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_reduce_normal"] forState:UIControlStateNormal];
        [_reduceBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_reduce_highlighted"] forState:UIControlStateHighlighted];
        [_reduceBtn setImage:[UIImage imageNamed:@"sc_pagecontrol_reduce_disabled"] forState:UIControlStateDisabled];
    }
    return _reduceBtn;
}
@end
