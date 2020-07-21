//
//  SCVideoView.m
//  YSLive
//
//  Created by jiang deng on 2019/11/8.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCVideoView.h"
#import "PanGestureControl.h"

#define widthScale  self.bm_width/([UIDevice bm_isiPad]? 400 : 300)
#define heightScale self.bm_height/([UIDevice bm_isiPad]? 260 : 160)

@interface SCVideoView ()
<
    UIGestureRecognizerDelegate
>

@property (nonatomic, strong) YSRoomUser *roomUser;

///没上课时没有连摄像头时的lab
@property (nonatomic, strong) UILabel * maskNoVideobgLab;

///正在加载中
@property (nonatomic, strong) UIImageView *loadingImgView;
///正在加载中图片
@property (nonatomic, strong) UIImage *loadingImg;

///所有蒙版的背景View
@property (nonatomic, strong) UIView * maskBackView;

///奖杯
@property (nonatomic, strong) UIImageView *cupImage;
///奖杯个数
@property (nonatomic, strong) UILabel *cupNumLab;
//奖杯个数富文本
@property (nonatomic, strong) NSMutableAttributedString *cupNumStr;
///画笔权限
@property (nonatomic, strong) UIImageView *brushImageView;
///用户名
@property (nonatomic, strong) UILabel *nickNameLab;
///声音图标
@property (nonatomic, strong) UIImageView *soundImageView;
@property (nonatomic, strong) UIImage *soundImage;
///没有麦克风时的label
@property (nonatomic, strong) UILabel *silentLab;

///关闭视频时的蒙版
@property (nonatomic, strong) UIView *maskCloseVideoBgView;//背景蒙版
@property (nonatomic, strong) UIImageView *maskCloseVideo;
@property (nonatomic, strong) UIImage *maskCloseImage;

///点击Home键提示蒙版
@property (nonatomic, strong) UILabel *homeMaskLab;

///没有连摄像头时的蒙版
@property (nonatomic, strong) UIView *maskNoVideo;//背景蒙版
//上课后没有连摄像头时的文字
@property (nonatomic, strong) UILabel *maskNoVideoTitle;

/// 当前设备上次捕捉的音量  音量大小 0 ～ 32670
@property (nonatomic, assign) NSUInteger lastVolume;

///拖出时的文字字号
@property (nonatomic, strong) UIFont *dragFont;
///拖出时的文字字号
@property (nonatomic, strong)UIFont *notDragFont;
///举手图标
@property (nonatomic, strong) UIImageView *raiseHandImage;

/// 视频状态
@property (nonatomic, assign) SCVideoViewVideoState videoState;
/// 摄像头设备状态
@property (nonatomic, assign) YSDeviceFaultType videoDeviceState;
/// 音频状态
@property (nonatomic, assign) SCVideoViewAudioState audioState;
/// 麦克风设备状态
@property (nonatomic, assign) YSDeviceFaultType audioDeviceState;

@end

@implementation SCVideoView

// 老师用
- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser withDelegate:(id<SCVideoViewDelegate>)delegate
{
    return [self initWithRoomUser:roomUser isForPerch:NO withDelegate:delegate];
}

- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser isForPerch:(BOOL)isForPerch withDelegate:(id<SCVideoViewDelegate>)delegate
{
    self = [super init];

    if (self)
    {
        self.delegate = delegate;
        
        self.roomUser = roomUser;
        self.isForPerch = isForPerch;
        
        if ([UIDevice bm_isiPad])
        {
            self.dragFont = UI_FONT_20;
            self.notDragFont = UI_FONT_16;
        }
        else
        {
            self.dragFont = UI_FONT_16;
            self.notDragFont = UI_FONT_10;
        }
        
        [self setupUIView];
        
        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToShowControl)];
        oneTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:oneTap];
        
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureToMoveView:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.panGesture.delegate = self;
        self.exclusiveTouch = YES;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.panGesture)
    {
        return NO;
    }
    else if ([[PanGestureControl shareInfo] isExistPanGestureAction:LONG_PRESS_VIEW_DEMO])
    {
        return NO;
    }
    else
    {
        [[PanGestureControl shareInfo] addPanGestureAction:LONG_PRESS_VIEW_DEMO];
        return YES;
    }
}

// 学生用
- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser
{
    return [self initWithRoomUser:roomUser isForPerch:NO];
}

- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser isForPerch:(BOOL)isForPerch
{
    self = [super init];
    if (self)
    {
        self.roomUser = roomUser;
        self.isForPerch = isForPerch;

        if ([UIDevice bm_isiPad])
        {
            self.dragFont = UI_FONT_20;
            self.notDragFont = UI_FONT_16;
        }
        else
        {
            self.dragFont = UI_FONT_16;
            self.notDragFont = UI_FONT_10;
        }
        
        [self setupUIView];
        
        if ([roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
            UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToShowControl)];
            oneTap.numberOfTapsRequired = 1;
            [self addGestureRecognizer:oneTap];
        }
        self.exclusiveTouch = YES;
    }
    return self;
}

//视频view点击事件
- (void)clickToShowControl
{
    if (self.appUseTheType == YSRoomUseTypeLiveRoom && [self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
    {
        if ([self.delegate respondsToSelector:@selector(clickViewToControlWithVideoView:)])
        {
            [self.delegate clickViewToControlWithVideoView:self];
        }
    }
    else
    {
        if (self.roomUser.role == YSUserType_Student || self.roomUser.role == YSUserType_Teacher)
        {
            if ([self.delegate respondsToSelector:@selector(clickViewToControlWithVideoView:)])
            {
                [self.delegate clickViewToControlWithVideoView:self];
            }
        }
    }
}

///视频拖拽事件
- (void)panGestureToMoveView:(UIPanGestureRecognizer *)pan
{
    if ([self.delegate respondsToSelector:@selector(panToMoveVideoView:withGestureRecognizer:)])
    {
        [self.delegate panToMoveVideoView:self withGestureRecognizer:pan];
    }
}

- (void)setupUIView
{
    self.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    
    UIView *sourceView = [[UIView alloc] init];
    sourceView.backgroundColor = UIColor.clearColor;
    sourceView.hidden = YES;
    [self addSubview:sourceView];
    self.sourceView = sourceView;
    
    //没上课时没有连摄像头时的lab
    UILabel * maskNoVideobgLab = [[UILabel alloc] initWithFrame:self.bounds];
    maskNoVideobgLab.backgroundColor = YSSkinDefineColor(@"videoMaskBack_color");
    maskNoVideobgLab.font = UI_FONT_14;
    maskNoVideobgLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
    maskNoVideobgLab.adjustsFontSizeToFitWidth = YES;
    maskNoVideobgLab.minimumScaleFactor = 0.3;
    maskNoVideobgLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:maskNoVideobgLab];
    self.maskNoVideobgLab = maskNoVideobgLab;
    
    ///正在加载中
    self.loadingImg = YSSkinElementImage(@"videoView_loadingImage", @"icon_normal");
    UIImageView * loadingImgView = [[UIImageView alloc]initWithImage:self.loadingImg];
    [loadingImgView setBackgroundColor:YSSkinDefineColor(@"videoMaskBack_color")];
    loadingImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:loadingImgView];
    self.loadingImgView = loadingImgView;
    
    self.backVideoView = [[UIView alloc]init];
    self.backVideoView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.backVideoView];
    
    UIView * maskBackView = [[UIView alloc]init];
    maskBackView.backgroundColor = UIColor.clearColor;
    [self.backVideoView addSubview:maskBackView];
    self.maskBackView = maskBackView;
    
    //关闭视频时的蒙版
    self.maskCloseVideoBgView = [[UIView alloc] init];
    self.maskCloseVideoBgView.backgroundColor = YSSkinDefineColor(@"noVideoMaskBgColor");
    [maskBackView addSubview:self.maskCloseVideoBgView];
    self.maskCloseVideoBgView.hidden = YES;

    self.maskCloseImage = YSSkinElementImage(@"videoView_stateVideo", @"closeCam");
    
    self.maskCloseVideo = [[UIImageView alloc] initWithImage:self.maskCloseImage];
    self.maskCloseVideo.contentMode = UIViewContentModeScaleAspectFit;
    [self.maskCloseVideoBgView addSubview:self.maskCloseVideo];

    ///点击Home键提示蒙版
    self.homeMaskLab = [[UILabel alloc]init];
    self.homeMaskLab.text = YSLocalized(@"State.teacherInBackGround");
    self.homeMaskLab.font = UI_FONT_12;
    self.homeMaskLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
    [maskBackView addSubview:self.homeMaskLab];
    [self.homeMaskLab setAdjustsFontSizeToFitWidth:YES];
    self.homeMaskLab.numberOfLines = 2;
    self.homeMaskLab.textAlignment = NSTextAlignmentCenter;
    self.homeMaskLab.backgroundColor = UIColor.clearColor;
    self.homeMaskLab.hidden = YES;
    
    //没有摄像头时的蒙版
    self.maskNoVideo = [[UIView alloc] init];
    self.maskNoVideo.backgroundColor = YSSkinDefineColor(@"videoMaskBack_color");;
    [maskBackView addSubview:self.maskNoVideo];
    self.maskNoVideo.hidden = YES;
    
    //没有连摄像头时的文字
    UILabel * maskNoVideoTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 20)];
    maskNoVideoTitle.backgroundColor = [UIColor clearColor];
    maskNoVideoTitle.font = UI_FONT_14;
    maskNoVideoTitle.textColor = YSSkinDefineColor(@"defaultTitleColor");
    maskNoVideoTitle.adjustsFontSizeToFitWidth = YES;
    maskNoVideoTitle.minimumScaleFactor = 0.3;
    maskNoVideoTitle.numberOfLines = 0;
    maskNoVideoTitle.textAlignment = NSTextAlignmentCenter;
    [self.maskNoVideo addSubview:maskNoVideoTitle];
    self.maskNoVideoTitle = maskNoVideoTitle;
    
    //奖杯
    self.cupImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    self.cupImage.image = YSSkinElementImage(@"videoView_trophyImage", @"iconNor");
    self.cupImage.hidden = NO;
    [self.backVideoView addSubview:self.cupImage];
    
    //奖杯个数
    self.cupNumLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 10)];
    self.cupNumLab.font = UI_FONT_14;
    self.cupNumLab.text = @"× 0";
    self.cupNumLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
    //self.cupNumLab.adjustsFontSizeToFitWidth = YES;
    //self.cupNumLab.minimumScaleFactor = 0.1;
    self.cupNumLab.hidden = NO;
    [self.backVideoView addSubview:self.cupNumLab];
    
    //画笔权限
    self.brushImageView = [[UIImageView alloc] init];
    UIImage *image = YSSkinElementImage(@"videoView_authorizeLab", @"iconNor");
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.brushImageView.image = image;
    self.brushImageView.hidden = NO;
    [self.backVideoView addSubview:self.brushImageView];
    
    //举手图标
    self.raiseHandImage = [[UIImageView alloc] init];
    self.raiseHandImage.image = YSSkinElementImage(@"videoView_handImageView", @"iconNor");
    self.raiseHandImage.hidden = YES;
    [self.backVideoView addSubview:self.raiseHandImage];
    self.raiseHandImage.backgroundColor = UIColor.clearColor;
    
    //用户名
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.font = UI_FONT_16;
    self.nickNameLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
    self.nickNameLab.adjustsFontSizeToFitWidth = YES;
    self.nickNameLab.minimumScaleFactor = 0.3;
    self.nickNameLab.hidden = NO;
    [self.backVideoView addSubview:self.nickNameLab];
    
    //声音图片
    self.soundImageView = [[UIImageView alloc] init];
    self.soundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backVideoView addSubview:self.soundImageView];
    
    UILabel * silentLab = [[UILabel alloc]init];
    silentLab.font = UI_FONT_16;
    silentLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
    silentLab.backgroundColor = UIColor.redColor;
    silentLab.adjustsFontSizeToFitWidth = YES;
    silentLab.minimumScaleFactor = 0.3;
    silentLab.textAlignment = NSTextAlignmentCenter;
    silentLab.layer.cornerRadius = 2;
    silentLab.layer.masksToBounds = YES;
    [self.backVideoView addSubview:silentLab];
    self.silentLab = silentLab;
    silentLab.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    if (self.isDragOut || self.isFullScreen)
    {
        self.nickNameLab.font = self.cupNumLab.font = self.dragFont;
    }
    else
    {
        self.nickNameLab.font = self.cupNumLab.font = self.notDragFont;
    }
    
    [self freshWithRoomUserProperty:self.roomUser];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.maskNoVideobgLab.frame = CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height-20);
    
    if (self.bounds.size.width > self.loadingImg.size.width && self.bounds.size.height > self.loadingImg.size.height)
    {
        self.loadingImgView.frame = CGRectMake((self.bounds.size.width - self.loadingImg.size.width)/2, (self.bounds.size.height - self.loadingImg.size.height)/2, self.loadingImg.size.width, self.loadingImg.size.height);
    }
    else
    {
        self.loadingImgView.frame = self.bounds;
    }
    
    self.backVideoView.frame = self.bounds;
    self.maskBackView.frame = self.bounds;
    self.maskCloseVideoBgView.frame = self.bounds;
    self.homeMaskLab.frame = CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height-20);
    self.maskNoVideo.frame = self.bounds;
    self.maskNoVideoTitle.frame = CGRectMake(2, 10, self.bm_width-4, self.bm_height-25);

    self.sourceView.frame = CGRectMake((self.bounds.size.width - 50)/2	, (self.bounds.size.height - 50)/2, 50, 50);

    if (self.bounds.size.width > self.maskCloseImage.size.width && self.bounds.size.height > self.maskCloseImage.size.height )
    {
        self.maskCloseVideo.frame = CGRectMake((self.bounds.size.width - self.maskCloseImage.size.width)/2, (self.bounds.size.height - self.maskCloseImage.size.height)/2, self.maskCloseImage.size.width, self.maskCloseImage.size.height);
    }
    else
    {
        self.maskCloseVideo.frame = self.bounds;
    }
    
    if (self.appUseTheType == YSRoomUseTypeLiveRoom || self.appUseTheType == YSRoomUseTypeMeeting || self.roomUser.role == YSUserType_Teacher || self.roomUser.role == YSUserType_Assistant)
    {
        self.cupImage.hidden = YES;
        self.cupNumLab.hidden = YES;
    }
    else
    {
        self.cupImage.hidden = NO;
        self.cupNumLab.hidden = NO;
    }
   
    self.cupImage.bm_width = self.cupImage.bm_height = self.bm_width*0.1f;
    self.cupNumLab.bm_width = self.bm_width*0.3f;
    self.cupNumLab.bm_top = self.cupImage.bm_top;
    self.cupNumLab.bm_height = self.cupImage.bm_height;
    self.cupNumLab.bm_left = self.cupImage.bm_right + 4.0f;
    CGFloat fontSize = self.cupImage.bm_height-2.0f;
    if (fontSize<1)
    {
        fontSize = 1.0f;
    }
    else if (fontSize>24)
    {
        fontSize = 24.0f;
    }
    self.cupNumLab.font = [UIFont systemFontOfSize:fontSize];

    self.brushImageView.frame = CGRectMake(self.bm_width - self.cupImage.bm_width - 4, self.cupImage.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
    self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX-self.cupImage.bm_width - 4, self.brushImageView.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
    
    CGFloat height;
    if ([UIDevice bm_isiPad])
    {
        height = 24*widthScale;
        if (height < 16)
        {
            height = 16;
        }
    }
    else
    {
        height = 20*widthScale;
        if (height < 12)
        {
            height = 12;
        }
    }

    self.nickNameLab.frame = CGRectMake(7*widthScale,self.bm_height-4-height, 120*widthScale, height);
    CGFloat soundImageWidth = height*5/3;
    self.soundImageView.frame = CGRectMake(self.bm_width-5-soundImageWidth, self.bm_height-4-height, soundImageWidth, height);
    self.silentLab.frame = CGRectMake(self.bm_width-150*widthScale, self.bm_height-4-height, 150*widthScale, height);
}

/// 当前设备音量  音量大小 0 ～ 32670
- (void)setIVolume:(NSUInteger)iVolume
{
    _iVolume = iVolume;
    
    if (self.audioState != YSDeviceFaultNone)
    {
        return;
    }
    if (self.roomUser.publishState == YSUser_PublishState_VIDEOONLY || self.roomUser.publishState == 4 || ([YSLiveManager sharedInstance].isEveryoneNoAudio && (self.roomUser.publishState == YSUser_PublishState_VIDEOONLY || self.roomUser.publishState == 4) && self.roomUser.role != YSUserType_Teacher))
    {
        self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_selientSound");
        return;
    }

    CGFloat volumeScale = 32670/4;
    
    if (iVolume < 1)
    {
        if (self.lastVolume > 1)
        {
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_noSound");
        }
    }
    else if (iVolume<= volumeScale)
    {
        if (self.lastVolume>volumeScale || self.lastVolume<1)
        {
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_1Sound");
        }
    }
    else if (iVolume<= volumeScale*2)
    {
        if (self.lastVolume> volumeScale*2 || self.lastVolume<= volumeScale)
        {
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_2Sound");
        }
    }
    else if (iVolume > volumeScale*2)
    {
        if (self.lastVolume<=volumeScale*2)
        {
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_3Sound");
        }
    }
}

/// 奖杯数
- (void)setGiftNumber:(NSUInteger)giftNumber
{
    _giftNumber = giftNumber;
    
    if (self.roomUser.role != YSUserType_Teacher && self.roomUser.role != YSUserType_Assistant)
    {
        self.cupNumLab.text = [NSString stringWithFormat:@"× %@", @(giftNumber)];
    }
    else
    {
        self.cupImage.hidden = YES;
        self.cupNumLab.hidden = YES;
        self.cupNumLab.text = nil;
    }
}

/// 画笔颜色值
- (void)setBrushColor:(NSString *)brushColor
{
    UIColor *color = [UIColor bm_colorWithHexString:brushColor];
    self.brushImageView.tintColor = color;
}

/// 画笔权限
- (void)setCanDraw:(BOOL)canDraw
{
    _canDraw = canDraw;
    self.brushImageView.hidden = !canDraw;
}

/// 是否隐藏奖杯
- (void)setIsHideCup:(BOOL)isHideCup
{
    self.cupImage.hidden = isHideCup;
    self.cupNumLab.hidden = isHideCup;
}

- (void)setIsDragOut:(BOOL)isDragOut
{
    _isDragOut = isDragOut;
    
    if (isDragOut)
    {
        self.nickNameLab.font = self.cupNumLab.font = self.dragFont;
    }
    else
    {
        self.nickNameLab.font = self.cupNumLab.font = self.notDragFont;
    }
}

- (void)setIsFullMedia:(BOOL)isFullMedia
{
    _isFullMedia = isFullMedia;
    
    if (isFullMedia)
    {
        self.nickNameLab.font = self.cupNumLab.font = self.dragFont;
    }
    else
    {
        self.nickNameLab.font = self.cupNumLab.font = self.notDragFont;
    }
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    
    if (isFullScreen)
    {
        self.nickNameLab.font = self.cupNumLab.font = self.dragFont;
    }
    else
    {
        self.nickNameLab.font = self.cupNumLab.font = self.notDragFont;
    }
}

// 是否举手
- (void)setIsRaiseHand:(BOOL)isRaiseHand
{
    _isRaiseHand = isRaiseHand;
    
    if (isRaiseHand)
    {
        self.raiseHandImage.hidden = NO;
        self.raiseHandImage.image = YSSkinElementImage(@"videoView_handImageView", @"iconNor");
    }
    else if (self.videoState & SCVideoViewVideoState_PoorInternet)
    {
        self.raiseHandImage.hidden = NO;
        self.raiseHandImage.image = YSSkinElementImage(@"videoView_stateVideo", @"lowWifi");
    }
    else
    {
       self.raiseHandImage.hidden = YES;
    }
}

/// 视频状态
- (void)setVideoState:(SCVideoViewVideoState)videoState
{
    _videoState = videoState;
    
    self.maskNoVideo.hidden = YES;
    self.maskCloseVideoBgView.hidden = YES;
    self.homeMaskLab.hidden = YES;
    
    // 低端设备
    if (videoState & SCVideoViewVideoState_Low_end)
    {
        if (self.roomUser.role != YSUserType_Teacher && ![self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
           {
               self.maskNoVideo.hidden = NO;
               self.maskNoVideoTitle.text = YSLocalized(@"Prompt.LowDeviceTitle");
               [self.maskBackView bringSubviewToFront:self.maskNoVideo];

               return;
           }
           else
           {
               self.maskNoVideoTitle.text = nil;
           }
    }
    
    if (videoState & SCVideoViewVideoState_DeviceError)
    {
        self.loadingImgView.hidden = YES;
        
        switch (self.videoDeviceState)
        {
            // 无设备
            case YSDeviceFaultNotFind:
            {
                self.maskCloseVideoBgView.hidden = NO;
                [self.maskCloseVideoBgView bm_bringToFront];
                self.maskCloseVideo.image = YSSkinElementImage(@"videoView_stateVideo", @"noCam");
            }
                break;
                
            // 设备被禁用
            case YSDeviceFaultNotAuth:
            {
                self.maskCloseVideoBgView.hidden = NO;
                [self.maskCloseVideoBgView bm_bringToFront];
                self.maskCloseVideo.image = YSSkinElementImage(@"videoView_stateVideo", @"disableCam");
            }
                break;
                
            // 设备被占用
            case YSDeviceFaultOccupied:
            {
                self.maskCloseVideoBgView.hidden = NO;
                [self.maskCloseVideoBgView bm_bringToFront];
                self.maskCloseVideo.image = YSSkinElementImage(@"videoView_stateVideo", @"occupyCam");
            }
                break;
                
            case YSDeviceFaultUnknown:
            {
                self.maskNoVideo.hidden = NO;
                [self.maskNoVideo bm_bringToFront];
                 if (self.isForPerch)
                 {
                     self.maskNoVideobgLab.text = YSLocalized(@"Prompt.DeviceUnknownError");
                 }
                 else
                 {
                     self.maskNoVideoTitle.text = YSLocalized(@"Prompt.DeviceUnknownError");
                 }
            }
                break;

//            // 设备打开失败
//                YSDeviceFaultUnknown        = 1, //未知错误
//                YSDeviceFaultConError       = 5, //约束无法获取设备流
//                YSDeviceFaultConFalse       = 6, //约束都为false
//                YSDeviceFaultStreamOverTime = 7, //获取设备流超时
//                YSDeviceFaultStreamEmpty    = 8 //设备流没有数据
            default:
            {
                self.maskNoVideo.hidden = NO;
                [self.maskNoVideo bm_bringToFront];
                if (self.isForPerch)
                {
                    self.maskNoVideobgLab.text = YSLocalized(@"Prompt.CanotOpenCamera");
                }
                else
                {
                    self.maskNoVideoTitle.text = [NSString stringWithFormat:@"%@:%@", @(self.videoDeviceState), YSLocalized(@"Prompt.CanotOpenCamera")];
                }
            }
                break;
        }
        return;
    }
    else
    {
        self.loadingImgView.hidden = NO;
    }

#if 0
    // 视频订阅失败
    if (videoState & SCVideoViewVideoState_SubscriptionFailed)
    {
        self.maskNoVideo.hidden = NO;
        self.maskNoVideoTitle.text = YSLocalized(@"Prompt.VideoLoading");
        [self.maskBackView bringSubviewToFront:self.maskNoVideo];
        return;
    }
    
    // 视频播放失败
    if (videoState & SCVideoViewVideoState_PlayFailed)
    {
        
        self.maskNoVideo.hidden = NO;
        self.maskNoVideoTitle.text = YSLocalized(@"Prompt.VideoBuffering");
        [self.maskBackView bringSubviewToFront:self.maskNoVideo];
        return;
    }
#endif
    
    // 用户关闭视频
    if (videoState & SCVideoViewVideoState_Close)
    {
        self.maskCloseVideoBgView.hidden = NO;
        [self.maskCloseVideoBgView bm_bringToFront];
        self.maskCloseVideo.image = self.maskCloseImage;
        return;
    }
    
    // 弱网环境
    if (self.isRaiseHand)
    {
        self.raiseHandImage.hidden = NO;
        self.raiseHandImage.image = YSSkinElementImage(@"videoView_handImageView", @"iconNor");
    }
    else if (videoState & SCVideoViewVideoState_PoorInternet)
    {
        self.raiseHandImage.hidden = NO;
        self.raiseHandImage.image = YSSkinElementImage(@"videoView_stateVideo", @"lowWifi");
    }
    else
    {
        self.raiseHandImage.hidden = YES;
    }
    
    // 用户进入后台
    if (videoState & SCVideoViewVideoState_InBackground)
    {
        if (self.roomUser.role == YSUserType_Student)
        {
            self.homeMaskLab.hidden = NO;
            [self.homeMaskLab bm_bringToFront];
            self.homeMaskLab.text = YSLocalized(@"State.teacherInBackGround");
            return;
        }
    }
    
    // 正常显示视频
    if (videoState == SCVideoViewVideoState_Normal)
    {
        self.maskCloseVideoBgView.hidden = YES;
    }
}

/// 摄像头设备状态
- (void)setVideoDeviceState:(YSDeviceFaultType)videoDeviceState
{
    _videoDeviceState = videoDeviceState;
    
    [self setVideoState:self.videoState];
}

/// 音频状态
- (void)setAudioState:(SCVideoViewAudioState)audioState
{
    _audioState = audioState;
    
    self.silentLab.hidden = YES;
    self.silentLab.text = nil;
    self.soundImageView.hidden = NO;
    self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_noSound");
    
    // 设备不可用
    if (audioState & SCVideoViewAudioState_DeviceError)
    {
        switch (self.audioDeviceState)
        {
            // 无设备
            case YSDeviceFaultNotFind:
            {
                self.soundImageView.image = YSSkinElementImage(@"videoView_stateSound", @"noMic");
            }
                break;
                
            // 设备被禁用
            case YSDeviceFaultNotAuth:
            {
                self.soundImageView.image = YSSkinElementImage(@"videoView_stateSound", @"disableMic");
            }
                break;
                
            // 设备被占用
            case YSDeviceFaultOccupied:
            {
                self.soundImageView.image = YSSkinElementImage(@"videoView_stateSound", @"occupyMic");
            }
                break;
               
            // 未知错误
            case YSDeviceFaultUnknown:
            {
                self.silentLab.hidden = NO;
                self.soundImageView.hidden = YES;
                self.silentLab.text = YSLocalized(@"Prompt.DeviceUnknownError");
            }
                break;

            // 浏览器不支持
            case YSDeviceFaultSDPFail:
            {
                self.silentLab.hidden = NO;
                self.soundImageView.hidden = YES;
                self.silentLab.text = YSLocalized(@"Prompt.BrowserCanotSupport");
            }
                break;
                
            // 设备打开失败
            default:
            {
                self.silentLab.hidden = NO;
                self.soundImageView.hidden = YES;
                self.silentLab.text = [NSString stringWithFormat:@"%@:%@", @(self.audioDeviceState), YSLocalized(@"Prompt.CanotOpenMicrophone")];
            }
                break;
        }

        return;
    }
    
#if 0
    // 音频订阅失败
    if (audioState & SCVideoViewAudioState_SubscriptionFailed)
    {
        self.silentLab.hidden = NO;
        self.silentLab.text = YSLocalized(@"Prompt.AudioLoading");
        self.soundImageView.hidden = YES;
        return;
    }
    
    // 音频播放失败
    if (audioState & SCVideoViewAudioState_PlayFailed)
    {
        self.silentLab.hidden = NO;
        self.silentLab.text = YSLocalized(@"Prompt.AudioBuffering");
        self.soundImageView.hidden = YES;
        return;
    }
#endif
    
    // 用户关闭麦克风
    if (audioState & SCVideoViewAudioState_Close)
    {
        self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_selientSound");
        return;
    }

    // 正常
    if (audioState == SCVideoViewAudioState_Normal)
    {
        self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_noSound");
    }
}

/// 麦克风设备状态
- (void)setAudioDeviceState:(YSDeviceFaultType)audioDeviceState
{
    _audioDeviceState = audioDeviceState;
    
    [self setAudioState:self.audioState];
}

- (void)freshWithRoomUserProperty:(YSRoomUser *)roomUser
{
    if (!roomUser)
    {
        return;
    }
    
    self.roomUser = roomUser;

    if (![self.roomUser.peerID isEqualToString:@"0"])
    {
        self.nickNameLab.text = self.roomUser.nickName;
    }
    
    if (self.isForPerch)
    {
        self.loadingImgView.hidden = (self.roomUser.vfail != YSDeviceFaultNone);
        self.backVideoView.hidden = YES;
        
        BOOL deviceError = NO;
        if ([self.roomUser.properties bm_containsObjectForKey:sYSUserVideoFail])
        {
            self.videoDeviceState = self.roomUser.vfail;
            if (self.roomUser.vfail != YSDeviceFaultNone)
            {
                deviceError = YES;
            }
        }

        if (deviceError)
        {
            self.videoState |= SCVideoViewVideoState_DeviceError;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_DeviceError;
        }
    }
    else
    {
        // 刷新当前用户前后台状态
        if ([self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
                BOOL isInBackGround = NO;
                UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                if (state != UIApplicationStateActive)
                {
                    isInBackGround = YES;
                    // 兼容iOS11前后台状态
                    if (BMIOS_VERSION >= 11.0 && BMIOS_VERSION < 12.0)
                    {
                        if (state == UIApplicationStateInactive)
                        {
                            isInBackGround = NO;
                        }
                    }
                }
                if (isInBackGround != [self.roomUser.properties bm_boolForKey:sYSUserIsInBackGround])
                {
                    [[YSLiveManager sharedInstance] setPropertyOfUid:YSCurrentUser.peerID tell:YSRoomPubMsgTellAll propertyKey:sYSUserIsInBackGround value:@(isInBackGround)];
                }
        }
        
        self.canDraw = [self.roomUser.properties bm_boolForKey:sYSUserCandraw];
        self.giftNumber = [self.roomUser.properties bm_uintForKey:sYSUserGiftNumber];
        
        NSString *brushColor = [self.roomUser.properties bm_stringTrimForKey:sYSUserPrimaryColor];
        if ([brushColor bm_isNotEmpty])
        {
            self.brushColor = brushColor;
        }

        // 视频相关
        
        // 低端设备
        BOOL low = [YSLiveManager sharedInstance].devicePerformance_Low;
        if (low)
        {
            self.videoState |= SCVideoViewVideoState_Low_end;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_Low_end;
        }

        // 设备不可用
        BOOL deviceError = NO;

//        if (!self.roomUser.disableVideo)
//        {
//            // 设备禁用
//            deviceError = YES;
//            self.videoDeviceState = SCVideoViewVideoDeviceState_Disable;
//        }
        if ([self.roomUser.properties bm_containsObjectForKey:sYSUserVideoFail])
        {
            if ([self.roomUser.properties bm_boolForKey:sYSUserHasVideo])
            {
                self.videoDeviceState = self.roomUser.vfail;
                if (self.roomUser.vfail != YSDeviceFaultNone)
                {
                    deviceError = YES;
                }
            }
            else
            {
                deviceError = YES;
                // 设备禁用
                self.videoDeviceState = YSDeviceFaultNotFind;
            }
        }
        else
        {
            if (!deviceError && ![self.roomUser.properties bm_boolForKey:sYSUserHasVideo])
            {
                // 无设备
                deviceError = YES;
                // 设备禁用
                self.videoDeviceState = YSDeviceFaultNotFind;
            }
        }

        if (deviceError)
        {
            self.videoState |= SCVideoViewVideoState_DeviceError;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_DeviceError;
        }

        YSPublishState publishState = [self.roomUser.properties bm_intForKey:sYSUserPublishstate];
        if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_ONSTAGE)
        {
            // 关闭视频
            self.videoState |= SCVideoViewVideoState_Close;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_Close;
        }
        
        // 网络状态
        BOOL isPoorNetWork = [self.roomUser.properties bm_boolForKey:sYSUserNetWorkState];
        if (isPoorNetWork)
        {
            self.videoState |= SCVideoViewVideoState_PoorInternet;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_PoorInternet;
        }
        
        // 进入后台(home键)
        BOOL isInBackGround = [self.roomUser.properties bm_boolForKey:sYSUserIsInBackGround];
        if (isInBackGround)
        {
            self.videoState |= SCVideoViewVideoState_InBackground;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_InBackground;
        }
        
        // 音频相关
        
        // 设备不可用
        deviceError = NO;
//        if (!self.roomUser.disableAudio)
//        {
//            // 设备禁用
//            deviceError = YES;
//            self.audioDeviceState = SCVideoViewAudioDeviceState_Disable;
//        }
        if ([self.roomUser.properties bm_containsObjectForKey:sYSUserAudioFail])
        {
            if ([self.roomUser.properties bm_boolForKey:sYSUserHasAudio])
            {
                self.audioDeviceState = self.roomUser.afail;
                if (self.roomUser.afail != YSDeviceFaultNone)
                {
                    deviceError = YES;
                }
            }
            else
            {
                deviceError = YES;
                self.audioDeviceState = YSDeviceFaultNotFind;
            }
        }
        else
        {
            
            if (!deviceError && ![self.roomUser.properties bm_boolForKey:sYSUserHasAudio])
            {
                // 无设备
                deviceError = YES;
                // 设备禁用
                self.audioDeviceState = YSDeviceFaultNotFind;
            }
        }

        if (deviceError)
        {
            self.audioState |= SCVideoViewAudioState_DeviceError;
        }
        else
        {
            self.audioState &= ~SCVideoViewAudioState_DeviceError;
        }

        if (publishState == YSUser_PublishState_VIDEOONLY || publishState == 4 || ([YSLiveManager sharedInstance].isEveryoneNoAudio && self.roomUser.role != YSUserType_Teacher))
        {
            // 关闭音频
            self.audioState |= SCVideoViewAudioState_Close;
        }
        else
        {
            self.audioState &= ~SCVideoViewAudioState_Close;
        }
    }
    
    [self.backVideoView bm_bringToFront];
}

@end
