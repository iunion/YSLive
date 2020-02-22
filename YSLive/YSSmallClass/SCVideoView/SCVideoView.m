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
///被禁视频时的蒙版
@property (nonatomic, strong) UIView *maskCloseVideoBgView;
@property (nonatomic, strong) UIImageView *maskCloseVideo;
///点击Home键提示蒙版
@property (nonatomic, strong)UIButton *homeMaskBtn;
///没有连摄像头时的蒙版
@property (nonatomic, strong) UIImageView *maskNoVideo;

/// 当前设备上次捕捉的音量  音量大小 0 ～ 32670
@property (nonatomic, assign) NSUInteger lastVolume;

///拖出时的文字字号
@property (nonatomic, strong) UIFont *dragFont;
///拖出时的文字字号
@property (nonatomic, strong)UIFont *notDragFont;

///举手图标
@property (nonatomic, strong) UIImageView *raiseHandImage;

///设备性能低时的蒙版
@property (nonatomic, strong) UIView *lowDeviceBgView;
///设备性能低时的蒙版上的文字
@property (nonatomic, strong) UILabel *lowDeviceTitle;


@end

@implementation SCVideoView

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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToShowControl)];
        [self addGestureRecognizer:tap];
        
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
        
        self.exclusiveTouch = YES;
    }
    return self;
}

//视频view点击事件
- (void)clickToShowControl
{
    if ([self.delegate respondsToSelector:@selector(clickViewToControlWithVideoView:)]) {
        [self.delegate clickViewToControlWithVideoView:self];
    }
}

///视频拖拽事件
- (void)panGestureToMoveView:(UIPanGestureRecognizer *)pan
{
    if ([self.delegate respondsToSelector:@selector(panToMoveVideoView:withGestureRecognizer:)]) {
        [self.delegate panToMoveVideoView:self withGestureRecognizer:pan];
    }
}

- (void)setupUIView
{
    self.backVideoView = [[UIView alloc]init];
    self.backVideoView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.backVideoView];
    
    //被禁视频时的蒙版
    self.maskCloseVideoBgView = [[UIView alloc] init];
    self.maskCloseVideoBgView.backgroundColor = [UIColor bm_colorWithHexString:@"#EDEDED"];
    [self.backVideoView addSubview:self.maskCloseVideoBgView];

    self.maskCloseVideo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closeVideo_SCVideoViewImage"]];
    self.maskCloseVideo.contentMode = UIViewContentModeScaleAspectFit;
    [self.maskCloseVideoBgView addSubview:self.maskCloseVideo];

    ///点击Home键提示蒙版
    self.homeMaskBtn = [[UIButton alloc]init];
    [self.homeMaskBtn setTitle:YSLocalized(@"State.teacherInBackGround") forState:UIControlStateNormal];
    [self.homeMaskBtn setImage:[UIImage imageNamed:@"homeRemind_SCVideoViewImage"] forState:UIControlStateNormal];
    self.homeMaskBtn.titleLabel.font = UI_FONT_12;
    [self.backVideoView addSubview:self.homeMaskBtn];
    
    //没有摄像头时的蒙版
    self.maskNoVideo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noVideo_SCVideoViewImage"]];
    self.maskNoVideo.contentMode = UIViewContentModeScaleAspectFit;
    self.maskNoVideo.backgroundColor = [UIColor bm_colorWithHexString:@"#EDEDED"];
    [self.backVideoView addSubview:self.maskNoVideo];
    
    //设备性能低时的蒙版
    self.lowDeviceBgView = [[UIView alloc] init];
    self.lowDeviceBgView.backgroundColor = [UIColor bm_colorWithHexString:@"#6D7278"];
    [self.backVideoView addSubview:self.lowDeviceBgView];
    
    BOOL isHighDevice = [[YSLiveManager shareInstance] devicePlatformHighEndEquipment];
    if (isHighDevice || self.roomUser.role == YSUserType_Teacher || [self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
    {
        self.lowDeviceBgView.hidden = YES;
    }
    else
    {
        self.lowDeviceBgView.hidden = NO;
    }
    
    //设备性能低时的蒙版上的文字
    UILabel * lowDeviceTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 20)];
    lowDeviceTitle.backgroundColor = [UIColor clearColor];
    lowDeviceTitle.font = UI_FONT_14;
    lowDeviceTitle.text = YSLocalized(@"Prompt.LowDeviceTitle");
    lowDeviceTitle.textColor = UIColor.whiteColor;
    lowDeviceTitle.adjustsFontSizeToFitWidth = YES;
    lowDeviceTitle.minimumScaleFactor = 0.3;
    lowDeviceTitle.numberOfLines = 0;
    lowDeviceTitle.textAlignment = NSTextAlignmentCenter;
    [self.lowDeviceBgView addSubview:lowDeviceTitle];
    self.lowDeviceTitle = lowDeviceTitle;
    
    
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
//    UIImage *handImage = [UIImage imageNamed:@"videlHand"];
//    handImage = [handImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.raiseHandImage.image = [UIImage imageNamed:@"videlHand"];
    
    self.raiseHandImage.hidden = YES;
    [self.backVideoView addSubview:self.raiseHandImage];
    
    
    //用户名
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.font = UI_FONT_16;
    self.nickNameLab.textColor = UIColor.whiteColor;
    self.nickNameLab.adjustsFontSizeToFitWidth = YES;
    self.nickNameLab.minimumScaleFactor = 0.3;
    self.nickNameLab.hidden = NO;
    [self.backVideoView addSubview:self.nickNameLab];
    if (![self.roomUser.peerID isEqualToString:@"0"])
    {
        self.nickNameLab.text = self.roomUser.nickName;
    }
    
    //声音图片
    self.soundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beSilent_SmallClassImage"]];
    self.soundImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.backVideoView addSubview:self.soundImage];
    
    
    if (self.isForPerch)
    {
        self.backVideoView.hidden = YES;
    }
    else
    {
        YSPublishState publishState = [self.roomUser.properties bm_intForKey:sUserPublishstate];
        if (publishState == YSUser_PublishState_AUDIOONLY || publishState == YSUser_PublishState_BOTH)
        {
            self.disableSound = NO;
        }
        else
        {
            self.disableSound = YES;
        }
        
        if (publishState == YSUser_PublishState_VIDEOONLY || publishState == YSUser_PublishState_BOTH)
        {
            self.disableVideo = NO;
        }
        else
        {
            self.disableVideo = YES;
        }
        
        self.canDraw = [self.roomUser.properties bm_boolForKey:sUserCandraw];
        self.giftNumber = [self.roomUser.properties bm_uintForKey:sUserGiftNumber];
        self.isInBackGround = [self.roomUser.properties bm_boolForKey:sUserIsInBackGround];
        self.iHasVadeo = self.roomUser.hasVideo;
        
        NSString *brushColor = [self.roomUser.properties bm_stringTrimForKey:sUserPrimaryColor];
        if ([brushColor bm_isNotEmpty])
        {
            self.brushColor = brushColor;
        }
    }
    
    if (self.isDragOut || self.isFullScreen)
    {
        self.nickNameLab.font = self.cupNumLab.font = self.dragFont;
    }
    else
    {
        self.nickNameLab.font = self.cupNumLab.font = self.notDragFont;
        
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.backVideoView.frame = self.bounds;
    self.maskCloseVideoBgView.frame = self.bounds;
    self.homeMaskBtn.frame = self.bounds;
    self.maskNoVideo.frame = self.bounds;
    self.lowDeviceBgView.frame = self.bounds;
    self.lowDeviceTitle.frame = CGRectMake(5, 10, self.bm_width-10, self.bm_height-25) ;
    
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
    
    if (self.appUseTheType == YSAppUseTheTypeMeeting || self.roomUser.role == YSUserType_Teacher)
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
    
    CGFloat height = 20*widthScale;
    if (height < 12)
    {
        height = 12;
    }
    self.nickNameLab.frame = CGRectMake(7*widthScale,self.bm_height-4-height, 120*widthScale, height);
    CGFloat soundImageWidth = height*5/3;
    self.soundImage.frame = CGRectMake(self.bm_width-5-soundImageWidth, self.bm_height-4-height, soundImageWidth, height);
}

/// 当前设备音量  音量大小 0 ～ 32670
- (void)setIVolume:(NSUInteger)iVolume
{
    _iVolume = iVolume;
    
    if (self.disableSound)
    {
        self.soundImage.image = [UIImage imageNamed:@"beSilent_SmallClassImage"];
        return;
    }
    CGFloat volumeScale = 32670/4;
    
    if (iVolume<1)
    {
        if (self.lastVolume>1) {
            self.soundImage.image = [UIImage imageNamed:@"sound_no_SmallClassImage"];
        }
        
    }
    else if (iVolume<= volumeScale)
    {
        if (self.lastVolume>volumeScale || self.lastVolume<1) {
            self.soundImage.image = [UIImage imageNamed:@"sound_1_SmallClassImage"];
        }
    }
    else if (iVolume<= volumeScale*2)
    {
        if (self.lastVolume> volumeScale*2 || self.lastVolume<= volumeScale) {
            self.soundImage.image = [UIImage imageNamed:@"sound_2_SmallClassImage"];
        }
    }
    else if (iVolume > volumeScale*2)
    {
        if (self.lastVolume<=volumeScale*2) {
            self.soundImage.image = [UIImage imageNamed:@"sound_3_SmallClassImage"];
        }
        
    }
}

///该用户有开摄像
- (void)setIHasVadeo:(BOOL)iHasVadeo
{
    _iHasVadeo = iHasVadeo;
    
    self.maskNoVideo.hidden = iHasVadeo;
    if (!iHasVadeo)
    {
        self.maskNoVideo.image = [UIImage imageNamed:@"noVideo_SCVideoViewImage"];
        //        [self bringSubviewToFront:self.maskNoVideo];
        //        [self bringSubviewToFront:self.backVideoView];
    }
}

/// 奖杯数
- (void)setGiftNumber:(NSUInteger)giftNumber
{
    _giftNumber = giftNumber;
    
    if (self.roomUser.role != YSUserType_Teacher)
    {
        //self.cupImage.hidden = (giftNumber==0);
        //self.cupNumLab.hidden = (giftNumber==0);
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

/// 是否被禁音
- (void)setDisableSound:(BOOL)disableSound
{
    _disableSound = disableSound;
    if (disableSound)
    {
        self.soundImage.image = [UIImage imageNamed:@"beSilent_SmallClassImage"];
    }
    else
    {
        self.soundImage.image = [UIImage imageNamed:@"sound_no_SmallClassImage"];
    }
}

/// 是否被禁视频
- (void)setDisableVideo:(BOOL)disableVideo
{
    _disableVideo = disableVideo;
    self.maskCloseVideoBgView.hidden = !disableVideo;
    if (disableVideo)
    {
        //        [self bringSubviewToFront:self.maskCloseVideo];
        //        [self bringSubviewToFront:self.backVideoView];
    }
}

/// 是否点击了home键
- (void)setIsInBackGround:(BOOL)isInBackGround
{
    _isInBackGround = isInBackGround;
    self.homeMaskBtn.hidden =!isInBackGround;
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


- (void)changeRoomUserProperty:(YSRoomUser *)roomUser
{
    self.roomUser = roomUser;
}




@end
