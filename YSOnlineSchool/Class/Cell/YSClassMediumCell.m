//
//  YSClassMediumCell.m
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassMediumCell.h"

@interface YSClassMediumCell ()

@property (nonatomic, strong) YSClassDetailModel *classDetailModel;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation YSClassMediumCell

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
    self.bgView.backgroundColor = [UIColor clearColor];
    
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.topView bm_roundedRect:4.0f];
    
    self.iconView.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    [self.iconView bm_roundedRect:2.0f];

    self.titleLabel.textColor = [UIColor bm_colorWithHex:0x828282];
    self.titleLabel.font = UI_BOLDFONT_16;

    self.bottomView.backgroundColor = [UIColor whiteColor];
}

- (void)drawCellWithModel:(YSClassDetailModel *)classDetailModel
{
    self.classDetailModel = classDetailModel;

    self.titleLabel.text = @"课程简介";
}


@end
