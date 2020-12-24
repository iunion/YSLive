//
//  YSSetTableViewCell.m
//  YSAll
//
//  Created by 马迪 on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSetTableViewCell.h"

@interface YSSetTableViewCell ()

@property(nonatomic,weak)UIView *bgView;

///行标题
@property(nonatomic,weak)UILabel * cellTitleLab;

///箭头
@property(nonatomic,weak)UIImageView * arrowImg;

@end

@implementation YSSetTableViewCell

/**
 *  快速创建tableViewCell
 *
 *  @param tableView tableView description
 *
 *  @return <#return value description#>
 */
+ (instancetype)setTableViewCellWithTableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = NSStringFromClass([self class]);
    YSSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[YSSetTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        // 创建子控件
        [self createSubViews];
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)createSubViews
{
    UIView *bgView = [[UIView alloc]init];
    self.bgView = bgView;
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    
    bgView.layer.cornerRadius = 6;
    bgView.layer.shadowColor = [UIColor bm_colorWithHex:0x000000 alpha:0.15].CGColor;
    bgView.layer.shadowOffset = CGSizeMake(0,0);
    
    //行标题
    UILabel * cellTitleLab = [[UILabel alloc]init];
    [cellTitleLab sizeToFit];
    cellTitleLab.font = UI_FONT_14;
    cellTitleLab.textColor = YSSkinDefineColor(@"PlaceholderColor");
    self.cellTitleLab = cellTitleLab;
    [bgView addSubview:cellTitleLab];
        
    //右箭头
    UIImageView * arrowImg = [[UIImageView alloc]initWithImage:YSSkinElementImage(@"set_arrow", @"iconNor")];
    self.arrowImg = arrowImg;
    [bgView addSubview:arrowImg];
//    arrowImg.hidden = YES;
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.cellTitleLab.text = titleText;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
 
    [self.bgView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(2);
        make.left.bmmas_equalTo(18);
        make.bottom.bmmas_equalTo(-2);
        make.right.bmmas_equalTo(-18);
    }];
    
    [self.arrowImg bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.right.bmmas_equalTo(-15);
        make.width.height.bmmas_equalTo(20);
        make.centerY.bmmas_equalTo(self.contentView);
    }];
    
    [self.cellTitleLab bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(15);
        make.right.bmmas_equalTo(self.arrowImg.bmmas_left).bmmas_offset(10);
        make.centerY.bmmas_equalTo(self.contentView);
    }];
}

@end
