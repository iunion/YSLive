//
//  YSMonthListCell.m
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/26.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMonthListCell.h"

@implementation YSMonthListCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120-2*13-6, 33)];
        titleLab.font = UI_FONT_15;
        titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab = titleLab;
        [self.contentView addSubview:titleLab];
    }
    return self;
}


@end
