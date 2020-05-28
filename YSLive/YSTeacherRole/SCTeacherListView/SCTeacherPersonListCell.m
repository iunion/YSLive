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
@property (nonatomic, strong) UIView *cupView;
/// 奖杯图片
@property (nonatomic, strong) UIImageView *cupImgView;
/// 奖杯数
@property (nonatomic, strong) UILabel *cupNumberLabel;
//@property (nonatomic, strong) YSRoomUser *userModel;
@property (nonatomic, assign) YSUserRoleType userRoleType;
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
    nameLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
    
    UIView *cupView = [[UIView alloc] init];
    [self.contentView addSubview:cupView];
    self.cupView = cupView;
    cupView.backgroundColor = YSSkinDefineColor(@"placeholderColor");
    
    UIImageView *cupImgView = [[UIImageView alloc] init];
    [self.contentView addSubview:cupImgView];
    self.cupImgView = cupImgView;
    [self.cupImgView setImage:YSSkinElementImage(@"nameList_cup", @"iconNor")];
    
    UILabel *cupNumberLabel = [[UILabel alloc] init];
    [self.contentView addSubview:cupNumberLabel];
    self.cupNumberLabel = cupNumberLabel;
    cupNumberLabel.font = [UIDevice bm_isiPad] ? UI_FONT_12 : UI_FONT_8;
    cupNumberLabel.textAlignment = NSTextAlignmentLeft;
    cupNumberLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
      
    UIButton *upPlatformBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:upPlatformBtn];
    self.upPlatformBtn = upPlatformBtn;
    [upPlatformBtn setBackgroundImage:YSSkinElementImage(@"nameList_updown", @"iconNor") forState:UIControlStateNormal];
    [upPlatformBtn setBackgroundImage:YSSkinElementImage(@"nameList_updown", @"iconSel") forState:UIControlStateSelected];
    UIImage * upPlatformDisImage = [YSSkinElementImage(@"nameList_updown", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [upPlatformBtn setImage:upPlatformDisImage forState:UIControlStateDisabled];
    [upPlatformBtn addTarget:self action:@selector(upPlatformBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *speakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:speakBtn];
    self.speakBtn = speakBtn;
    [speakBtn setBackgroundImage:YSSkinElementImage(@"nameList_speak", @"iconNor") forState:UIControlStateNormal];
    [speakBtn setBackgroundImage:YSSkinElementImage(@"nameList_speak", @"iconSel") forState:UIControlStateSelected];
    UIImage * speakDisImage = [YSSkinElementImage(@"nameList_speak", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [speakBtn setImage:speakDisImage forState:UIControlStateDisabled];
    [speakBtn addTarget:self action:@selector(speakBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *outBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:outBtn];
    self.outBtn = outBtn;
    [outBtn setBackgroundImage:YSSkinElementImage(@"nameList_out", @"iconNor") forState:UIControlStateNormal];
    [outBtn setBackgroundImage:YSSkinElementImage(@"nameList_out", @"iconSel") forState:UIControlStateSelected];
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
        
        
        self.cupView.frame = CGRectMake(0, 0, 70, 26);
        self.cupView.bm_centerY = self.contentView.bm_centerY;
        self.cupView.bm_right = self.upPlatformBtn.bm_left - 10;
        self.cupView.layer.cornerRadius = 13;
        
        self.cupImgView.frame = CGRectMake(6, 0, 16, 16);
        self.cupImgView.bm_centerY = self.contentView.bm_centerY;
        self.cupImgView.bm_left = self.cupView.bm_left + 6;
        
        self.cupNumberLabel.frame = CGRectMake(0, 0, 65, 22);
        self.cupNumberLabel.bm_centerY = self.cupView.bm_centerY;
        self.cupNumberLabel.bm_left = self.cupImgView.bm_right + 4;
        self.cupNumberLabel.font = [UIFont systemFontOfSize:15.0f];
        
        self.nameLabel.frame = CGRectMake(0, 0, 10, 26);
        [self.nameLabel bm_setLeft:self.iconImgView.bm_right + 10 right:self.cupView.bm_left - 10];
        self.nameLabel.bm_centerY = self.contentView.bm_centerY;
    }
    else
    {
        self.iconImgView.frame = CGRectMake(12, 0, 24, 24);
        self.iconImgView.bm_centerY = self.contentView.bm_centerY;
        self.cupNumberLabel.font = [UIFont systemFontOfSize:12.0f];
        self.nameLabel.font = [UIFont systemFontOfSize:12.0];
        self.nameLabel.frame = CGRectMake(0, 0, 60, 20);
//        [self.nameLabel bm_setLeft:self.iconImgView.bm_right + 5 right:self.upPlatformBtn.bm_left - 5];
        self.nameLabel.bm_centerY = self.contentView.bm_centerY;
        self.nameLabel.bm_left = self.iconImgView.bm_right + 5;
        
        self.cupView.frame = CGRectMake(0, 0, 60, 24);
        self.cupView.bm_centerY = self.contentView.bm_centerY;
        self.cupView.bm_left = self.nameLabel.bm_right;
        self.cupView.layer.cornerRadius = 12;
        
        self.cupImgView.frame = CGRectMake(6, 0, 16, 16);
        self.cupImgView.bm_centerY = self.contentView.bm_centerY;
        self.cupImgView.bm_left = self.cupView.bm_left + 6;
        
        self.cupNumberLabel.frame = CGRectMake(0, 0, 44, 22);
        self.cupNumberLabel.bm_centerY = self.cupView.bm_centerY;
        self.cupNumberLabel.bm_left = self.cupImgView.bm_right + 4;
        self.cupNumberLabel.font = [UIFont systemFontOfSize:14.0f];
        
        
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

- (void)setUserModel:(YSRoomUser *)userModel
{
    _userModel = userModel;
    
    /// AndroidPad:Android pad；AndroidPhone:Andriod phone；
    /// iPad:iPad；iPhone:iPhone；
    /// MacPC:mac explorer；MacClient:mac client；
    /// WindowPC:windows explorer；WindowClient:windows client
    NSString *imageName = @"nameList_OtherDevice";
    NSString *devicetype = [[userModel.properties bm_stringTrimForKey:sUserDevicetype] lowercaseString];
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
    
    BOOL isBeginClass = [YSLiveManager shareInstance].isBeginClass;
    
    if (userModel.role == YSUserType_Student )
    {
        if (isBeginClass)
        {
            self.upPlatformBtn.selected = userModel.publishState != 0;
            
        }
        BOOL disablechat = [userModel.properties bm_boolForKey:sUserDisablechat];
        self.speakBtn.selected = disablechat;
    }
    self.upPlatformBtn.enabled = isBeginClass;
    self.outBtn.enabled = isBeginClass;
    self.nameLabel.text = userModel.nickName;
    [self.iconImgView setImage:YSSkinElementImage(imageName, @"iconNor")];
    
    NSInteger giftNumber = [userModel.properties bm_uintForKey:sUserGiftNumber];
    self.cupNumberLabel.text = [NSString stringWithFormat:@"x %@",giftNumber <= 99 ? @(giftNumber) : @"99+"];

    if ([YSLiveManager shareInstance].room_UseTheType == YSAppUseTheTypeMeeting)
    {
        self.cupView.hidden = YES;
        self.cupImgView.hidden = YES;
        self.cupNumberLabel.hidden = YES;
    }
    else
    {
        self.cupView.hidden = NO;
        self.cupImgView.hidden = NO;
        self.cupNumberLabel.hidden = NO;
    }

    if (userModel.role == YSUserType_Assistant )
    {
        self.upPlatformBtn.enabled = NO;
        self.outBtn.enabled = NO;
        self.speakBtn.enabled = NO;
        self.cupView.hidden = YES;
        self.cupImgView.hidden = YES;
        self.cupNumberLabel.hidden = YES;
    }
    else
    {
        self.cupView.hidden = NO;
        self.cupImgView.hidden = NO;
        self.cupNumberLabel.hidden = NO;
    }

}
- (void)setUserRole:(YSUserRoleType)userRoleType
{
    if (userRoleType ==  YSUserType_Patrol)
    {
        _userRoleType = userRoleType;
    }
}
- (void)upPlatformBtnClicked:(UIButton *)btn
{
//    btn.selected = !btn.selected;
    if (_userRoleType ==  YSUserType_Patrol)
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
    if (_userRoleType ==  YSUserType_Patrol)
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
    if (_userRoleType ==  YSUserType_Patrol)
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
