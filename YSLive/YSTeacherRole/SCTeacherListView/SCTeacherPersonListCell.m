//
//  SCTeacherPersonListCell.m
//  YSLive
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTeacherPersonListCell.h"

@interface SCTeacherPersonListCell ()

/// 学生登录设备标识
@property (nonatomic, strong) UIImageView *iconImgView;
/// 学生姓名
@property (nonatomic, strong) UILabel *nameLabel;
/// 上下台
@property (nonatomic, strong) UIButton *upPlatformBtn;
/// 发言 禁言
@property (nonatomic, strong) UIButton *speakBtn;
/// 踢出
@property (nonatomic, strong) UIButton *outBtn;

/// 奖杯数
@property (nonatomic, strong) UIButton *cupButton;

@property (nonatomic, assign) CHUserRoleType userRoleType;
@end

@implementation SCTeacherPersonListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setup];
    }
    return self;
}


- (void)setup
{
    UIImageView *iconImgView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImgView];
    self.iconImgView = iconImgView;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIDevice bm_isiPad] ? UI_FONT_14 : UI_FONT_12;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = YSSkinDefineColor(@"Color3");
    
    UIButton *cupButton = [[UIButton alloc]init];
    [self.contentView addSubview:cupButton];
    [cupButton setBackgroundColor:YSSkinDefineColor(@"Color6")];
    self.cupButton = cupButton;
    UIImage *cup = [YSSkinElementImage(@"nameList_cup", @"iconNor") bm_imageWithTintColor:YSSkinDefineColor(@"Color10")];
    [cupButton setImage:cup forState:UIControlStateNormal];
    [cupButton setTitleColor:YSSkinDefineColor(@"Color10") forState:UIControlStateNormal];
    cupButton.titleLabel.font = [UIDevice bm_isiPad] ? UI_FONT_15 : UI_FONT_12;
    cupButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    cupButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
      
    UIButton *upPlatformBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:upPlatformBtn];
    self.upPlatformBtn = upPlatformBtn;
    [upPlatformBtn setImage:YSSkinElementImage(@"nameList_updown", @"iconNor") forState:UIControlStateNormal];
    [upPlatformBtn setImage:YSSkinElementImage(@"nameList_updown", @"iconSel") forState:UIControlStateSelected];
    UIImage * upPlatformDisImage = [YSSkinElementImage(@"nameList_updown", @"iconSel") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [upPlatformBtn setImage:upPlatformDisImage forState:UIControlStateDisabled];
    [upPlatformBtn addTarget:self action:@selector(upPlatformBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *speakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:speakBtn];
    self.speakBtn = speakBtn;
    [speakBtn setImage:YSSkinElementImage(@"nameList_speak", @"iconNor") forState:UIControlStateNormal];
    [speakBtn setImage:YSSkinElementImage(@"nameList_speak", @"iconSel") forState:UIControlStateSelected];
    UIImage * speakDisImage = [YSSkinElementImage(@"nameList_speak", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [speakBtn setImage:speakDisImage forState:UIControlStateDisabled];
    [speakBtn addTarget:self action:@selector(speakBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *outBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:outBtn];
    self.outBtn = outBtn;
    [outBtn setImage:YSSkinElementImage(@"nameList_out", @"iconNor") forState:UIControlStateNormal];
    [outBtn setImage:YSSkinElementImage(@"nameList_out", @"iconSel") forState:UIControlStateSelected];
    UIImage * outDisImage = [YSSkinElementImage(@"nameList_out", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [outBtn setImage:outDisImage forState:UIControlStateDisabled];
    [outBtn addTarget:self action:@selector(outBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([UIDevice bm_isiPad])
    {
        self.iconImgView.frame = CGRectMake(20, 0, 36, 36);
        self.iconImgView.bm_centerY = self.contentView.bm_centerY;
        
        self.outBtn.frame = CGRectMake(0, 0, 26, 26);
        self.outBtn.bm_centerY = self.contentView.bm_centerY;
        self.outBtn.bm_right = self.contentView.bm_right - 20;
        
        self.speakBtn.frame = CGRectMake(0, 0, 26, 26);
        self.speakBtn.bm_centerY = self.contentView.bm_centerY;
        self.speakBtn.bm_right = self.outBtn.bm_left - 20;
        
        self.upPlatformBtn.frame = CGRectMake(0, 0, 26, 26);
        self.upPlatformBtn.bm_centerY = self.contentView.bm_centerY;
        self.upPlatformBtn.bm_right = self.speakBtn.bm_left - 20;
        
        self.cupButton.frame = CGRectMake(0, 0, 70, 26);
        self.cupButton.bm_centerY = self.contentView.bm_centerY;
        self.cupButton.bm_right = self.upPlatformBtn.bm_left - 10;
        self.cupButton.layer.cornerRadius = 13;

        self.nameLabel.frame = CGRectMake(0, 0, 10, 26);
        [self.nameLabel bm_setLeft:self.iconImgView.bm_right + 10 right:self.cupButton.bm_left - 10];
        self.nameLabel.bm_centerY = self.contentView.bm_centerY;
    }
    else
    {
        self.iconImgView.frame = CGRectMake(12, 0, 24, 24);
        self.iconImgView.bm_centerY = self.contentView.bm_centerY;
        self.nameLabel.font = [UIFont systemFontOfSize:12.0];
        self.nameLabel.frame = CGRectMake(0, 0, 60, 20);
//        [self.nameLabel bm_setLeft:self.iconImgView.bm_right + 5 right:self.upPlatformBtn.bm_left - 5];
        self.nameLabel.bm_centerY = self.contentView.bm_centerY;
        self.nameLabel.bm_left = self.iconImgView.bm_right + 5;
        
        self.cupButton.frame = CGRectMake(0, 0, 60, 24);
        self.cupButton.bm_centerY = self.contentView.bm_centerY;
        self.cupButton.bm_left = self.nameLabel.bm_right;
        self.cupButton.layer.cornerRadius = 12;

        self.outBtn.frame = CGRectMake(0, 0, 20, 20);
        self.outBtn.bm_centerY = self.contentView.bm_centerY;
        self.outBtn.bm_right = self.contentView.bm_right - 10;
        
        self.speakBtn.frame = CGRectMake(0, 0, 20, 20);
        self.speakBtn.bm_centerY = self.contentView.bm_centerY;
        self.speakBtn.bm_right = self.outBtn.bm_left - 10;
        
        self.upPlatformBtn.frame = CGRectMake(0, 0, 20, 20);
        self.upPlatformBtn.bm_centerY = self.contentView.bm_centerY;
        self.upPlatformBtn.bm_right = self.speakBtn.bm_left - 10;
    }
}

- (void)setUserModel:(CHRoomUser *)userModel
{
    _userModel = userModel;

    NSString *imageName = @"nameList_OtherDevice";
    NSString *devicetype = [[userModel.properties bm_stringTrimForKey:@"devicetype"] lowercaseString];
    if ([devicetype isEqualToString:@"androidpad"])
    {
        imageName = @"nameList_AndroidPad";
    }
    else if ([devicetype isEqualToString:@"androidphone"])
    {
        imageName = @"nameList_AndroidPhone";
    }
    else if ([devicetype isEqualToString:@"ipad"])
    {
        imageName = @"nameList_ipad";
    }
    else if ([devicetype isEqualToString:@"iphone"])
    {
        imageName = @"nameList_iphone";
    }
    else if ([devicetype isEqualToString:@"macpc"])
    {
        imageName = @"nameList_MacExplorer";
    }
    else if ([devicetype isEqualToString:@"macclient"])
    {
        imageName = @"nameList_MacClient";
    }
    else if ([devicetype isEqualToString:@"windowpc"])
    {
        imageName = @"nameList_WindowsExplorer";
    }
    else if ([devicetype isEqualToString:@"windowclient"])
    {
        imageName = @"nameList_WindowsClient";
    }
    
    BOOL isBeginClass = [YSLiveManager sharedInstance].isClassBegin;
    
    if (userModel.role == CHUserType_Student )
    {
        if (isBeginClass)
        {
            self.upPlatformBtn.selected = (userModel.publishState == CHUser_PublishState_UP);
        }
        else
        {
//            self.upPlatformBtn.selected = NO;
        }
        BOOL disablechat = [userModel.properties bm_boolForKey:sCHUserDisablechat];
        self.speakBtn.selected = disablechat;
    }
    self.upPlatformBtn.enabled = isBeginClass;
    self.outBtn.enabled = isBeginClass;
    self.nameLabel.text = userModel.nickName;
    [self.iconImgView setImage:YSSkinElementImage(imageName, @"iconNor")];
    
    NSInteger giftNumber = [userModel.properties bm_uintForKey:sCHUserGiftNumber];
     
    NSString *cupNum = [NSString stringWithFormat:@"x %@",giftNumber <= 99 ? @(giftNumber) : @"99+"];
    [self.cupButton setTitle:cupNum forState:UIControlStateNormal];

    self.cupButton.hidden = NO;
    
    if (userModel.role == CHUserType_Assistant )
    {
        self.upPlatformBtn.enabled = NO;
        self.outBtn.enabled = NO;
        self.speakBtn.enabled = NO;
        self.cupButton.hidden = YES;
    }
    else
    {
        self.cupButton.hidden = NO;
    }

}
- (void)setUserRole:(CHUserRoleType)userRoleType
{
    if (userRoleType ==  CHUserType_Patrol)
    {
        _userRoleType = userRoleType;
    }
}
- (void)upPlatformBtnClicked:(UIButton *)btn
{
//    btn.selected = !btn.selected;
    if (_userRoleType ==  CHUserType_Patrol)
    {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(upPlatformBtnProxyClickWithRoomUser:)])
    {
        [self.delegate upPlatformBtnProxyClickWithRoomUser:self.userModel];
    }
}

- (void)speakBtnClicked:(UIButton *)btn
{
    if (_userRoleType ==  CHUserType_Patrol)
    {
        return;
    }
    btn.selected = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(speakBtnProxyClickWithRoomUser:)])
    {
        [self.delegate speakBtnProxyClickWithRoomUser:self.userModel];
    }
}

- (void)outBtnClicked:(UIButton *)btn
{
    if (_userRoleType ==  CHUserType_Patrol)
    {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(outBtnProxyClickWithRoomUser:)])
    {
        [self.delegate outBtnProxyClickWithRoomUser:self.userModel];
    }
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
