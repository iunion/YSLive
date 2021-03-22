//
//  CHLiveControl.m
//  YSAll
//
//  Created by 马迪 on 2021/3/22.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHLiveControlView.h"


@interface CHLiveControlView ()

///音频控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * audioBtn;
///视频控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * videoBtn;

/// 控制自己音视频的按钮的背景View
@property(nonatomic,strong) UIView * controlBackView;

@end

@implementation CHLiveControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
        
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)setup
{
    UIView * controlBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 40)];
    controlBackView.backgroundColor = YSSkinDefineColor(@"Color2");
    self.controlBackView = controlBackView;
    [self addSubview:controlBackView];
    [controlBackView bm_roundedRect:5.0f borderWidth:0 borderColor:nil];

    //音频控制按钮
    self.audioBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") imageName:@"videoPop_soundButton" selectImageName:@"videoPop_soundButton"];
    self.audioBtn.disabledImage = YSSkinElementImage(@"videoPop_soundButton", @"iconDis");
    self.audioBtn.disabledText = YSLocalized(@"Button.OpenAudio");
    self.audioBtn.tag = 0;
    [controlBackView addSubview:self.audioBtn];
    self.audioBtn.frame = CGRectMake(5, 4, 36, 32);
    
    //视频控制按钮
    self.videoBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenVideo") selectTitle:YSLocalized(@"Button.CloseVideo") imageName:@"videoPop_videoButton" selectImageName:@"videoPop_videoButton"];
    UIImage * videoClose = [YSSkinElementImage(@"videoPop_videoButton", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    self.videoBtn.disabledImage = videoClose;
    self.videoBtn.disabledText = YSLocalized(@"Button.OpenVideo");
    [controlBackView addSubview:self.videoBtn];
    self.videoBtn.tag = 1;
    self.videoBtn.frame = CGRectMake(45, 4, 36, 32);
    
}

/// 刷新视频控制按钮状态
- (void)updataVideoPopViewStateWithSourceId:(NSString *)sourceId
{
    if (YSCurrentUser.audioMute == CHSessionMuteState_Mute)
    {
        self.audioBtn.selected = NO;
    }
    else
    {
        self.audioBtn.selected = YES;
    }

    if ([YSCurrentUser getVideoMuteWithSourceId:sourceId] == CHSessionMuteState_Mute)
    {
        self.videoBtn.selected = NO;
    }
    else
    {
        self.videoBtn.selected = YES;
    }
        
    //没有摄像头、麦克风权限时的显示禁用状态
    if (YSCurrentUser.afail == CHDeviceFaultNone)
    {
        self.audioBtn.enabled = YES;
    }
    else
    {
        self.audioBtn.enabled = NO;
    }
    
    if ([YSCurrentUser getVideoVfailWithSourceId:sourceId] == CHDeviceFaultNone)
    {
        self.videoBtn.enabled = YES;
    }
    else
    {
        self.videoBtn.enabled = NO;
    }
}

- (void)userBtnsClick:(UIButton *)sender
{
    CHSessionMuteState muteState = CHSessionMuteState_UnMute;
    
    switch (sender.tag) {
        case 0:
        {//关闭音频
            if (sender.selected)
            {//当前是打开音频状态
                muteState = CHSessionMuteState_Mute;
            }
            [YSCurrentUser sendToChangeAudioMute:muteState];
            sender.selected = !sender.selected;
        }
            break;
        case 1:
        {//关闭视频
            if (sender.selected)
            {//当前是打开视频状态
                muteState = CHSessionMuteState_Mute;
            }
            
            [YSCurrentUser sendToChangeVideoMute:muteState WithSourceId:sCHUserDefaultSourceId];
            sender.selected = !sender.selected;
        }
            break;
        default:
            break;
    }
}

///创建button
- (BMImageTitleButtonView *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle imageName:(NSString *)imageName selectImageName:(NSString *)selectImageName
{
    BMImageTitleButtonView * button = [[BMImageTitleButtonView alloc]init];
    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
    button.textNormalColor = YSSkinDefineColor(@"Color3");
    button.textFont = UI_FONT_10;
    button.normalText = title;
    
    if (selectTitle.length)
    {
        button.selectedText = selectTitle;
    }
    button.normalImage = YSSkinElementImage(imageName, @"iconNor");

    if (selectImageName.length)
    {
        button.selectedImage = YSSkinElementImage(imageName, @"iconSel");
    }
    
    return button;
}

@end
