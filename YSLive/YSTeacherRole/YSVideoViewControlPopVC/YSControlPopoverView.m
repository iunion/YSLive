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
@property (nonatomic, strong) UIButton * restoreBtn;
//发奖杯按钮
@property (nonatomic, strong) UIButton * giftCupBtn;

//全体复位控制按钮
@property (nonatomic, strong) UIButton * allRestoreBtn;
//全体奖杯按钮
@property (nonatomic, strong) UIButton * allGiftCupBtn;

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

- (void)setupUI
{
    [self.backView bm_removeAllSubviews];
    YSPublishState publishState = [self.userModel.properties bm_intForKey:sUserPublishstate];
    
    //音频控制按钮
    self.audioBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") image:YSSkinElementImage(@"videoPop_soundButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_soundButton", @"iconSel")];
    UIImage * audioClose = [YSSkinElementImage(@"videoPop_soundButton", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.audioBtn setImage:audioClose forState:UIControlStateDisabled];
    self.audioBtn.tag = SCVideoViewControlTypeAudio;
    if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
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
    [self.videoBtn setImage:videoClose forState:UIControlStateDisabled];
    self.videoBtn.tag = SCVideoViewControlTypeVideo;
    if (publishState == YSUser_PublishState_VIDEOONLY || publishState == YSUser_PublishState_BOTH)
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
    BOOL canDraw = [self.userModel.properties bm_boolForKey:sUserCandraw];
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
    [self.mirrorBtn setImage:mirrorClose forState:UIControlStateDisabled];
    self.mirrorBtn.tag = SCVideoViewControlTypeMirror;
    if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.mirrorBtn.selected = YES;
    }
    else
    {
        self.mirrorBtn.selected = NO;
    }
    
    //复位控制按钮
    UIButton * restoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.RestorePosition") selectTitle:nil image:YSSkinElementImage(@"videoPop_resetButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_resetButton", @"iconSel")];
    restoreBtn.tag = SCVideoViewControlTypeRestore;
    self.restoreBtn = restoreBtn;
    
    //成为焦点按钮
    self.fouceBtn = [self creatButtonWithTitle:YSLocalized(@"Button.SetFocus") selectTitle:YSLocalized(@"Button.CancelFocus") image:YSSkinElementImage(@"videoPop_fouceButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_fouceButton", @"iconSel")];
    self.fouceBtn.tag = SCVideoViewControlTypeFouce;
    if ([self.userModel.peerID isEqualToString:self.foucePeerId])
    {
        self.fouceBtn.selected = YES;
    }
    else
    {
        self.fouceBtn.selected = NO;
    }
    
    //发奖杯按钮
    UIButton * giftCupBtn = [self creatButtonWithTitle:YSLocalized(@"Button.GiveCup") selectTitle:nil image:YSSkinElementImage(@"videoPop_trophyButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_trophyButton", @"iconSel")];
    giftCupBtn.tag = SCVideoViewControlTypeGiftCup;
    self.giftCupBtn = giftCupBtn;
    
    //全体复位按钮
    UIButton * allRestoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.Reset") selectTitle:nil image:YSSkinElementImage(@"videoPop_resetButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_resetButton", @"iconSel")];
    allRestoreBtn.tag = SCVideoViewControlTypeAllRestore;
    self.allRestoreBtn = allRestoreBtn;
    
    //全体奖杯按钮
    UIButton * allGiftCupBtn = [self creatButtonWithTitle:YSLocalized(@"Button.Reward") selectTitle:nil image:YSSkinElementImage(@"videoPop_trophyButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_trophyButton", @"iconSel")];
    allGiftCupBtn.tag = SCVideoViewControlTypeAllGiftCup;
    self.allGiftCupBtn = allGiftCupBtn;
    [self.btnArray removeAllObjects];
    
    
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
            if (self.roomtype == YSRoomType_One)
            {
                
                //音频 视频 镜像 全体奖杯
                [self.btnArray addObject:self.audioBtn];
                [self.btnArray addObject:self.videoBtn];
                [self.btnArray addObject:self.mirrorBtn];
                [self.btnArray addObject:self.allGiftCupBtn];

            }
            else
            {
                if (self.roomLayout == YSLiveRoomLayout_AroundLayout)
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
                    //音频 视频 镜像 全体奖杯 全体复位 焦点
                    [self.btnArray addObject:self.audioBtn];
                    [self.btnArray addObject:self.videoBtn];
                    [self.btnArray addObject:self.mirrorBtn];
                    [self.btnArray addObject:self.allGiftCupBtn];
                    [self.btnArray addObject:self.fouceBtn];
                }
                
            }
            
        }
        else if (self.userModel.role == YSUserType_Student)
        {
            if (self.roomtype == YSRoomType_One)
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
                if (self.roomLayout == YSLiveRoomLayout_AroundLayout)
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
    
    if (self.appUseTheType == YSAppUseTheTypeMeeting)
    {
        /// 会议将奖杯移除
        [self.btnArray removeObject:self.allGiftCupBtn];
        [self.btnArray removeObject:self.giftCupBtn];
    }
    
    if (self.roomtype == YSRoomType_One)
    {
        
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
        [self moveButtonTitleAndImageWithButton:btn];
    }

    //没有摄像头、麦克风权限时的显示禁用状态
    if ([self.userModel.properties bm_containsObjectForKey:sUserVideoFail])
    {
        if (self.userModel.afail == YSDeviceFaultNone)
        {
            self.audioBtn.enabled = YES;
        }
        else
        {
            self.audioBtn.enabled = NO;
        }
        if (self.userModel.vfail == YSDeviceFaultNone)
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
    else
    {
        if (self.userModel.hasAudio)
        {
            self.audioBtn.enabled = YES;
        }
        else
        {
            self.audioBtn.enabled = NO;
        }
        if (self.userModel.hasVideo)
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
    
}



- (void)userBtnsClick:(UIButton *)sender
{
    
    
    if ([self.delegate respondsToSelector:@selector(videoViewControlBtnsClick:videoViewControlType:)])
    {
        [self.delegate videoViewControlBtnsClick:sender videoViewControlType:sender.tag];
    }
    
}

- (void)setVideoMirrorMode:(YSVideoMirrorMode)videoMirrorMode
{
    _videoMirrorMode = videoMirrorMode;
    if (videoMirrorMode == YSVideoMirrorModeEnabled)
    {
        self.mirrorBtn.selected = YES;
    }
    else if (videoMirrorMode == YSVideoMirrorModeDisabled)
    {
        self.mirrorBtn.selected = NO;
    }
}


///创建button
- (UIButton *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle image:(UIImage *)image selectImage:(UIImage *)selectImage
{
    UIButton * button = [[UIButton alloc]init];
    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
//    [button setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    [button setTitleColor:YSSkinDefineColor(@"defaultTitleColor") forState:UIControlStateNormal];
    button.titleLabel.font = UI_FONT_10;
//    if (![UIDevice bm_isiPad] && self.roomLayout == YSLiveRoomLayout_VideoLayout)
//    {
//
//
//    }else
    {
        [button setTitle:title forState:UIControlStateNormal];
        if (selectTitle.length)
        {
            [button setTitle:selectTitle forState:UIControlStateSelected];
        }
    }
    
    [button setImage:image forState:UIControlStateNormal];
    if (selectImage)
    {
        [button setImage:selectImage forState:UIControlStateSelected];
    }
    return button;
}

///移动button上图片和文字的位置（图片在上，文字在下）
- (void)moveButtonTitleAndImageWithButton:(UIButton *)button
{
    CGFloat margin = 25;
    if ([UIDevice bm_isiPad])
    {
        margin = 20;
    }

    button.imageEdgeInsets = UIEdgeInsetsMake(0,margin, button.titleLabel.bounds.size.height + 10.0f, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(button.currentImage.size.width + 0.0f, -(button.currentImage.size.width), 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}



@end
