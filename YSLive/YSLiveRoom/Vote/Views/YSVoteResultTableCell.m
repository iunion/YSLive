//
//  YSVoteResultTableCell.m
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSVoteResultTableCell.h"
#import "YSVoteModel.h"
@interface YSVoteResultTableCell()
/// 选项内容
@property (nonatomic, strong) UILabel * titleL;
/// 条状图底部view
@property (nonatomic, strong) UIView * backView;
/// 条状图比例
@property (nonatomic, strong) UIView * selectView;
/// 人数
@property (nonatomic, strong) UILabel * numPersonLabel;
@end

@implementation YSVoteResultTableCell


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
    
    
    self.titleL.frame = CGRectMake(30, 8, BMUI_SCREEN_WIDTH - 30 - 30, _resultModel.endCellHeight);
    
    self.backView.frame = CGRectMake(30, CGRectGetMaxY(self.titleL.frame) + 5 , BMUI_SCREEN_WIDTH - 30 - 30, 18);
    self.backView.layer.cornerRadius = 9;
    self.backView.layer.masksToBounds = YES;
    
    self.selectView.frame = CGRectMake(30, CGRectGetMaxY(self.titleL.frame) + 5, self.backView.bm_width * f, 18);
    self.selectView.layer.cornerRadius = 9;
    self.selectView.layer.masksToBounds = YES;
   
    self.numPersonLabel.frame = CGRectMake(0, 0, 32, 15);
    self.numPersonLabel.bm_centerY = self.backView.bm_centerY;
    self.numPersonLabel.bm_right = self.backView.bm_right - 10;
    if (f > 0.9 )
    {
        self.numPersonLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
    }
   
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
- (void)setResultModel:(YSVoteResultModel *)resultModel
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
        _titleL.textColor = YSSkinDefineColor(@"placeholderColor");
        _titleL.textAlignment = NSTextAlignmentLeft;
        _titleL.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12);
        _titleL.numberOfLines = 0;
    }
    return _titleL;
}

- (UIView *)backView
{
    if (!_backView)
    {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = YSSkinDefineColor(@"timer_timeBgColor");
    }
    return _backView;
}

- (UIView *)selectView
{
    if (!_selectView)
    {
        _selectView = [[UIView alloc] init];
        _selectView.backgroundColor = YSSkinDefineColor(@"defaultSelectedBgColor");

    }
    return _selectView;
}

- (UILabel *)numPersonLabel
{
    if (!_numPersonLabel)
    {
        _numPersonLabel = [[UILabel alloc] init];
        _numPersonLabel.textColor = YSSkinDefineColor(@"placeholderColor");
        _numPersonLabel.textAlignment = NSTextAlignmentRight;
        _numPersonLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12);
    }
    return _numPersonLabel;
}
@end
