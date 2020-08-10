//
//  YSControlPopoverView.m
//  YSLive
//
//  Created by 马迪 on 2019/12/24.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSControlPopoverView.h"


//const NSInteger margin = 2;

#define Margin 2

@interface YSControlPopoverView ()

@property (nonatomic, strong) UIView *backView;

//复位控制按钮
@property (nonatomic, strong) BMImageTitleButtonView * restoreBtn;
//发奖杯按钮
@property (nonatomic, strong) BMImageTitleButtonView * giftCupBtn;

//全体复位控制按钮
@property (nonatomic, strong) BMImageTitleButtonView * allRestoreBtn;
//全体奖杯按钮
@property (nonatomic, strong) BMImageTitleButtonView * allGiftCupBtn;
//线
@property (nonatomic, strong) UIView * lineView;
@property (nonatomic, strong) NSMutableArray *btnArray;

@end

@implementation YSControlPopoverView


- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnArray = [[NSMutableArray alloc] init];
//    self.view.backgroundColor = [UIColor bm_colorWithHex:0x336CC7];
    self.view.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    
    self.backView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backView.backgroundColor = [UIColor clearColor];
    self.backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backView];
}

- (void)viewWillLayoutSubviews
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
    {
        CGRect layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame;
        self.backView.frame = layoutFrame;
    }
    else
    {
        self.backView.frame = self.view.frame;
    }

    if (self.backView.bm_width>self.backView.bm_height)
    {
        ///音频控制按钮
        self.audioBtn.bm_height = self.backView.bm_height;
        ///视频控制按钮
        self.videoBtn.bm_height = self.backView.bm_height;
        ///镜像控制按钮
        self.mirrorBtn.bm_height = self.backView.bm_height;
        ///画笔权限控制按钮
        self.canDrawBtn.bm_height = self.backView.bm_height;
        ///上下台控制按钮
        self.onStageBtn.bm_height = self.backView.bm_height;
        //成为焦点按钮
        self.fouceBtn.bm_height = self.backView.bm_height;
        //复位控制按钮
        self.restoreBtn.bm_height = self.backView.bm_height;
        //发奖杯按钮
        self.giftCupBtn.bm_height = self.backView.bm_height;
        //全体复位按钮
        self.allRestoreBtn.bm_height = self.backView.bm_height;
        //全体奖杯按钮
        self.allGiftCupBtn.bm_height = self.backView.bm_height;
        
    }
    else
    {
        ///音频控制按钮
        self.audioBtn.bm_width = self.backView.bm_width;
        ///视频控制按钮
        self.videoBtn.bm_width = self.backView.bm_width;
        ///镜像控制按钮
        self.mirrorBtn.bm_width = self.backView.bm_width;
        ///画笔权限控制按钮
        self.canDrawBtn.bm_width = self.backView.bm_width;
        ///上下台控制按钮
        self.onStageBtn.bm_width = self.backView.bm_width;
        //成为焦点按钮
        self.fouceBtn.bm_width = self.backView.bm_width;
        //复位控制按钮
        self.restoreBtn.bm_width = self.backView.bm_width;
        //发奖杯按钮
        self.giftCupBtn.bm_width = self.backView.bm_width;
        //全体复位按钮
        self.allRestoreBtn.bm_width = self.backView.bm_width;
        //全体奖杯按钮
        self.allGiftCupBtn.bm_width = self.backView.bm_width;
    }
    
}

- (void)setUserModel:(YSRoomUser *)userModel
{
    _userModel = userModel;
    
    [self setupUI];

}
- (void)setIsAllNoAudio:(BOOL)isAllNoAudio
{
    _isAllNoAudio = isAllNoAudio;
    
    if (self.userModel.role != YSUserType_Teacher)
    {
        self.audioBtn.enabled = !isAllNoAudio;
    }
    
}

- (void)setupUI
{
    [self.backView bm_removeAllSubviews];
    
    //音频控制按钮
    self.audioBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") image:YSSkinElementImage(@"videoPop_soundButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_soundButton", @"iconSel")];
    self.audioBtn.disabledImage = YSSkinElementImage(@"videoPop_soundButton", @"iconDis");
    self.audioBtn.disabledText = YSLocalized(@"Button.MutingAudio");
    self.audioBtn.tag = SCVideoViewControlTypeAudio;
    self.audioBtn.enabled = YES;
    if (self.userModel.audioMute == YSSessionMuteState_UnMute)
    {
        self.audioBtn.selected = YES;
    }
    else
    {
        self.audioBtn.selected = NO;
    }
    
    //视频控制按钮
    self.videoBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenVideo") selectTitle:YSLocalized(@"Button.CloseVideo") image:YSSkinElementImage(@"videoPop_videoButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_videoButton", @"iconSel")];
    UIImage * videoClose = [YSSkinElementImage(@"videoPop_videoButton", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    self.videoBtn.disabledImage = videoClose;
    self.videoBtn.tag = SCVideoViewControlTypeVideo;
    if ([self.userModel getVideoMuteWithSourceId:self.sourceId] == YSSessionMuteState_UnMute)
    {
        self.videoBtn.selected = YES;
    }
    else
    {
        self.videoBtn.selected = NO;
    }
    
    //画笔权限控制按钮
    self.canDrawBtn = [self creatButtonWithTitle:YSLocalized(@"Label.Authorized") selectTitle:YSLocalized(@"Label.CancelAuthorized") image:YSSkinElementImage(@"videoPop_authorizeButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_authorizeButton", @"iconSel")];
    self.canDrawBtn.tag = SCVideoViewControlTypeCanDraw;
    BOOL canDraw = [self.userModel.properties bm_boolForKey:sYSUserCandraw];
    if (canDraw)
    {
        self.canDrawBtn.selected = YES;
    }
    else
    {
        self.canDrawBtn.selected = NO;
    }
    
    //上下台控制按钮
    self.onStageBtn = [self creatButtonWithTitle:YSLocalized(@"Button.DownPlatform") selectTitle:YSLocalized(@"Button.DownPlatform") image:YSSkinElementImage(@"videoPop_seatButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_seatButton", @"iconNor")];
    self.onStageBtn.tag = SCVideoViewControlTypeOnStage;
    
    
    //镜像控制按钮
    self.mirrorBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenMirror" ) selectTitle:YSLocalized(@"Button.CloseMirror" ) image:YSSkinElementImage(@"videoPop_mirrorButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_mirrorButton", @"iconSel")];
    UIImage * mirrorClose = [YSSkinElementImage(@"videoPop_mirrorButton", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    self.mirrorBtn.disabledImage = mirrorClose;
    self.mirrorBtn.tag = SCVideoViewControlTypeMirror;
//    if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
//    {
//        self.mirrorBtn.selected = YES;
//    }
//    else
//    {
//        self.mirrorBtn.selected = NO;
//    }
    
    //复位控制按钮
    BMImageTitleButtonView  * restoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.RestorePosition") selectTitle:nil image:YSSkinElementImage(@"videoPop_resetButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_resetButton", @"iconSel")];
    restoreBtn.tag = SCVideoViewControlTypeRestore;
    self.restoreBtn = restoreBtn;
    
    //成为焦点按钮
    self.fouceBtn = [self creatButtonWithTitle:YSLocalized(@"Button.SetFocus") selectTitle:YSLocalized(@"Button.CancelFocus") image:YSSkinElementImage(@"videoPop_fouceButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_fouceButton", @"iconSel")];
    self.fouceBtn.tag = SCVideoViewControlTypeFouce;
    
    if ([self.foucePeerId isEqualToString:self.userModel.peerID] && [self.fouceStreamId isEqualToString:self.streamId])
    {
        self.fouceBtn.selected = YES;
    }
    else
    {
        self.fouceBtn.selected = NO;
    }
    
    //发奖杯按钮
    BMImageTitleButtonView  * giftCupBtn = [self creatButtonWithTitle:YSLocalized(@"Button.GiveCup") selectTitle:nil image:YSSkinElementImage(@"videoPop_trophyButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_trophyButton", @"iconSel")];
    giftCupBtn.tag = SCVideoViewControlTypeGiftCup;
    self.giftCupBtn = giftCupBtn;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = YSSkinDefineColor(@"login_lineColor");
    self.lineView = lineView;
    lineView.hidden = YES;
    
    //全体复位按钮
    BMImageTitleButtonView  * allRestoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.Reset") selectTitle:nil image:YSSkinElementImage(@"videoPop_allResetButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_allResetButton", @"iconSel")];
    allRestoreBtn.tag = SCVideoViewControlTypeAllRestore;
    self.allRestoreBtn = allRestoreBtn;
    
    //全体奖杯按钮
    BMImageTitleButtonView  * allGiftCupBtn = [self creatButtonWithTitle:YSLocalized(@"Button.Reward") selectTitle:nil image:YSSkinElementImage(@"videoPop_trophyButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_trophyButton", @"iconSel")];
    allGiftCupBtn.tag = SCVideoViewControlTypeAllGiftCup;
    self.allGiftCupBtn = allGiftCupBtn;
    [self.btnArray removeAllObjects];
    
    
    BOOL isShowLine = NO;
    if (YSCurrentUser.role == YSUserType_Student)
    {
        //音频 视频 镜像
        [self.btnArray addObject:self.audioBtn];
        [self.btnArray addObject:self.videoBtn];
        [self.btnArray addObject:self.mirrorBtn];
    }
    else
    {
        if (self.userModel.role == YSUserType_Teacher || self.userModel.role == YSUserType_Assistant )
        {
            if (self.roomtype == YSRoomUserType_One)
            {
                
                //音频 视频 镜像
                [self.btnArray addObject:self.audioBtn];
                [self.btnArray addObject:self.videoBtn];
                [self.btnArray addObject:self.mirrorBtn];
//                [self.btnArray addObject:self.allGiftCupBtn];
            }
            else
            {
                isShowLine = YES;
                if (self.roomLayout == YSRoomLayoutType_AroundLayout)
                {
                    if (self.isDragOut)
                    {
                        //音频 视频 镜像 复位 全体奖杯 全体复位
                        [self.btnArray addObject:self.audioBtn];
                        [self.btnArray addObject:self.videoBtn];
                        [self.btnArray addObject:self.mirrorBtn];
                        [self.btnArray addObject:self.restoreBtn];
                        [self.btnArray addObject:self.allGiftCupBtn];
                        [self.btnArray addObject:self.allRestoreBtn];
                    }
                    else
                    {
                        //音频 视频 镜像 全体奖杯 全体复位
                        [self.btnArray addObject:self.audioBtn];
                        [self.btnArray addObject:self.videoBtn];
                        [self.btnArray addObject:self.mirrorBtn];
                        [self.btnArray addObject:self.allGiftCupBtn];
                        [self.btnArray addObject:self.allRestoreBtn];
                    }
                }
                else
                {
                    //音频 视频 镜像 焦点 全体奖杯
                    [self.btnArray addObject:self.audioBtn];
                    [self.btnArray addObject:self.videoBtn];
                    [self.btnArray addObject:self.mirrorBtn];
                    [self.btnArray addObject:self.fouceBtn];
                    [self.btnArray addObject:self.allGiftCupBtn];
                }
            }
            
        }
        else if (self.userModel.role == YSUserType_Student)
        {
            if (self.roomtype == YSRoomUserType_One)
            {
                //音频 视频 画笔 上下台 奖杯
                [self.btnArray addObject:self.audioBtn];
                [self.btnArray addObject:self.videoBtn];
                [self.btnArray addObject:self.canDrawBtn];
                [self.btnArray addObject:self.onStageBtn];
                [self.btnArray addObject:self.giftCupBtn];
            }
            else
            {
                if (self.roomLayout == YSRoomLayoutType_AroundLayout)
                {
                    //音频 视频 画笔 上下台 奖杯
                    [self.btnArray addObject:self.audioBtn];
                    [self.btnArray addObject:self.videoBtn];
                    [self.btnArray addObject:self.canDrawBtn];
                    [self.btnArray addObject:self.onStageBtn];
                    [self.btnArray addObject:self.giftCupBtn];
                    
                    if (self.isDragOut)
                    {
                        //音频 视频 画笔 上下台 奖杯 复位
                        [self.btnArray addObject:self.restoreBtn];
                    }
                    
                }
                else
                {
                    //音频 视频 画笔 上下台 奖杯 焦点
                    [self.btnArray addObject:self.audioBtn];
                    [self.btnArray addObject:self.videoBtn];
                    [self.btnArray addObject:self.canDrawBtn];
                    [self.btnArray addObject:self.onStageBtn];
                    [self.btnArray addObject:self.giftCupBtn];
                    [self.btnArray addObject:self.fouceBtn];
                }
                
            }
            
        }
    }
    
    if (self.appUseTheType == YSRoomUseTypeMeeting)
    {
        /// 会议将奖杯移除
        [self.btnArray removeObject:self.allGiftCupBtn];
        [self.btnArray removeObject:self.giftCupBtn];
    }
    
    if (self.roomtype == YSRoomUserType_One && !self.isNested)
    {// 1V1 且 画中画的情况下老师视频是 竖排的
        
        self.view.frame = CGRectMake(0, 0, 50, 50 *self.btnArray.count);
        self.preferredContentSize = CGSizeMake(50, 50 *self.btnArray.count);
    }
    else
    {
        self.view.frame = CGRectMake(0, 0, 50 *self.btnArray.count, 50);
        self.preferredContentSize = CGSizeMake(50 *self.btnArray.count, 50);
    }
    
    //纵向时按钮高度
    CGFloat height = (self.view.bm_height-5)/self.btnArray.count+0.5f;
    //横向时按钮高度
    CGFloat width = (self.view.bm_width-5)/self.btnArray.count+0.5f;
    
    for (NSUInteger index = 0; index < self.btnArray.count; index++)
    {
        UIButton *btn = self.btnArray[index];
        [self.backView addSubview:btn];
        if (self.view.bm_width < self.view.bm_height)
        {
            CGRect frame = CGRectMake(0, Margin + height * index, self.view.bm_width, height);
            btn.frame = frame;
        }
        else
        {
            CGRect frame = CGRectMake(Margin + width * index, 0, width, self.view.bm_height);
            btn.frame = frame;
        }
//        [self moveButtonTitleAndImageWithButton:btn];
    }
    if (isShowLine)
    {
        self.lineView.hidden = NO;
        [self.backView addSubview:self.lineView];
        self.lineView.frame = CGRectZero;
        if (self.view.bm_width < self.view.bm_height)
        {
            self.lineView.bm_height = 1.0f;
            self.lineView.bm_bottom = self.allGiftCupBtn.bm_top;
            self.lineView.bm_width = 30.0f;
            self.lineView.bm_centerX = self.view.bm_width*0.5f;
        }
        else
        {
            self.lineView.bm_width = 1.0f;
            self.lineView.bm_right = self.allGiftCupBtn.bm_left;
            self.lineView.bm_height = 30.0f;
            self.lineView.bm_centerY = self.view.bm_height*0.5f;
        }
    }

    //没有摄像头、麦克风权限时的显示禁用状态
    if (self.userModel.role != YSUserType_Teacher)
    {
        if (self.userModel.afail == YSDeviceFaultNone)
        {
            self.audioBtn.enabled = !self.isAllNoAudio;
        }
        else
        {
            self.audioBtn.enabled = NO;
        }
    }
    
    if ([self.userModel getVideoVfailWithSourceId:self.sourceId] == YSDeviceFaultNone)
    {
        self.videoBtn.enabled = YES;
        self.mirrorBtn.enabled = YES;
    }
    else
    {
        self.videoBtn.enabled = NO;
        self.mirrorBtn.enabled = NO;
    }
}


- (void)userBtnsClick:(BMImageTitleButtonView *)sender
{
    if ([self.delegate respondsToSelector:@selector(videoViewControlBtnsClick:videoViewControlType:withStreamId:)])
    {
        [self.delegate videoViewControlBtnsClick:sender videoViewControlType:sender.tag withStreamId:self.streamId];
    }
}

- (void)setVideoMirrorMode:(CloudHubVideoMirrorMode)videoMirrorMode
{
    _videoMirrorMode = videoMirrorMode;
    if (videoMirrorMode == CloudHubVideoMirrorModeEnabled)
    {
        self.mirrorBtn.selected = YES;
    }
    else if (videoMirrorMode == CloudHubVideoMirrorModeDisabled)
    {
        self.mirrorBtn.selected = NO;
    }
}


///创建button
- (BMImageTitleButtonView *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle image:(UIImage *)image selectImage:(UIImage *)selectImage
{
    BMImageTitleButtonView * button = [[BMImageTitleButtonView alloc]init];
    button.userInteractionEnabled = YES;
    button.type = BMImageTitleButtonView_ImageTop;
    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
    button.textNormalColor = YSSkinDefineColor(@"defaultTitleColor");
    button.textFont= UI_FONT_10;
    button.normalText = title;
    
    if (selectTitle.length)
    {
        button.selectedText = selectTitle;
    }
    
    button.normalImage = image;
    if (selectImage)
    {
        button.selectedImage = selectImage;
    }
    return button;
}

///移动button上图片和文字的位置（图片在上，文字在下）
- (void)moveButtonTitleAndImageWithButton:(UIButton *)button
{
    CGFloat margin = 18;
    if ([UIDevice bm_isiPad])
    {
        margin = 13;
    }

    button.imageEdgeInsets = UIEdgeInsetsMake(0,margin, button.titleLabel.bounds.size.height + 10.0f, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(button.currentImage.size.width + 0.0f, -(button.currentImage.size.width), 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}



@end
