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
///选中标识
@property (nonatomic, strong) UIImageView * headImage;
@end

@implementation YSUpHandPopCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    NSString *reuseIdentifier = NSStringFromClass([self class]);
    
    YSUpHandPopCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        
        cell = [[YSUpHandPopCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor             = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    
    //昵称
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 95-10-24, 24)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
    self.nickNameLab.textColor =[UIColor bm_colorWithHexString:@"#828282"];
    self.nickNameLab.font = UI_FONT_16;
    [self.contentView addSubview:_nickNameLab];
    
    //选中标识
    self.headImage = [[UIImageView alloc] initWithFrame:CGRectMake(95-30, 2, 20,20)];
    self.headImage.image = [UIImage imageNamed:@"member_noSelected"];
    [self.contentView addSubview:self.headImage];
    
}

- (void)setDataDict:(NSDictionary *)dataDict
{
    _dataDict = dataDict;
    self.nickNameLab.text = [dataDict bm_stringForKey:@"nickName"];
    
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:[dataDict bm_stringForKey:@"headImage"]] placeholderImage:[UIImage imageNamed:@"login_name"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
}

@end
