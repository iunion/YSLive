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
@property (nonatomic, strong) UIImageView *soundImage;
///没有麦克风时的label
@property (nonatomic, strong) UILabel *silentLab;

///关闭视频时的蒙版
@property (nonatomic, strong) UIView *maskCloseVideoBgView;//背景蒙版
@property (nonatomic, strong) UIImageView *maskCloseVideo;

///点击Home键提示蒙版
@property (nonatomic, strong) UILabel *homeMaskLab;

///没有连摄像头时的蒙版
@property (nonatomic, strong) UIView *maskNoVideo;//背景蒙版
///上课后没有连摄像头时的文字
@property (nonatomic, strong) UILabel *maskNoVideoTitle;

/// 当前设备上次捕捉的音量  音量大小 0 ～ 32670
@property (nonatomic, assign) NSUInteger lastVolume;

///拖出时的文字字号
@property (nonatomic, strong) UIFont *dragFont;
///拖出时的文字字号
@property (nonatomic, strong)UIFont *notDragFont;
///举手图标
@property (nonatomic, strong) UIImageView *raiseHandImage;

///手机是否是低版本
//@property (nonatomic, assign)BOOL isLowDevice;


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

////这个方法返回YES，第一个和第二个互斥时，第二个会失效
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0);
//{
//    return YES;
//}

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
    if (self.roomUser.role == YSUserType_Student || self.roomUser.role == YSUserType_Teacher)
    {
        if ([self.delegate respondsToSelector:@selector(clickViewToControlWithVideoView:)])
        {
            [self.delegate clickViewToControlWithVideoView:self];
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
    self.backgroundColor = UIColor.blackColor;
    
    //没上课时没有连摄像头时的lab
    UILabel * maskNoVideobgLab = [[UILabel alloc] initWithFrame:self.bounds];
    maskNoVideobgLab.backgroundColor = [UIColor bm_colorWithHexString:@"#6D7278"];
    maskNoVideobgLab.font = UI_FONT_14;
    maskNoVideobgLab.text = YSLocalized(@"Prompt.DisableCamera");
    maskNoVideobgLab.textColor = UIColor.whiteColor;
    maskNoVideobgLab.adjustsFontSizeToFitWidth = YES;
    maskNoVideobgLab.minimumScaleFactor = 0.3;
//    maskNoVideobgLab.numberOfLines = 0;
    maskNoVideobgLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:maskNoVideobgLab];
    self.maskNoVideobgLab = maskNoVideobgLab;
    
    BOOL isBeginClass = [YSLiveManager shareInstance].isBeginClass;
    
    if (isBeginClass)
    {
        maskNoVideobgLab.text = YSLocalized(@"Prompt.DataLoading");
    }
    
//    self.maskNoVideobgLab.hidden = isBeginClass;
    
    self.backVideoView = [[UIView alloc]init];
    self.backVideoView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.backVideoView];
    
    UIView * maskBackView = [[UIView alloc]init];
    maskBackView.backgroundColor = UIColor.clearColor;
    [self.backVideoView addSubview:maskBackView];
    self.maskBackView = maskBackView;

    
    //关闭视频时的蒙版
    self.maskCloseVideoBgView = [[UIView alloc] init];
    self.maskCloseVideoBgView.backgroundColor = [UIColor bm_colorWithHexString:@"#EDEDED"];
    [maskBackView addSubview:self.maskCloseVideoBgView];
    self.maskCloseVideoBgView.hidden = YES;

    self.maskCloseVideo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closeVideo_SCVideoViewImage"]];
    self.maskCloseVideo.contentMode = UIViewContentModeScaleAspectFit;
    [self.maskCloseVideoBgView addSubview:self.maskCloseVideo];

    ///点击Home键提示蒙版
    self.homeMaskLab = [[UILabel alloc]init];
    self.homeMaskLab.text = YSLocalized(@"State.teacherInBackGround");
    self.homeMaskLab.font = UI_FONT_12;
    self.homeMaskLab.textColor = UIColor.whiteColor;
    [maskBackView addSubview:self.homeMaskLab];
    [self.homeMaskLab setAdjustsFontSizeToFitWidth:YES];
    self.homeMaskLab.numberOfLines = 2;
    self.homeMaskLab.textAlignment = NSTextAlignmentCenter;
    self.homeMaskLab.backgroundColor = UIColor.clearColor;
    self.homeMaskLab.hidden = YES;
    
    //没有摄像头时的蒙版
    self.maskNoVideo = [[UIView alloc] init];
    self.maskNoVideo.backgroundColor = [UIColor bm_colorWithHexString:@"#6D7278"];
    [maskBackView addSubview:self.maskNoVideo];
    self.maskNoVideo.hidden = YES;
    
    //没有连摄像头时的文字
    UILabel * maskNoVideoTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 20)];
    maskNoVideoTitle.backgroundColor = [UIColor clearColor];
    maskNoVideoTitle.font = UI_FONT_14;
    maskNoVideoTitle.textColor = UIColor.whiteColor;
    maskNoVideoTitle.adjustsFontSizeToFitWidth = YES;
    maskNoVideoTitle.minimumScaleFactor = 0.3;
    maskNoVideoTitle.numberOfLines = 0;
    maskNoVideoTitle.textAlignment = NSTextAlignmentCenter;
    [self.maskNoVideo addSubview:maskNoVideoTitle];
    self.maskNoVideoTitle = maskNoVideoTitle;
    
    //奖杯
    self.cupImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    self.cupImage.image = [UIImage imageNamed:@"cup_SmallClassImage"];
    self.cupImage.hidden = NO;
    [self.backVideoView addSubview:self.cupImage];
    
    //奖杯个数
    self.cupNumLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 20)];
    self.cupNumLab.backgroundColor = [UIColor clearColor];
    self.cupNumLab.font = UI_FONT_14;
    self.cupNumLab.text = @"× 0";
    self.cupNumLab.textColor = [UIColor bm_colorWithHexString:@"#FFE895"];
    self.cupNumLab.adjustsFontSizeToFitWidth = YES;
    self.cupNumLab.minimumScaleFactor = 0.3;
    self.cupNumLab.hidden = NO;
    [self.backVideoView addSubview:self.cupNumLab];
    
    //画笔权限
    self.brushImageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageNamed:@"brush_SmallClassImage"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.brushImageView.image = image;
    self.brushImageView.hidden = NO;
    [self.backVideoView addSubview:self.brushImageView];
    
    //举手图标
    self.raiseHandImage = [[UIImageView alloc] init];
    self.raiseHandImage.image = [UIImage imageNamed:@"videlHand"];
    self.raiseHandImage.hidden = YES;
    [self.backVideoView addSubview:self.raiseHandImage];
    
    //用户名
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.font = UI_FONT_16;
    self.nickNameLab.textColor = UIColor.whiteColor;
    self.nickNameLab.adjustsFontSizeToFitWidth = YES;
    self.nickNameLab.minimumScaleFactor = 0.3;
    self.nickNameLab.hidden = NO;
    [self.backVideoView addSubview:self.nickNameLab];
    
    //声音图片
    self.soundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beSilent_SmallClassImage"]];
    self.soundImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.backVideoView addSubview:self.soundImage];
    
    UILabel * silentLab = [[UILabel alloc]init];
//    silentLab.text = YSLocalized(@"Prompt.DisableMicrophone");
    silentLab.font = UI_FONT_16;
    silentLab.textColor = UIColor.whiteColor;
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
    self.maskNoVideobgLab.frame = self.bounds;
    self.backVideoView.frame = self.bounds;
    self.maskBackView.frame = self.bounds;
    self.maskCloseVideoBgView.frame = self.bounds;
    self.homeMaskLab.frame = self.bounds;
    self.maskNoVideo.frame = self.bounds;
    self.maskNoVideoTitle.frame = CGRectMake(2, 10, self.bm_width-4, self.bm_height-25);
    
    CGFloat imageWidth = frame.size.height*0.3f;
    if (imageWidth > self.maskCloseVideo.image.size.width)
    {
        imageWidth = self.maskCloseVideo.image.size.width;
    }
    CGFloat imageHeight = imageWidth;
    if (self.maskCloseVideo.image.size.width > 0)
    {
        imageHeight = imageWidth * self.maskCloseVideo.image.size.height / self.maskCloseVideo.image.size.width;
    }
    self.maskCloseVideo.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    [self.maskCloseVideo bm_centerInSuperView];
    
    if (self.appUseTheType == YSAppUseTheTypeMeeting || self.roomUser.role == YSUserType_Teacher || self.roomUser.role == YSUserType_Assistant)
    {
        self.cupImage.hidden = YES;
        self.cupNumLab.hidden = YES;
    }
    else
    {
        self.cupImage.hidden = NO;
        self.cupNumLab.hidden = NO;
        self.cupImage.bm_width = 20*widthScale;
        self.cupImage.bm_height = 20*widthScale;
        self.cupNumLab.bm_centerY = self.cupImage.bm_centerY;
        self.cupNumLab.bm_left = self.cupImage.bm_right + 4;
        self.cupNumLab.bm_width = 100*widthScale;
    }
   
    self.brushImageView.frame = CGRectMake(self.bm_width-(8+20)*widthScale, 5*heightScale, 20*widthScale, 20*widthScale);
    
    self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX-(10+25)*widthScale, 5*heightScale, 25*widthScale, 25*widthScale);
    
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
    self.soundImage.frame = CGRectMake(self.bm_width-5-soundImageWidth, self.bm_height-4-height, soundImageWidth, height);
    self.silentLab.frame = CGRectMake(self.bm_width-150*widthScale, self.bm_height-4-height, 150*widthScale, height);
}

/// 当前设备音量  音量大小 0 ～ 32670
- (void)setIVolume:(NSUInteger)iVolume
{
    _iVolume = iVolume;
    if (self.roomUser.publishState == YSUser_PublishState_VIDEOONLY || self.roomUser.publishState == 4 || ([YSLiveManager shareInstance].isEveryoneNoAudio && self.roomUser.role != YSUserType_Teacher))
    {
        self.soundImage.image = [UIImage imageNamed:@"beSilent_SmallClassImage"];
        return;
    }

    CGFloat volumeScale = 32670/4;
    
    if (iVolume<1)
    {
        if (self.lastVolume>1)
        {
            self.soundImage.image = [UIImage imageNamed:@"sound_no_SmallClassImage"];
        }
        
    }
    else if (iVolume<= volumeScale)
    {
        if (self.lastVolume>volumeScale || self.lastVolume<1)
        {
            self.soundImage.image = [UIImage imageNamed:@"sound_1_SmallClassImage"];
        }
    }
    else if (iVolume<= volumeScale*2)
    {
        if (self.lastVolume> volumeScale*2 || self.lastVolume<= volumeScale)
        {
            self.soundImage.image = [UIImage imageNamed:@"sound_2_SmallClassImage"];
        }
    }
    else if (iVolume > volumeScale*2)
    {
        if (self.lastVolume<=volumeScale*2)
        {
            self.soundImage.image = [UIImage imageNamed:@"sound_3_SmallClassImage"];
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
    self.raiseHandImage.hidden = !isRaiseHand;
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
               self.maskNoVideo.hidden = YES;
               self.maskNoVideoTitle.text = nil;
           }
    }
    
    if (videoState & SCVideoViewVideoState_DeviceError)
    {
        self.maskNoVideo.hidden = NO;
        [self.maskBackView bringSubviewToFront:self.maskNoVideo];
        
        switch (self.videoDeviceState)
        {
            // 无设备
            case YSDeviceFaultNotFind:
            {
                self.maskNoVideoTitle.text = YSLocalized(@"Prompt.NoCamera");
            }
                break;
                
            // 设备被禁用
            case YSDeviceFaultNotAuth:
            {
                self.maskNoVideoTitle.text = YSLocalized(@"Prompt.DisableCamera");
            }
                break;
                
            // 设备被占用
            case YSDeviceFaultOccupied:
            {
                self.maskNoVideoTitle.text = YSLocalized(@"Prompt.CameraOccupied");
            }
                break;
                
            case YSDeviceFaultUnknown:
            {
                 self.maskNoVideoTitle.text = YSLocalized(@"Prompt.DeviceUnknownError");
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
                self.maskNoVideoTitle.text = [NSString stringWithFormat:@"%@:%@", @(self.videoDeviceState), YSLocalized(@"Prompt.CanotOpenCamera")];
            }
                break;
        }
        return;
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
        [self.maskBackView bringSubviewToFront:self.maskCloseVideoBgView];
        return;
    }
    
    // 弱网环境
    if (videoState & SCVideoViewVideoState_PoorInternet)
    {
        self.homeMaskLab.hidden = NO;
        
        if ([self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//本地
            self.homeMaskLab.text = YSLocalized(@"State.PoorNetWork.self");
        }
        else
        {
            self.homeMaskLab.text = YSLocalized(@"State.PoorNetWork.other");
        }
        [self.maskBackView bringSubviewToFront:self.homeMaskLab];
        
        return;
    }
    
    // 用户进入后台
    if (videoState & SCVideoViewVideoState_InBackground)
    {
        if (self.roomUser.role == YSUserType_Student)
        {
            self.homeMaskLab.hidden = NO;
            self.homeMaskLab.text = YSLocalized(@"State.teacherInBackGround");
            [self.maskBackView bringSubviewToFront:self.homeMaskLab];
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
    self.soundImage.hidden = NO;
    self.soundImage.image = [UIImage imageNamed:@"sound_no_SmallClassImage"];
    
    // 设备不可用
    if (audioState & SCVideoViewAudioState_DeviceError)
    {
        self.silentLab.hidden = NO;
        self.soundImage.hidden = YES;
        
        switch (self.audioDeviceState)
        {
            // 无设备
            case YSDeviceFaultNotFind:
            {
                self.silentLab.text = YSLocalized(@"Prompt.NoMicrophone");
            }
                break;
                
            // 设备被禁用
            case YSDeviceFaultNotAuth:
            {
                self.silentLab.text = YSLocalized(@"Prompt.DisableMicrophone");
            }
                break;
                
            // 设备被占用
            case YSDeviceFaultOccupied:
            {
                self.silentLab.text = YSLocalized(@"Prompt.MicrophoneOccupied");
            }
                break;
                
            case YSDeviceFaultUnknown:
            {
                self.silentLab.text = YSLocalized(@"Prompt.DeviceUnknownError");
            }
                break;

            // 设备打开失败
            default:
            {
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
        self.soundImage.hidden = YES;
        return;
    }
    
    // 音频播放失败
    if (audioState & SCVideoViewAudioState_PlayFailed)
    {
        self.silentLab.hidden = NO;
        self.silentLab.text = YSLocalized(@"Prompt.AudioBuffering");
        self.soundImage.hidden = YES;
        return;
    }
#endif
    
    self.silentLab.hidden = YES;
    self.soundImage.hidden = NO;
    
    // 用户关闭麦克风
    if (audioState & SCVideoViewAudioState_Close)
    {
        self.soundImage.image = [UIImage imageNamed:@"beSilent_SmallClassImage"];
        return;
    }

    // 正常
    if (audioState == SCVideoViewAudioState_Normal)
    {
        self.soundImage.image = [UIImage imageNamed:@"sound_no_SmallClassImage"];
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
//        self.maskNoVideobgLab.hidden = self.roomUser.hasVideo;
//        self.maskNoVideobgLab.hidden = (self.roomUser.vfail == YSDeviceFaultNone);
        self.backVideoView.hidden = YES;
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
                }
                if (isInBackGround != [self.roomUser.properties bm_boolForKey:sUserIsInBackGround])
                {
                    [[YSLiveManager shareInstance].roomManager changeUserProperty:YSCurrentUser.peerID tellWhom:YSRoomPubMsgTellAll key:sUserIsInBackGround value:@(isInBackGround) completion:nil];
                }
        }

//        self.maskNoVideobgLab.hidden = YES;
        
        self.canDraw = [self.roomUser.properties bm_boolForKey:sUserCandraw];
        self.giftNumber = [self.roomUser.properties bm_uintForKey:sUserGiftNumber];
        
        NSString *brushColor = [self.roomUser.properties bm_stringTrimForKey:sUserPrimaryColor];
        if ([brushColor bm_isNotEmpty])
        {
            self.brushColor = brushColor;
        }

        // 视频相关
        
        // 低端设备
        BOOL low = [[YSLiveManager shareInstance] devicePlatformLowEndEquipment];
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
        if ([self.roomUser.properties bm_containsObjectForKey:sUserVideoFail])
        {
            if (self.roomUser.hasVideo)
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
                self.videoDeviceState = YSDeviceFaultNotAuth;
            }
        }
        else
        {
            if (!deviceError && !self.roomUser.hasVideo)
            {
                // 无设备
                deviceError = YES;
                // 设备禁用
                self.videoDeviceState = YSDeviceFaultNotAuth;
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

        YSPublishState publishState = [self.roomUser.properties bm_intForKey:sUserPublishstate];
        if (publishState == YSUser_PublishState_AUDIOONLY || publishState == 4)
        {
            // 关闭视频
            self.videoState |= SCVideoViewVideoState_Close;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_Close;
        }
        
        // 网络状态
        BOOL isPoorNetWork = [self.roomUser.properties bm_boolForKey:sUserNetWorkState];
        if (isPoorNetWork)
        {
            self.videoState |= SCVideoViewVideoState_PoorInternet;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_PoorInternet;
        }
        
        // 进入后台(home键)
        BOOL isInBackGround = [self.roomUser.properties bm_boolForKey:sUserIsInBackGround];
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
        if ([self.roomUser.properties bm_containsObjectForKey:sUserAudioFail])
        {
            if (self.roomUser.hasAudio)
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
                self.audioDeviceState = YSDeviceFaultNotAuth;
            }
        }
        else
        {
            if (!deviceError && !self.roomUser.hasAudio)
            {
                // 无设备
                deviceError = YES;
                // 设备禁用
                self.audioDeviceState = YSDeviceFaultNotAuth;
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

        if (publishState == YSUser_PublishState_VIDEOONLY || publishState == 4 || ([YSLiveManager shareInstance].isEveryoneNoAudio && self.roomUser.role != YSUserType_Teacher))
        {
            // 关闭音频
            self.audioState |= SCVideoViewAudioState_Close;
        }
        else
        {
            self.audioState &= ~SCVideoViewAudioState_Close;
        }
    }
}

///// 是否被禁音
//- (void)setDisableSound:(BOOL)disableSound
//{
//    _disableSound = disableSound;
//    if (disableSound)
//    {
//        self.soundImage.image = [UIImage imageNamed:@"beSilent_SmallClassImage"];
//    }
//    else
//    {
//        self.soundImage.image = [UIImage imageNamed:@"sound_no_SmallClassImage"];
//    }
//}

/// 是否被禁视频
//- (void)setDisableVideo:(BOOL)disableVideo
//{
//    _disableVideo = disableVideo;
//    self.maskCloseVideoBgView.hidden = !disableVideo;
//
//    if (self.iHasVadeo)
//    {
//        [self.maskBackView bringSubviewToFront:self.maskCloseVideoBgView];
//    }
//    else
//    {
//        [self.maskBackView bringSubviewToFront:self.maskNoVideo];
//    }
//}

/// 是否点击了home键
//- (void)setIsInBackGround:(BOOL)isInBackGround
//{
//    _isInBackGround = isInBackGround;
//
//    if (!self.isPoorNetWork)
//    {
//        if (self.roomUser.role == YSUserType_Student)
//        {
//            self.homeMaskLab.hidden =!isInBackGround;
//        }
//        else
//        {
//            self.homeMaskLab.hidden = YES;
//        }
//    }
//}

// 用户是否网络不好
//- (void)setIsPoorNetWork:(BOOL)isPoorNetWork
//{
//    _isPoorNetWork = isPoorNetWork;
//    self.homeMaskLab.hidden = !isPoorNetWork;
//
//    if ([self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
//    {//本地
//        if (isPoorNetWork)
//        {
//            self.homeMaskLab.text = YSLocalized(@"State.PoorNetWork.self");
//            [self.maskBackView bringSubviewToFront:self.homeMaskLab];
//        }
//    }
//    else
//    {
//        if (self.iHasVadeo && isPoorNetWork)
//        {
//            self.homeMaskLab.text = YSLocalized(@"State.PoorNetWork.other");
//            [self.maskBackView bringSubviewToFront:self.homeMaskLab];
//        }
//    }
//}
//
///////低端设备
//- (void)setIsLowDevice:(BOOL)isLowDevice
//{
//    _isLowDevice = isLowDevice;
//
//    if (isLowDevice && self.roomUser.role != YSUserType_Teacher && ![self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
//    {
//        self.maskNoVideo.hidden = NO;
//        self.maskNoVideoTitle.text = YSLocalized(@"Prompt.LowDeviceTitle");
//        [self.maskBackView bringSubviewToFront:self.maskNoVideo];
//    }
//    else
//    {
//        self.maskNoVideo.hidden = YES;
//        self.maskNoVideoTitle.text = nil;
//    }
//}

///该用户有开摄像
//- (void)setIHasVadeo:(BOOL)iHasVadeo
//{
//    _iHasVadeo = iHasVadeo;
//
//    if (!iHasVadeo)
//    {
//        self.maskNoVideo.hidden = NO;
//        if ([self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
//        {//本地
//            if (self.isPoorNetWork)
//            {
//                [self.maskBackView bringSubviewToFront:self.homeMaskLab];
//            }
//            else
//            {
//                self.maskNoVideoTitle.text = YSLocalized(@"Prompt.NoCamera");
//                [self.maskBackView bringSubviewToFront:self.maskNoVideo];
//            }
//        }
//        else
//        {
//            if (self.isLowDevice && self.roomUser.role != YSUserType_Teacher)
//            {
//                self.maskNoVideoTitle.text = YSLocalized(@"Prompt.LowDeviceTitle");
//                [self.maskBackView bringSubviewToFront:self.maskNoVideo];
//            }
//            else
//            {
//                self.maskNoVideoTitle.text = YSLocalized(@"Prompt.NoCamera");
//                [self.maskBackView bringSubviewToFront:self.maskNoVideo];
//            }
//
//        }
//    }
//    else
//    {
//        if (!self.isLowDevice)
//        {
//            self.maskNoVideo.hidden = YES;
//        }
//    }
//}

/////该用户有开麦克风
//- (void)setIHasAudio:(BOOL)iHasAudio
//{
//    _iHasAudio = iHasAudio;
//    self.silentLab.hidden = iHasAudio;
//    self.soundImage.hidden = !iHasAudio;
//}

@end
