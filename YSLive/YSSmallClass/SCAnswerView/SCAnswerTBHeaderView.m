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
@property (nonatomic, strong) UILabel * nameL;
/// 答案
@property (nonatomic, strong) UILabel * resultL;
/// 用时
@property (nonatomic, strong) UILabel * timeL;

@end

@implementation SCAnswerTBHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.backView];
    [self.contentView addSubview:self.nameL];
    [self.contentView addSubview:self.resultL];
    [self.contentView addSubview:self.timeL];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backView.frame = CGRectMake(15 ,0, self.bm_width - 30, 22);
    self.backView.bm_centerY = self.contentView.bm_centerY;
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    self.nameL.frame = CGRectMake(40, 0, 130, 15);
    self.nameL.bm_centerY = self.contentView.bm_centerY;
    
    self.resultL.frame = CGRectMake(CGRectGetMaxX(self.nameL.frame) + 10, 0, 110, 15);
    self.resultL.bm_centerY = self.contentView.bm_centerY;\
    
    self.timeL.frame = CGRectMake(CGRectGetMaxX(self.resultL.frame) + 10, 0, self.contentView.bm_width - self.timeL.bm_left - 5 - 10, 15);
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
        _backView.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
    }
    return _backView;
}

- (UILabel *)nameL
{
    if (!_nameL)
    {
        _nameL = [[UILabel alloc] init];
        _nameL.textAlignment = NSTextAlignmentLeft;
        _nameL.font = [UIFont systemFontOfSize:12];
        _nameL.numberOfLines = 0;
        _nameL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    }
    return _nameL;
}
- (UILabel *)resultL
{
    if (!_resultL)
    {
        _resultL = [[UILabel alloc] init];
        _resultL.textAlignment = NSTextAlignmentLeft;
        _resultL.font = [UIFont systemFontOfSize:12];
        _resultL.numberOfLines = 0;
        _resultL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    }
    return _resultL;
}
- (UILabel *)timeL
{
    if (!_timeL)
    {
        _timeL = [[UILabel alloc] init];
        _timeL.textAlignment = NSTextAlignmentLeft;
        _timeL.font = [UIFont systemFontOfSize:12];
        _timeL.numberOfLines = 0;
        _timeL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    }
    return _timeL;
}

@end
