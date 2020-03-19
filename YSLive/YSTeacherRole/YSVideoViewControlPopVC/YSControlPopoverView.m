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

@end

@implementation YSControlPopoverView


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bm_colorWithHex:0x336CC7];
    
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

    }
    
}

- (void)setUserModel:(YSRoomUser *)userModel
{
    _userModel = userModel;
    
    if (YSCurrentUser.role == YSUserType_Student)
    {
        [self setupStudentSelfUI];
    }
    else
    {
    
    if (userModel.role == YSUserType_Teacher || userModel.role == YSUserType_Assistant )
    {
        [self setupTearcherUI];
        
    }
    else if (userModel.role == YSUserType_Student)
    {
        [self setupStudentUI];
    }
    }
}

- (void)setupStudentSelfUI
{
    [self.backView bm_removeAllSubviews];
    YSPublishState publishState = [self.userModel.properties bm_intForKey:sUserPublishstate];
    
    //纵向时按钮高度
    CGFloat height = (self.view.bm_height-5)/3+0.5;
    //横向时按钮高度
    CGFloat width = (self.view.bm_width-5)/3+0.5;
    
    //音频控制按钮
    self.audioBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") imageName:@"tearch_openSound" selectImageName:@"tearch_closeSound"];
    UIImage * audioClose = [[UIImage imageNamed:@"tearch_openSound"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.audioBtn setImage:audioClose forState:UIControlStateDisabled];
    self.audioBtn.tag = 0;
    if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.audioBtn.selected = YES;
    }
    else
    {
        self.audioBtn.selected = NO;
    }
    
    //视频控制按钮
    self.videoBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenVideo") selectTitle:YSLocalized(@"Button.CloseVideo") imageName:@"tearch_openVideo" selectImageName:@"tearch_closeVideo"];
    UIImage * videoClose = [[UIImage imageNamed:@"tearch_openVideo"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.videoBtn setImage:videoClose forState:UIControlStateDisabled];
    
    self.videoBtn.tag = 1;
    if (publishState == YSUser_PublishState_VIDEOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.videoBtn.selected = YES;
    }
    else
    {
        self.videoBtn.selected = NO;
    }
    
    //镜像控制按钮
    self.mirrorBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenMirror" ) selectTitle:YSLocalized(@"Button.CloseMirror" ) imageName:@"user_openMirror" selectImageName:@"user_CloseMirror"];
    
    UIImage * mirrorClose = [[UIImage imageNamed:@"user_openMirror"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.mirrorBtn setImage:mirrorClose forState:UIControlStateDisabled];
    
    
    self.mirrorBtn.tag = 2;
    if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.mirrorBtn.selected = YES;
    }
    else
    {
        self.mirrorBtn.selected = NO;
    }
    
    if (self.view.bm_width < self.view.bm_height)
    {
        self.audioBtn.frame = CGRectMake(0, Margin, self.view.bm_width, height);
        self.videoBtn.frame = CGRectMake(0, Margin + height, self.view.bm_width, height);
        self.mirrorBtn.frame = CGRectMake(0, Margin + 2 * height, self.view.bm_width, height);
    }
    else
    {
        self.audioBtn.frame = CGRectMake(Margin, 0, width, self.view.bm_height);
        self.videoBtn.frame = CGRectMake(Margin + width, 0, width, self.view.bm_height);
        self.mirrorBtn.frame = CGRectMake(Margin + 2 * width, 0, width, self.view.bm_height);
    }
    
    [self moveButtonTitleAndImageWithButton:self.audioBtn];
    [self moveButtonTitleAndImageWithButton:self.videoBtn];
    [self moveButtonTitleAndImageWithButton:self.mirrorBtn];
    
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

- (void)setupTearcherUI
{
    [self.backView bm_removeAllSubviews];
    YSPublishState publishState = [self.userModel.properties bm_intForKey:sUserPublishstate];
    
    //纵向时按钮高度
    CGFloat height = (self.view.bm_height-5)/4+0.5;
    //横向时按钮高度
    CGFloat width = (self.view.bm_width-5)/4+0.5;
        
    if (self.roomtype == YSRoomType_One || (self.roomLayout == YSLiveRoomLayout_AroundLayout && !self.isDragOut))
    {
        height = (self.view.bm_height-5)/2+0.5;
        width = (self.view.bm_width-5)/2+0.5;
    }
    else if ((self.appUseTheType == YSAppUseTheTypeSmallClass && self.roomLayout != YSLiveRoomLayout_AroundLayout && !self.isDragOut)||(self.appUseTheType == YSAppUseTheTypeSmallClass  && self.roomLayout == YSLiveRoomLayout_AroundLayout && self.isDragOut) || (self.appUseTheType == YSAppUseTheTypeMeeting && self.isDragOut))
    {
        height = (self.view.bm_height-5)/3+0.5;
        width = (self.view.bm_width-5)/3+0.5;
    }
        
    //音频控制按钮
    self.audioBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") imageName:@"tearch_openSound" selectImageName:@"tearch_closeSound"];
    UIImage * audioClose = [[UIImage imageNamed:@"tearch_openSound"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.audioBtn setImage:audioClose forState:UIControlStateDisabled];
    self.audioBtn.tag = 0;
    if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.audioBtn.selected = YES;
    }
    else
    {
        self.audioBtn.selected = NO;
    }
    
    //视频控制按钮
    self.videoBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenVideo") selectTitle:YSLocalized(@"Button.CloseVideo") imageName:@"tearch_openVideo" selectImageName:@"tearch_closeVideo"];
    UIImage * videoClose = [[UIImage imageNamed:@"tearch_openVideo"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.videoBtn setImage:videoClose forState:UIControlStateDisabled];
    
    self.videoBtn.tag = 1;
    if (publishState == YSUser_PublishState_VIDEOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.videoBtn.selected = YES;
    }
    else
    {
        self.videoBtn.selected = NO;
    }
    
    if (self.view.bm_width < self.view.bm_height)
    {
        self.audioBtn.frame = CGRectMake(0, Margin, self.view.bm_width, height);
        self.videoBtn.frame = CGRectMake(0, Margin + height, self.view.bm_width, height);
    }
    else
    {
        self.audioBtn.frame = CGRectMake(Margin, 0, width, self.view.bm_height);
        self.videoBtn.frame = CGRectMake(Margin + width, 0, width, self.view.bm_height);
    }
    
    [self moveButtonTitleAndImageWithButton:self.audioBtn];
    [self moveButtonTitleAndImageWithButton:self.videoBtn];
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
    
    if (self.roomtype == YSRoomType_More)
    {
        if (self.roomLayout == YSLiveRoomLayout_AroundLayout)
        {
            if (self.isDragOut)
            {
                //复位控制按钮
                UIButton * restoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.RestorePosition") selectTitle:nil imageName:@"videoReset" selectImageName:nil];
                restoreBtn.tag = 3;
                
                if (self.view.bm_width < self.view.bm_height)
                {
                    restoreBtn.frame = CGRectMake(0, Margin + 2 * height, self.view.bm_width, height);
                }
                else
                {
                    restoreBtn.frame = CGRectMake(Margin + 2 * width, 0, width, self.view.bm_height);
                }
                [self moveButtonTitleAndImageWithButton:restoreBtn];
                self.restoreBtn = restoreBtn;
            }
        }
        else
        {
            //成为焦点按钮
            self.fouceBtn = [self creatButtonWithTitle:YSLocalized(@"Button.SetFocus") selectTitle:YSLocalized(@"Button.CancelFocus") imageName:@"teacherOrStudent_NotFouce" selectImageName:@"teacherOrStudent_IsFouce"];
            self.fouceBtn.tag = 2;
            if (self.view.bm_width < self.view.bm_height)
            {
                self.fouceBtn.frame = CGRectMake(0, Margin + 2 * height, self.view.bm_width, height);
            }
            else
            {
                self.fouceBtn.frame = CGRectMake(Margin + 2 * width, 0, width, self.view.bm_height);
            }
            
            if ([self.userModel.peerID isEqualToString:self.foucePeerId])
            {
                self.fouceBtn.selected = YES;
            }
            else
            {
                self.fouceBtn.selected = NO;
            }
            
            [self moveButtonTitleAndImageWithButton:self.fouceBtn];
            
            if (self.isDragOut)
            {
                //复位控制按钮
                UIButton * restoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.RestorePosition") selectTitle:nil imageName:@"videoReset" selectImageName:nil];
                restoreBtn.tag = 3;
                
                if (self.view.bm_width < self.view.bm_height)
                {
                    restoreBtn.frame = CGRectMake(0, Margin + 3 * height, self.view.bm_width, height);
                }
                else
                {
                    restoreBtn.frame = CGRectMake(Margin + 3 * width, 0, width, self.view.bm_height);
                }
                [self moveButtonTitleAndImageWithButton:restoreBtn];
                self.restoreBtn = restoreBtn;
            }
        }
    }
}

- (void)setupStudentUI
{
    [self.backView bm_removeAllSubviews];
    YSPublishState publishState = [self.userModel.properties bm_intForKey:sUserPublishstate];
    //纵向时按钮高度
    CGFloat height = (self.view.bm_height-5)/7+0.5;
    //横向时按钮高度
    CGFloat width = (self.view.bm_width-5)/7+0.5;
    
    if (self.roomtype == YSRoomType_One || (self.appUseTheType == YSAppUseTheTypeMeeting && self.isDragOut) || (self.appUseTheType == YSAppUseTheTypeSmallClass && self.roomLayout == YSLiveRoomLayout_AroundLayout && !self.isDragOut))
    {
        height = (self.view.bm_height-5)/5+0.5;
        width = (self.view.bm_width-5)/5+0.5;
    }
    else if (self.appUseTheType == YSAppUseTheTypeSmallClass && ((!self.isDragOut && self.roomLayout != YSLiveRoomLayout_AroundLayout)||(self.isDragOut && self.roomLayout == YSLiveRoomLayout_AroundLayout)))
    {
        height = (self.view.bm_height-5)/6+0.5;
        width = (self.view.bm_width-5)/6+0.5;
    }
    else if (self.appUseTheType == YSAppUseTheTypeMeeting && !self.isDragOut)
    {
        height = (self.view.bm_height-5)/4+0.5;
        width = (self.view.bm_width-5)/4+0.5;
    }
   
    //音频控制按钮
    self.audioBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") imageName:@"tearch_openSound" selectImageName:@"tearch_closeSound"];
    UIImage * audioClose = [[UIImage imageNamed:@"tearch_openSound"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.audioBtn setImage:audioClose forState:UIControlStateDisabled];
    self.audioBtn.tag = 0;
    if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.audioBtn.selected = YES;
    }
    else
    {
        self.audioBtn.selected = NO;
    }
    
    //视频控制按钮
    self.videoBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenVideo") selectTitle:YSLocalized(@"Button.CloseVideo") imageName:@"tearch_openVideo" selectImageName:@"tearch_closeVideo"];
    UIImage * videoClose = [[UIImage imageNamed:@"tearch_openVideo"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.videoBtn setImage:videoClose forState:UIControlStateDisabled];
    
    self.videoBtn.tag = 1;
    if (publishState == YSUser_PublishState_VIDEOONLY || publishState == YSUser_PublishState_BOTH)
    {
        self.videoBtn.selected = YES;
    }
    else
    {
        self.videoBtn.selected = NO;
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
    //画笔权限控制按钮
    self.canDrawBtn = [self creatButtonWithTitle:YSLocalized(@"Label.Authorized") selectTitle:YSLocalized(@"Label.CancelAuthorized") imageName:@"teacher_authorize" selectImageName:@"teacher_ancelAuthorize"];
    self.canDrawBtn.tag = 2;
    
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
    self.onStageBtn = [self creatButtonWithTitle:YSLocalized(@"Button.DownPlatform") selectTitle:YSLocalized(@"Button.DownPlatform") imageName:@"teacher_downSeat" selectImageName:@"teacher_onSeat"];
    self.onStageBtn.tag = 3;
    
    if (self.view.bm_width < self.view.bm_height)
    {
        self.audioBtn.frame = CGRectMake(0, Margin, self.view.bm_width, height);
        self.videoBtn.frame = CGRectMake(0, Margin + height, self.view.bm_width, height);
        self.canDrawBtn.frame = CGRectMake(0, Margin + 2 * height, self.view.bm_width, height);
        self.onStageBtn.frame = CGRectMake(0, Margin + 3 * height, self.view.bm_width, height);
    }
    else
    {
        self.audioBtn.frame = CGRectMake(Margin , 0, width, self.view.bm_height);
        self.videoBtn.frame = CGRectMake(Margin + width, 0, width, self.view.bm_height);
        self.canDrawBtn.frame = CGRectMake(Margin + 2 * width, 0, width, self.view.bm_height);
        self.onStageBtn.frame = CGRectMake(Margin + 3 * width, 0, width, self.view.bm_height);
    }
    
    [self moveButtonTitleAndImageWithButton:self.audioBtn];
    [self moveButtonTitleAndImageWithButton:self.videoBtn];
    [self moveButtonTitleAndImageWithButton:self.canDrawBtn];
    [self moveButtonTitleAndImageWithButton:self.onStageBtn];
    
    if (self.appUseTheType == YSAppUseTheTypeMeeting)
    {
        if (self.isDragOut)
        {
            //复位控制按钮
            UIButton * restoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.RestorePosition") selectTitle:nil imageName:@"videoReset" selectImageName:nil];
            restoreBtn.tag = 6;
            
            if (self.view.bm_width < self.view.bm_height)
            {
                restoreBtn.frame = CGRectMake(0, Margin + 4 * height, self.view.bm_width, height);
            }
            else
            {
                restoreBtn.frame = CGRectMake(Margin + 4 * width, 0, width, self.view.bm_height);
            }
            [self moveButtonTitleAndImageWithButton:restoreBtn];
            self.restoreBtn = restoreBtn;
        }
    }
    else
    {
        //发奖杯按钮
        UIButton * giftCupBtn = [self creatButtonWithTitle:YSLocalized(@"Button.GiveCup") selectTitle:nil imageName:@"teacher_trophy" selectImageName:nil];
        giftCupBtn.tag = 4;

        if (self.view.bm_width < self.view.bm_height)
        {
            giftCupBtn.frame = CGRectMake(0, Margin + 4 * height, self.view.bm_width, height);
        }
        else
        {
            giftCupBtn.frame = CGRectMake(Margin + 4 * width, 0, width, self.view.bm_height);
        }

        [self moveButtonTitleAndImageWithButton:giftCupBtn];
        self.giftCupBtn = giftCupBtn;
        
        if (self.roomtype == YSRoomType_More)
        {
            if (self.roomLayout == YSLiveRoomLayout_AroundLayout)
            {
                if (self.isDragOut)
                {
                    //复位控制按钮
                    UIButton * restoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.RestorePosition") selectTitle:nil imageName:@"videoReset" selectImageName:nil];
                    restoreBtn.tag = 6;
                    
                    if (self.view.bm_width < self.view.bm_height)
                    {
                        restoreBtn.frame = CGRectMake(0, Margin + 5 * height, self.view.bm_width, height);
                    }
                    else
                    {
                        restoreBtn.frame = CGRectMake(Margin + 5 * width, 0, width, self.view.bm_height);
                    }
                    [self moveButtonTitleAndImageWithButton:restoreBtn];
                    self.restoreBtn = restoreBtn;
                }
            }
            else
            {
                //成为焦点按钮
                self.fouceBtn = [self creatButtonWithTitle:YSLocalized(@"Button.SetFocus") selectTitle:YSLocalized(@"Button.CancelFocus") imageName:@"teacherOrStudent_NotFouce" selectImageName:@"teacherOrStudent_IsFouce"];
                self.fouceBtn.tag = 5;
                if (self.view.bm_width < self.view.bm_height)
                {
                    self.fouceBtn.frame = CGRectMake(0, Margin + 5 * height, self.view.bm_width, height);
                }
                else
                {
                    self.fouceBtn.frame = CGRectMake(Margin + 5 * width, 0, width, self.view.bm_height);
                }
                
                if ([self.userModel.peerID isEqualToString:self.foucePeerId])
                {
                    self.fouceBtn.selected = YES;
                }
                else
                {
                    self.fouceBtn.selected = NO;
                }
                
                [self moveButtonTitleAndImageWithButton:self.fouceBtn];
                
                if (self.isDragOut)
                {
                    //复位控制按钮
                    UIButton * restoreBtn = [self creatButtonWithTitle:YSLocalized(@"Button.RestorePosition") selectTitle:nil imageName:@"videoReset" selectImageName:nil];
                    restoreBtn.tag = 6;
                    
                    if (self.view.bm_width < self.view.bm_height)
                    {
                        restoreBtn.frame = CGRectMake(0, Margin + 6 * height, self.view.bm_width, height);
                    }
                    else
                    {
                        restoreBtn.frame = CGRectMake(Margin + 6 * width, 0, width, self.view.bm_height);
                    }
                    [self moveButtonTitleAndImageWithButton:restoreBtn];
                }
            }
        }
    }    
}

- (void)userBtnsClick:(UIButton *)sender
{
    if (self.userModel.role == YSUserType_Teacher || self.userModel.role == YSUserType_Assistant || [self.userModel.peerID isEqualToString:YSCurrentUser.peerID])
    {
        if ([self.delegate respondsToSelector:@selector(teacherControlBtnsClick:)])
        {
            [self.delegate teacherControlBtnsClick:sender];
        }
    }
    else if(self.userModel.role == YSUserType_Student)
    {
        if ([self.delegate respondsToSelector:@selector(studentControlBtnsClick:)])
        {
            [self.delegate studentControlBtnsClick:sender];
        }
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
- (UIButton *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle imageName:(NSString *)imageName selectImageName:(NSString *)selectImageName
{
    UIButton * button = [[UIButton alloc]init];
    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    button.titleLabel.font = UI_FONT_10;
    if (![UIDevice bm_isiPad] && self.roomLayout == YSLiveRoomLayout_VideoLayout)
    {


    }else
    {
        [button setTitle:title forState:UIControlStateNormal];
        if (selectTitle.length)
        {
            [button setTitle:selectTitle forState:UIControlStateSelected];
        }
    }
    
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if (selectImageName.length)
    {
        [button setImage:[UIImage imageNamed:selectImageName] forState:UIControlStateSelected];
    }
    [self.backView addSubview:button];
        
    return button;
}

///移动button上图片和文字的位置（图片在上，文字在下）
- (void)moveButtonTitleAndImageWithButton:(UIButton *)button
{
    // 使图片和文字水平居中显示
//    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    // 文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(button.imageView.frame.size.height ,-button.imageView.frame.size.width, 0.0,0.0)];
//    [button setImageEdgeInsets:UIEdgeInsetsMake(-button.imageView.frame.size.height, (button.bounds.size.width - button.imageView.bounds.size.width)*0.5f,0.0, 0.0)];
//
//    button.imageEdgeInsets = UIEdgeInsetsMake(- (button.bm_height - button.titleLabel.bm_height- button.titleLabel.bm_originY)+50,(button.bm_width -button.titleLabel.bm_width+15)/2.0f -button.imageView.bm_width+3, 0, 0);
//    button.titleEdgeInsets = UIEdgeInsetsMake(button.bm_height-button.imageView.bm_height-button.imageView.bm_originY, -button.imageView.bm_width, 0, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(0,18, button.titleLabel.bounds.size.height + 10.0f, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(button.currentImage.size.width + 0.0f, -(button.currentImage.size.width), 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}



@end
