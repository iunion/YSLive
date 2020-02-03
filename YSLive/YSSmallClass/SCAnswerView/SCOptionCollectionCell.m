//
//  SCOptionCollectionCell.m
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCOptionCollectionCell.h"

@interface SCOptionCollectionCell ()
@property (nonatomic, strong) UIImageView *optionImg;
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
    [self.contentView addSubview:self.optionImg];
    self.optionImg.frame = CGRectMake(0, 0, self.contentView.bm_width, self.contentView.bm_height);
}

- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    NSString *normalImg = dataDic[@"normalImgs"];
    NSString *selectedImg = dataDic[@"selectedImgs"];
    
    if ([_dataDic[@"isselect"] intValue] == 0)
    {
        [self.optionImg setImage:[UIImage imageNamed:normalImg]];
    }
    else
    {
        [self.optionImg setImage:[UIImage imageNamed:selectedImg]];
    }
}

- (UIImageView *)optionImg
{
    if (!_optionImg)
    {
        _optionImg = [[UIImageView alloc]init];
    }
    
    return _optionImg;
}
@end
