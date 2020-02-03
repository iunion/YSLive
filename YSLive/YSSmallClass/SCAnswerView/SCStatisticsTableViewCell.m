//
//  SCStatisticsTableViewCell.m
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCStatisticsTableViewCell.h"
#import "SCAnswerStatisticsModel.h"

@interface SCStatisticsTableViewCell ()
/// 选项内容
@property (nonatomic, strong) UILabel * titleL;
/// 条状图底部view
@property (nonatomic, strong) UIView * backView;
/// 条状图比例
@property (nonatomic, strong) UIView * selectView;
/// 人数
@property (nonatomic, strong) UILabel * numPersonLabel;
@end


@implementation SCStatisticsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.backView];
    [self.contentView addSubview:self.selectView];
    [self.contentView addSubview:self.titleL];
    [self.contentView addSubview:self.numPersonLabel];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat f = 0.0;
    if (_resultModel.total.floatValue == 0.0)
    {
    }
    else
    {
        f =  (_resultModel.number.floatValue) / (_resultModel.total.floatValue);
    }
    
    self.titleL.frame = CGRectMake(20, 0, 25, 17);
    self.titleL.bm_centerY = self.contentView.bm_centerY;
    
    
    self.backView.frame = CGRectMake(CGRectGetMaxX(self.titleL.frame) + 10 , 0, self.bm_width - 55 - 70, 10);
    self.backView.bm_centerY = self.contentView.bm_centerY;
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    self.selectView.frame = CGRectMake(CGRectGetMaxX(self.titleL.frame) + 10, 0, self.backView.bm_width * f, CGRectGetHeight(self.backView.frame));
    self.selectView.bm_centerY = self.contentView.bm_centerY;
    self.selectView.layer.cornerRadius = 5;
    self.selectView.layer.masksToBounds = YES;
    
    self.numPersonLabel.frame = CGRectMake(CGRectGetMaxX(self.backView.frame) + 8, 0, 60, 19);
    self.numPersonLabel.bm_centerY = self.contentView.bm_centerY;
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}


#pragma mark -
#pragma mark SET

- (void)setResultModel:(SCAnswerStatisticsModel *)resultModel
{
    _resultModel = resultModel;
    self.titleL.text = resultModel.title;
    self.numPersonLabel.text =[NSString stringWithFormat:@"%@%@",resultModel.number,YSLocalized(@"tool.ren")];
}


#pragma mark -
#pragma mark Lazy
- (UILabel *)titleL
{
    if (!_titleL)
    {
        _titleL = [[UILabel alloc] init];
        _titleL.backgroundColor = [UIColor whiteColor];
        _titleL.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _titleL.textAlignment = NSTextAlignmentLeft;
        _titleL.font = [UIFont systemFontOfSize:12];
        _titleL.numberOfLines = 0;
    }
    return _titleL;
}

- (UIView *)backView
{
    if (!_backView)
    {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];

    }
    return _backView;
}

- (UIView *)selectView
{
    if (!_selectView)
    {
        _selectView = [[UIView alloc] init];
        _selectView.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC];

    }
    return _selectView;
}

- (UILabel *)numPersonLabel
{
    if (!_numPersonLabel)
    {
        _numPersonLabel = [[UILabel alloc] init];
        _numPersonLabel.backgroundColor = [UIColor whiteColor];
        _numPersonLabel.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _numPersonLabel.textAlignment = NSTextAlignmentLeft;
        _numPersonLabel.font = [UIFont systemFontOfSize:12];
    }
    return _numPersonLabel;
}


@end
