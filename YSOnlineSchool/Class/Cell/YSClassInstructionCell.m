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
@property (nonatomic, assign) CGFloat cellHeight;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

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
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];

//    [self.iconImageView bm_roundedRect:4.0f];
//    
//    self.titleLabel.textColor = [UIColor bm_colorWithHex:0x828282];
//    self.titleLabel.font = UI_BOLDFONT_16;
//
//    self.nameLabel.textColor = [UIColor bm_colorWithHex:0x9F9F9F];
//    self.nameLabel.font = UI_BOLDFONT_12;
//    self.gistLabel.textColor = [UIColor bm_colorWithHex:0x9F9F9F];
//    self.gistLabel.font = UI_BOLDFONT_12;
//
//    [self.enterBtn bm_roundedRect:self.enterBtn.bm_height * 0.5f];
//    self.enterBtn.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
//    
//    self.timeLabel.textColor = [UIColor bm_colorWithHex:0x9F9F9F];
//    self.timeLabel.font = UI_BOLDFONT_12;
//
//    self.stateLabel.textColor = [UIColor whiteColor];
//    self.stateLabel.font = UI_BOLDFONT_12;
//    [self.stateLabel bm_roundedRect:self.stateLabel.bm_height * 0.5f];
}

- (void)drawCellWithModel:(YSClassDetailModel *)classDetailModel
{
    
}

@end
