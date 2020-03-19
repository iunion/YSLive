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

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
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
    self.nickNameLab.textColor = [UIColor bm_colorWithHex:0x828282];
    self.nickNameLab.font = UI_FONT_14;
    [self.contentView addSubview:_nickNameLab];
            
    //选中标识
    self.headBtn = [[UIButton alloc] initWithFrame:CGRectMake(95-25, 2, 20,18)];
    [self.headBtn addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headBtn setImage:[UIImage imageNamed:@"downPlatform_hand"] forState:UIControlStateNormal];
    [self.headBtn setImage:[UIImage imageNamed:@"upPlatform_hand"] forState:UIControlStateSelected];
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

//- (void)setUserModel:(YSRoomUser *)userModel
//{
//    _userModel = userModel;
//    self.nickNameLab.text = userModel.nickName;
//    if (userModel.publishState >0)
//    {
//        self.nickNameLab.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
//        self.headBtn.selected = YES;
//    }
//    else
//    {
//        self.nickNameLab.textColor = [UIColor bm_colorWithHex:0x828282];
//        self.headBtn.selected = NO;
//    }
//}

- (void)setUserDict:(NSMutableDictionary *)userDict
{
    _userDict = userDict;
    self.nickNameLab.text = [userDict bm_stringForKey:@"nickName"];
    YSPublishState publishState = [userDict bm_intForKey:@"publishState"];
    if (publishState >0)
    {
        self.nickNameLab.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        self.headBtn.selected = YES;
    }
    else
    {
        self.nickNameLab.textColor = [UIColor bm_colorWithHex:0x828282];
        self.headBtn.selected = NO;
    }
    
}

@end
