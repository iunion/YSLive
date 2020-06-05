//
//  SCAnswerTBHeaderView.m
//  YSLive
//
//  Created by fzxm on 2019/11/21.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCAnswerTBHeaderView.h"
#import "SCAnswerDetailModel.h"

@interface SCAnswerTBHeaderView ()

@property (nonatomic, strong)UIView *backView;
/// 用户名
@property (nonatomic, strong) UILabel *nameL;
/// 答案
@property (nonatomic, strong) UILabel *resultL;
/// 用时
@property (nonatomic, strong) UILabel *timeL;

@end

@implementation SCAnswerTBHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *bacView = [UIView new];
    bacView.backgroundColor = [UIColor clearColor];
    self.backgroundView = bacView;
    
    [self.contentView addSubview:self.backView];
    [self.contentView addSubview:self.nameL];
    [self.contentView addSubview:self.resultL];
    [self.contentView addSubview:self.timeL];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backView.frame = CGRectMake(10 ,0, self.bm_width - 20, 22);
    self.backView.bm_centerY = self.contentView.bm_centerY;

    CGFloat tempWidth = (self.backView.bm_width - 25) / 3.0f;
    self.nameL.frame = CGRectMake(15, 0, tempWidth, 15);
    self.nameL.bm_centerY = self.contentView.bm_centerY;
    
    self.resultL.frame = CGRectMake(CGRectGetMaxX(self.nameL.frame) + 5, 0, tempWidth, 15);
    self.resultL.bm_centerY = self.contentView.bm_centerY;
    
    self.timeL.frame = CGRectMake(CGRectGetMaxX(self.resultL.frame) + 5, 0, tempWidth, 15);
    self.timeL.bm_centerY = self.contentView.bm_centerY;
}


#pragma mark -
#pragma mark SET

- (void)setDetailModel:(SCAnswerDetailModel *)detailModel
{
    _detailModel = detailModel;
    self.nameL.text = detailModel.name;
    self.resultL.text = detailModel.result;
    self.timeL.text = detailModel.time;
}


#pragma mark -
#pragma mark Lazy

- (UIView *)backView
{
    if (!_backView)
    {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

- (UILabel *)nameL
{
    if (!_nameL)
    {
        _nameL = [[UILabel alloc] init];
        _nameL.textAlignment = NSTextAlignmentLeft;
        _nameL.font = UI_FONT_10;
        _nameL.textColor = YSSkinDefineColor(@"defaultTitleColor");
    }
    return _nameL;
}

- (UILabel *)resultL
{
    if (!_resultL)
    {
        _resultL = [[UILabel alloc] init];
        _resultL.textAlignment = NSTextAlignmentCenter;
        _resultL.font = UI_FONT_10;
        _resultL.textColor = YSSkinDefineColor(@"defaultTitleColor");
    }
    return _resultL;
}

- (UILabel *)timeL
{
    if (!_timeL)
    {
        _timeL = [[UILabel alloc] init];
        _timeL.textAlignment = NSTextAlignmentRight;
        _timeL.font = UI_FONT_10;
        _timeL.textColor = YSSkinDefineColor(@"defaultTitleColor");
    }
    return _timeL;
}

@end
