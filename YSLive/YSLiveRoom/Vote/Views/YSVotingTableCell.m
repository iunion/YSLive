//
//  YSRotingTableViewCell.m
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSVotingTableCell.h"
#import "YSVoteModel.h"

@interface YSVotingTableCell()
@property (nonatomic, strong) UIImageView * selectImageV;
/// 选项内容
@property (nonatomic, strong) UILabel * titleL;
/// view
@property (nonatomic, strong) UIView * lineView;

@end

@implementation YSVotingTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.selectImageV];
    [self.contentView addSubview:self.titleL];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor bm_colorWithHex:0xEEF0F3];
    self.selectImageV.frame = CGRectMake(22, 0, 17, 17);
    self.selectImageV.bm_centerY = self.contentView.bm_centerY;

    self.titleL.frame = CGRectMake(CGRectGetMaxX(self.selectImageV.frame) + 22 , 0, BMUI_SCREEN_WIDTH - CGRectGetMaxX(self.selectImageV.frame) - 22 - 5 - 10, _votingModel.ingCellHeight);
    self.titleL.bm_centerY = self.contentView.bm_centerY;
    self.lineView.frame = CGRectMake(56, 0, BMUI_SCREEN_WIDTH - 56 - 20, 1);
    self.lineView.bm_bottom = self.contentView.bm_bottom;
}


#pragma mark -
#pragma mark SET
- (void)setVotingModel:(YSVoteResultModel *)votingModel
{
    _votingModel = votingModel;
    self.titleL.text = votingModel.title;
    
    NSString * imgName = @"";
//    if (self.isSingle)
//    {
    imgName = votingModel.isSelect ? @"vote_single_select" : @"vote_single_normal";
      
//    }
//    else
//    {
//        imgName = votingModel.isSelect ? @"vote_multi_select" : @"vote_multi_normal";
//
//    }
    [_selectImageV setImage:[UIImage imageNamed:imgName]];
}


#pragma mark -
#pragma mark LZAY
- (UIImageView *)selectImageV
{
    if (!_selectImageV)
    {
        _selectImageV = [[UIImageView alloc] init];
    }
    return _selectImageV;
}
- (UILabel *)titleL
{
    if (!_titleL)
    {
        _titleL = [[UILabel alloc] init];
        _titleL.backgroundColor = [UIColor clearColor];
        _titleL.textColor = YSColor_VoteTime;
        _titleL.textAlignment = NSTextAlignmentLeft;
        _titleL.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 16);
        _titleL.numberOfLines = 0;
    }
    return _titleL;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor bm_colorWithHex:0xEEEEEE];

    }
    return _lineView;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
