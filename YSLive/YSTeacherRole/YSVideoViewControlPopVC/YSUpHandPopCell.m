//
//  YSUpHandPopCell.m
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/17.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSUpHandPopCell.h"

@interface YSUpHandPopCell ()
///用户名
@property (nonatomic, strong) UILabel *nickNameLab;

@end

@implementation YSUpHandPopCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = NSStringFromClass([self class]);
    
    YSUpHandPopCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[YSUpHandPopCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor             = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    //昵称
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 95-10-30, 24)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
    self.nickNameLab.textColor = YSSkinDefineColor(@"Color4");
    self.nickNameLab.font = UI_FONT_14;
    [self.contentView addSubview:_nickNameLab];
            
    //选中标识
    self.headBtn = [[UIButton alloc] initWithFrame:CGRectMake(95-25, 2, 20,18)];
    [self.headBtn addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headBtn setImage:YSSkinElementImage(@"raiseHand_platform", @"iconNor") forState:UIControlStateNormal];
    [self.headBtn setImage:YSSkinElementImage(@"raiseHand_platform", @"iconSel") forState:UIControlStateSelected];
    self.headBtn.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.headBtn];
}

- (void)buttonclick:(UIButton *)sender
{
    if (!sender.selected)
    {
        if (_headButtonClick)
        {
            _headButtonClick();
        }
    }
}

- (void)setUserDict:(NSMutableDictionary *)userDict
{
    _userDict = userDict;
    self.nickNameLab.text = [userDict bm_stringForKey:@"nickName"];
    CHPublishState publishState = [userDict bm_intForKey:@"publishState"];
    if (publishState > 0)
    {
        self.nickNameLab.textColor = YSSkinDefineColor(@"Color4");
        self.headBtn.selected = YES;
    }
    else
    {
        self.nickNameLab.textColor = YSSkinDefineColor(@"Color3");
        self.headBtn.selected = NO;
    }
}

@end
