//
//  YSChatMemberListCell.m
//  YSLive
//
//  Created by 马迪 on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSChatMemberListCell.h"

@interface YSChatMemberListCell()
///用户名
@property (nonatomic, strong) UILabel *nickNameLab;
///选中标识
@property (nonatomic, strong) UIImageView * selectImg;
@end

@implementation YSChatMemberListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor             = [UIColor whiteColor];
        [self setupView];
    }
    return self;
}
- (void)setupView
{
    //选中标识
    self.selectImg = [[UIImageView alloc] initWithFrame:CGRectMake(30, 17, 20,20)];
    self.selectImg.image = [UIImage imageNamed:@"member_noSelected"];
    [self.contentView addSubview:_selectImg];
    
    //昵称
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(self.selectImg.bm_right+14, 15, UI_SCREEN_WIDTH-self.selectImg.bm_right-20, 22)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
    self.nickNameLab.textColor =[UIColor bm_colorWithHexString:@"#828282"];
    self.nickNameLab.font = UI_FONT_16;
    [self.contentView addSubview:_nickNameLab];
    
    
    BMSingleLineView * line = [[BMSingleLineView alloc]initWithFrame:CGRectMake(56, 52-1, UI_SCREEN_WIDTH-56-20, 1) direction:SingleLineDirectionLandscape];
    line.needGap = YES;
    [self.contentView addSubview:line];
    
}


- (void)setModel:(YSRoomUser *)model
{
    _model = model;
    self.nickNameLab.text= model.nickName;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (isSelected)
    {
        self.selectImg.image = [UIImage imageNamed:@"member_selected"];
    }
    else
    {
        self.selectImg.image = [UIImage imageNamed:@"member_noSelected"];
    }
}


@end
