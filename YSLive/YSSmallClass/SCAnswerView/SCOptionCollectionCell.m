//
//  SCOptionCollectionCell.m
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCOptionCollectionCell.h"

@interface SCOptionCollectionCell ()
@property (nonatomic, strong) UILabel *optionLabel;
@end

@implementation SCOptionCollectionCell
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
    [self.contentView addSubview:self.optionLabel];
    self.optionLabel.frame = CGRectMake(0, 0, self.contentView.bm_width, self.contentView.bm_height);
    [self.optionLabel bm_roundedRect:4.0f];
}

- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;

    self.optionLabel.text = dataDic[@"option"];
    if ([_dataDic[@"isselect"] intValue] == 0)
    {
        self.optionLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
        self.optionLabel.backgroundColor = YSSkinDefineColor(@"defaultSelectedBgColor");
    }
    else
    {
        self.optionLabel.textColor = YSSkinDefineColor(@"defaultSelectedBgColor");
        self.optionLabel.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
    }
}

- (UILabel *)optionLabel
{
    if (!_optionLabel)
    {
        _optionLabel = [[UILabel alloc]init];
        _optionLabel.textColor = YSSkinDefineColor(@"defaultSelectedBgColor");
        _optionLabel.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
        _optionLabel.textAlignment = NSTextAlignmentCenter;
        _optionLabel.font = [UIFont systemFontOfSize:40.0f];
    }
    
    return _optionLabel;
}
@end
