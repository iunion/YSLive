//
//  YSOnlineMineTableViewCell.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/7.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSOnlineMineTableViewCell.h"

@interface YSOnlineMineTableViewCell ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UIImageView *signImage;

@end

@implementation YSOnlineMineTableViewCell

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
    
    self.lineView = [[UIView alloc] init];
    [self.contentView addSubview:self.lineView];
    self.lineView.backgroundColor = [UIColor bm_colorWithHex:0x6D7278];
//    self.lineView.frame = CGRectMake(15, 0, self.bm_width - 30, 1);
    
    self.titleL = [[UILabel alloc] init];
    [self.contentView addSubview:self.titleL];
    self.titleL.font = [UIFont systemFontOfSize:14.0f];
    self.titleL.textColor = [UIColor bm_colorWithHex:0x828282];
    self.titleL.textAlignment = NSTextAlignmentLeft;
//    self.titleL.frame = CGRectMake(20, 0, self.bm_width - 40, 20);
//    self.titleL.bm_centerY = self.contentView.bm_centerY;
    
    self.signImage = [[UIImageView alloc] init];
//    self.signImage.frame = CGRectMake(0, 0, 14, 14);
//    self.signImage.bm_centerY = self.contentView.bm_centerY;
//    self.signImage.bm_right = self.contentView.bm_right - 20;
    [self.contentView addSubview:self.signImage];
    [self.signImage setImage:[UIImage imageNamed:@"mine_fanhui"]];
    _signImage.contentMode = UIViewContentModeCenter;
    
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lineView.frame = CGRectMake(15, 0, self.bm_width - 30, 1);
    self.titleL.frame = CGRectMake(20, 0, self.bm_width - 40, 20);
    self.titleL.bm_centerY = self.contentView.bm_centerY;
    self.signImage.frame = CGRectMake(0, 0, 14, 14);
    self.signImage.bm_centerY = self.contentView.bm_centerY;
    self.signImage.bm_right = self.contentView.bm_right - 20;
}
- (void)setTitle:(NSString *)title
{
    self.titleL.text = title;
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
