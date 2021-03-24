//
//  YSClassInstructionCell.m
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassInstructionCell.h"

@interface YSClassInstructionCell ()

@property (nonatomic, strong) YSClassDetailModel *classDetailModel;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation YSClassInstructionCell

- (void)dealloc
{
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self makeCellStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)makeCellStyle
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.bgView.backgroundColor = [UIColor clearColor];
    
    self.topView.backgroundColor = YSSkinOnlineDefineColor(@"defaultTitleColor");
    [self.topView bm_roundedRect:6.0f];
    
    self.iconView.backgroundColor = YSSkinOnlineDefineColor(@"onlineSchoolClassIconColor");
    [self.iconView bm_roundedRect:2.0f];

    self.titleLabel.textColor = YSSkinOnlineDefineColor(@"placeholderColor");
    self.titleLabel.font = UI_BOLDFONT_16;

    self.bottomView.backgroundColor = [UIColor whiteColor];
    self.detailLabel.textColor = YSSkinOnlineDefineColor(@"onlineSchoolSubTextColor");
    self.detailLabel.font = UI_FONT_12;
}

- (void)drawCellWithModel:(YSClassDetailModel *)classDetailModel
{
    self.classDetailModel = classDetailModel;

    self.titleLabel.text = YSLocalizedSchool(@"ClassInstructionCell.Title");
    
    self.detailLabel.text = classDetailModel.classInstruction;
    
    if ([classDetailModel.classReplayList bm_isNotEmpty])
    {
        [self.bottomView bm_removeBorders];
    }
    else
    {
        [self.bottomView bm_roundedRect:6.0f];
    }
}

@end
