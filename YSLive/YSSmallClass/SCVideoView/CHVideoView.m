//
//  CHVideoView.m
//  YSLive
//
//  Created by jiang deng on 2021/4/8.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHVideoView.h"
#import "CHPanGestureControl.h"

#define widthScale  self.bm_width/([UIDevice bm_isiPad]? 400 : 300)
#define heightScale self.bm_height/([UIDevice bm_isiPad]? 260 : 160)

@interface CHVideoView ()
<
    UIGestureRecognizerDelegate
>

@property (nonatomic, strong) CHRoomUser *roomUser;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

/// popView的基准View
@property (nonatomic, strong) UIView *sourceView;

/// 背景view
@property (nonatomic, strong) UIView *backView;
/// 正在加载中
@property (nonatomic, strong) UIImageView *loadingImageView;

/// 视频承载View
@property (nonatomic, strong) UIView *contentView;


/// 所有蒙版的背景View
@property (nonatomic, strong) UIView *maskBackView;

/// 关闭视频时的蒙版
@property (nonatomic, strong) UIView *maskCloseVideoBgView;
@property (nonatomic, strong) UIImageView *maskCloseVideoImageView;

/// 点击Home键进入后台提示蒙版
@property (nonatomic, strong) UILabel *homeMaskLabel;

/// 没有连摄像头时的蒙版
@property (nonatomic, strong) UIView *maskNoVideoBgView;
/// 上课后没有连摄像头时的文字
@property (nonatomic, strong) UILabel *maskNoVideoLabel;


/// 上层数据View
@property (nonatomic, strong) UIView *coverView;
#if CH_OldGroup
/// 分组蒙版
@property (nonatomic, strong) UIView *maskGroupRoomBgView;
@property (nonatomic, strong) UIImageView *maskGroupRoomImageView;
#endif
/// 奖杯
@property (nonatomic, strong) UIImageView *cupImageView;
/// 奖杯个数
@property (nonatomic, strong) UILabel *cupNumLabel;
/// 画笔权限
@property (nonatomic, strong) UIImageView *brushImageView;
/// 用户名
@property (nonatomic, strong) UILabel *nickNameLabel;
/// 声音图标
@property (nonatomic, strong) UIImageView *soundImageView;

/// 弱网图标
@property (nonatomic, strong) UIImageView *lowWifiImageView;
/// 举手图标
@property (nonatomic, strong) UIImageView *raiseHandImageView;

/// 当前设备音量  音量大小 0 ～ 255
@property (nonatomic, assign) NSUInteger iVolume;
/// 音量等级，根据 iVolume 计算
@property (nonatomic, assign) NSUInteger volumeStep;
/// 奖杯数
@property (nonatomic, assign) NSUInteger giftNumber;
/// 画笔颜色值
@property (nonatomic, strong) NSString *brushColor;
/// 画笔权限
@property (nonatomic, assign) BOOL canDraw;

@end

@implementation CHVideoView

- (void)dealloc
{
    NSString *notificationKey = [NSString stringWithFormat:@"%@%@", CHRoomUserPropertiesChangedNotification, self.roomUser.peerID];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationKey object:nil];
}

// 学生用
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId
{
    return [self initWithRoomUser:roomUser withSourceId:sourceId isForPerch:NO];
}

- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId isForPerch:(BOOL)isForPerch
{
    return [self initWithRoomUser:roomUser withSourceId:sourceId isForPerch:isForPerch withDelegate:nil];
}

// 老师用
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId withDelegate:(id<CHVideoViewDelegate>)delegate
{
    return [self initWithRoomUser:roomUser withSourceId:sourceId isForPerch:NO withDelegate:delegate];
}

- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId isForPerch:(BOOL)isForPerch withDelegate:(id<CHVideoViewDelegate>)delegate
{
    self = [super init];

    if (self)
    {
        self.delegate = delegate;
        
        if ([sourceId isEqualToString:sCHUserDefaultSourceId] && [roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
            self.streamId = [NSString stringWithFormat:@"%@:video:%@",roomUser.peerID,sourceId];
        }
        
        self.roomUser = roomUser;
        self.sourceId = sourceId;
        self.isForPerch = isForPerch;
        
        [self setupUIView];
        
        if (YSCurrentUser.role == CHUserType_Teacher && delegate)
        {
            UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToShowControl)];
            oneTap.numberOfTapsRequired = 1;
            [self addGestureRecognizer:oneTap];
            
            // 拖拽手势
            self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureToMoveView:)];
            [self addGestureRecognizer:self.panGesture];
            
            self.panGesture.delegate = self;
        }
        else
        {
            if ([roomUser.peerID isEqualToString:YSCurrentUser.peerID])
            {
                UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToShowControl)];
                oneTap.numberOfTapsRequired = 1;
                [self addGestureRecognizer:oneTap];
            }
        }

        self.exclusiveTouch = YES;
    }
    
    return self;
}

// 判断手势是否可用
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.panGesture)
    {
        return NO;
    }
    else if ([[CHPanGestureControl shareInfo] isExistPanGestureAction:CHLONG_PRESS_VIEW_VIDEO])
    {
        return NO;
    }
    else
    {
        [[CHPanGestureControl shareInfo] addPanGestureAction:CHLONG_PRESS_VIEW_VIDEO];
        return YES;
    }
}

- (void)setRoomUser:(CHRoomUser *)roomUser
{
    _roomUser = roomUser;
    
    NSString *notificationKey = [NSString stringWithFormat:@"%@%@", CHRoomUserPropertiesChangedNotification, self.roomUser.peerID];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationKey object:nil];

    if (roomUser)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshWithRoomUserNotification:) name:notificationKey object:nil];
    }
}

- (void)freshWithRoomUserNotification:(NSNotification *)notification
{
    NSString *key = notification.object;
//#if DEBUG
//    NSLog(@"User change Property: %@", key);
//#endif
    
    if ([key isEqualToString:@"iVolume"])
    {
        self.iVolume = self.roomUser.iVolume;
    }
    else
    {
        [self freshWithRoomUser];
    }
}

/// 视频view点击事件
- (void)clickToShowControl
{
    if (self.appUseTheType == CHRoomUseTypeLiveRoom && [self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
    {
        if ([self.delegate respondsToSelector:@selector(clickViewToControlWithVideoView:)])
        {
            [self.delegate clickViewToControlWithVideoView:self];
        }
    }
    else
    {
        if (self.roomUser.role == CHUserType_Student || self.roomUser.role == CHUserType_Teacher)
        {
            if ([self.delegate respondsToSelector:@selector(clickViewToControlWithVideoView:)])
            {
                [self.delegate clickViewToControlWithVideoView:self];
            }
        }
    }
}

/// 视频拖拽事件
- (void)panGestureToMoveView:(UIPanGestureRecognizer *)pan
{
    if ([self.delegate respondsToSelector:@selector(panToMoveVideoView:withGestureRecognizer:)])
    {
        [self.delegate panToMoveVideoView:self withGestureRecognizer:pan];
    }
}

- (void)setupUIView
{
    self.backgroundColor = YSSkinDefineColor(@"Color9");
    
    // popView的基准View
    UIView *sourceView = [[UIView alloc] init];
    sourceView.backgroundColor = UIColor.clearColor;
    sourceView.hidden = YES;
    [self addSubview:sourceView];
    self.sourceView = sourceView;

    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = UIColor.clearColor;
    [self addSubview:backView];
    self.backView = backView;

    // 正在加载中
    UIImage *loadingImage = YSSkinElementImage(@"videoView_loadingImage", @"icon_normal");
    UIImageView *loadingImageView = [[UIImageView alloc] initWithImage:loadingImage];
    [loadingImageView setBackgroundColor:YSSkinDefineColor(@"Color9")];
    loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backView addSubview:loadingImageView];
    self.loadingImageView = loadingImageView;
    
    [self setupMaskView];

    // 视频承载View
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = UIColor.clearColor;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    [self setupCoverView];
    
    [self freshWithRoomUser];
}

- (void)setupMaskView
{
    /// 所有蒙版的背景View
    UIView *maskBackView = [[UIView alloc]init];
    maskBackView.backgroundColor = UIColor.clearColor;
    [self addSubview:maskBackView];
    self.maskBackView = maskBackView;

    // 关闭视频时的蒙版
    UIView *maskCloseVideoBgView = [[UIView alloc] init];
    maskCloseVideoBgView.backgroundColor = YSSkinDefineColor(@"Color9");
    [self.maskBackView addSubview:maskCloseVideoBgView];
    maskCloseVideoBgView.hidden = YES;
    self.maskCloseVideoBgView = maskCloseVideoBgView;

    UIImage *maskCloseImage = YSSkinElementImage(@"videoView_stateVideo", @"closeCam");
    UIImageView *maskCloseVideoImageView = [[UIImageView alloc] initWithImage:maskCloseImage];
    maskCloseVideoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.maskCloseVideoBgView addSubview:maskCloseVideoImageView];
    self.maskCloseVideoImageView = maskCloseVideoImageView;
    
    // 没有摄像头时的蒙版
    UIView *maskNoVideoBgView = [[UIView alloc] init];
    maskNoVideoBgView.backgroundColor = YSSkinDefineColor(@"Color9");;
    [self.maskBackView addSubview:maskNoVideoBgView];
    maskNoVideoBgView.hidden = YES;
    self.maskNoVideoBgView = maskNoVideoBgView;
    
    // 没有连摄像头时的文字
    UILabel *maskNoVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 20)];
    maskNoVideoLabel.backgroundColor = UIColor.clearColor;
    if ([UIDevice bm_isiPad])
    {
        maskNoVideoLabel.font = UI_FONT_14;
    }
    else
    {
        maskNoVideoLabel.font = UI_FONT_12;
    }
    maskNoVideoLabel.textColor = YSSkinDefineColor(@"Color3");
    maskNoVideoLabel.adjustsFontSizeToFitWidth = YES;
    maskNoVideoLabel.minimumScaleFactor = 0.3;
    maskNoVideoLabel.numberOfLines = 0;
    maskNoVideoLabel.textAlignment = NSTextAlignmentCenter;
    [self.maskNoVideoBgView addSubview:maskNoVideoLabel];
    self.maskNoVideoLabel = maskNoVideoLabel;
    
    // 点击Home键提示蒙版
    UILabel *homeMaskLabel = [[UILabel alloc] init];
    homeMaskLabel.text = YSLocalized(@"State.teacherInBackGround");
    if ([UIDevice bm_isiPad])
    {
        homeMaskLabel.font = UI_FONT_12;
    }
    else
    {
        homeMaskLabel.font = UI_FONT_10;
    }
    homeMaskLabel.textColor = YSSkinDefineColor(@"Color3");
    [self.maskBackView addSubview:homeMaskLabel];
    [homeMaskLabel setAdjustsFontSizeToFitWidth:YES];
    homeMaskLabel.numberOfLines = 2;
    homeMaskLabel.textAlignment = NSTextAlignmentCenter;
    homeMaskLabel.backgroundColor = UIColor.clearColor;
    homeMaskLabel.hidden = YES;
    self.homeMaskLabel = homeMaskLabel;
}

- (void)setupCoverView
{
    /// 上层数据View
    UIView *coverView = [[UIView alloc]init];
    coverView.backgroundColor = UIColor.clearColor;
    [self addSubview:coverView];
    self.coverView = coverView;
    
#if CH_OldGroup
    // 分组
    UIView *maskGroupRoomBgView = [[UIView alloc] init];
    maskGroupRoomBgView.backgroundColor = YSSkinDefineColor(@"Color9");
    [self.coverView addSubview:maskGroupRoomBgView];
    maskGroupRoomBgView.hidden = YES;
    self.maskGroupRoomBgView = maskGroupRoomBgView;
    
    UIImageView *maskGroupRoomImageView = [[UIImageView alloc] init];
    maskGroupRoomImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.maskGroupRoomBgView addSubview:maskGroupRoomImageView];
    self.maskGroupRoomImageView = maskGroupRoomImageView;
#endif
    // 奖杯
    UIImageView *cupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    cupImageView.image = YSSkinElementImage(@"videoView_trophyImage", @"iconNor");
    cupImageView.hidden = NO;
    [self.coverView addSubview:cupImageView];
    self.cupImageView = cupImageView;

    // 奖杯个数
    UILabel *cupNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 10)];
    cupNumLabel.text = @"× 0";
    cupNumLabel.textColor = YSSkinDefineColor(@"Color3");
    cupNumLabel.adjustsFontSizeToFitWidth = YES;
    cupNumLabel.minimumScaleFactor = 0.1;
    cupNumLabel.hidden = NO;
    [self.coverView addSubview:cupNumLabel];
    self.cupNumLabel = cupNumLabel;
    
    // 画笔权限
    UIImageView *brushImageView = [[UIImageView alloc] init];
    UIImage *image = YSSkinElementImage(@"videoView_authorizeLab", @"iconNor");
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    brushImageView.image = image;
    brushImageView.hidden = NO;
    [self.coverView addSubview:brushImageView];
    self.brushImageView = brushImageView;

    // 用户名
    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    nickNameLabel.backgroundColor = [UIColor clearColor];
    nickNameLabel.textColor = YSSkinDefineColor(@"Color3");
    nickNameLabel.adjustsFontSizeToFitWidth = YES;
    nickNameLabel.minimumScaleFactor = 0.3;
    nickNameLabel.hidden = NO;
    [self.coverView addSubview:nickNameLabel];
    self.nickNameLabel = nickNameLabel;
    
    // 声音
    UIImageView *soundImageView = [[UIImageView alloc] init];
    soundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.coverView addSubview:soundImageView];
    soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_noSound");
    self.soundImageView = soundImageView;

    // 弱网图标
    UIImageView *lowWifiImageView = [[UIImageView alloc] init];
    lowWifiImageView.image = YSSkinElementImage(@"videoView_stateVideo", @"lowWifi");
    lowWifiImageView.contentMode = UIViewContentModeScaleAspectFit;
    lowWifiImageView.hidden = YES;
    lowWifiImageView.backgroundColor = UIColor.clearColor;
    [self.coverView addSubview:lowWifiImageView];
    self.lowWifiImageView = lowWifiImageView;
    
    // 举手图标
    UIImageView *raiseHandImageView = [[UIImageView alloc] init];
    raiseHandImageView.image = YSSkinElementImage(@"videoView_handImageView", @"iconNor");
    raiseHandImageView.contentMode = UIViewContentModeScaleAspectFit;
    raiseHandImageView.hidden = YES;
    raiseHandImageView.backgroundColor = UIColor.clearColor;
    [self.coverView addSubview:raiseHandImageView];
    self.raiseHandImageView = raiseHandImageView;
}

- (void)changeVideoEncoderConfigurationWithOldWidth:(CGFloat)oldWidth newWidth:(CGFloat)newWidth
{
    CGFloat oldScale = oldWidth / BMUI_SCREEN_WIDTH_ROTATE;
    CGFloat newScale = newWidth / BMUI_SCREEN_WIDTH_ROTATE;

    int oldTag = 1;
    int newTag = 1;
    
    if (oldScale < 0.25)
    {
        oldTag = 1;
    }
    else if (oldScale < 0.34)
    {
        oldTag = 2;
    }
    else
    {
        oldTag = 3;
    }
    
    if (newScale < 0.25)
    {
        newTag = 1;
    }
    else if (newScale < 0.34)
    {
        newTag = 2;
    }
    else
    {
        newTag = 3;
    }

    NSInteger videowidth = 0;
    NSInteger videoheight = 0;
    CHRoomModel *roomModel = [YSLiveManager sharedInstance].roomModel;
    
    if ((!oldScale && newScale > 0) || oldTag != newTag)
    {
        if (newTag == 1)
        {
            videowidth = [roomModel.lowerResolution bm_intForKey:@"videowidth"];
            videoheight = [roomModel.lowerResolution bm_intForKey:@"videoheight"];
        }
        else if (newTag == 2)
        {
            videowidth = [roomModel.middleResolution bm_intForKey:@"videowidth"];
            videoheight = [roomModel.middleResolution bm_intForKey:@"videoheight"];
        }
        else
        {
            videowidth = [roomModel.highResolution bm_intForKey:@"videowidth"];
            videoheight = [roomModel.highResolution bm_intForKey:@"videoheight"];
        }
        
        // 容错处理
        if (videowidth == 0 || videoheight == 0)
        {
            videowidth = roomModel.videowidth;
            videoheight = roomModel.videoheight;
        }
        
        CloudHubVideoEncoderConfiguration *config = [[CloudHubVideoEncoderConfiguration alloc] initWithWidth:videowidth height:videoheight frameRate:roomModel.videoframerate];
        
        [[CHSessionManager sharedInstance].cloudHubRtcEngineKit setVideoEncoderConfiguration:config];
    }
}

- (void)setFrame:(CGRect)frame
{
    CGFloat oldWidth = self.bm_width;

    [super setFrame:frame];

    CGFloat newWidth = self.bm_width;

    // 动态调整自己的视频分辨率
    if ([self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
    {
        if ([YSLiveManager sharedInstance].roomModel.roomtype == CHRoomUseTypeSmallClass)
        {
            [self changeVideoEncoderConfigurationWithOldWidth:oldWidth newWidth:newWidth];
        }
    }
    
    self.backView.frame = self.bounds;
    self.maskBackView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.coverView.frame = self.bounds;

    self.sourceView.frame = CGRectMake((self.bounds.size.width - 50.0f)/2, (self.bounds.size.height - 50.0f)/2, 50.0f, 50.0f);

    CGFloat width = self.bm_height*0.7f;
    if (width>100)
    {
        width = 100;
    }
    self.loadingImageView.bm_size = CGSizeMake(width, width);
    [self.loadingImageView bm_centerInSuperView];
    
    self.maskCloseVideoBgView.frame = self.maskBackView.bounds;
    self.maskCloseVideoImageView.bm_size = CGSizeMake(width, width);
    [self.maskCloseVideoImageView bm_centerInSuperView];

    self.maskNoVideoBgView.frame = self.maskBackView.bounds;
    self.maskNoVideoLabel.frame = CGRectMake(2.0f, 10.0f, self.bm_width-4.0f, self.bm_height-25.0f);

    self.homeMaskLabel.frame = CGRectMake(0, 10.0f, self.bounds.size.width, self.bounds.size.height-20.0f);
#if CH_OldGroup
    self.maskGroupRoomBgView.frame = self.coverView.bounds;
    self.maskGroupRoomImageView.bm_size = CGSizeMake(width, width);
    [self.maskGroupRoomImageView bm_centerInSuperView];
#endif
    if (self.appUseTheType == CHRoomUseTypeLiveRoom || self.roomUser.role == CHUserType_Teacher || self.roomUser.role == CHUserType_Assistant)
    {
        self.cupImageView.hidden = YES;
        self.cupNumLabel.hidden = YES;
    }
    else
    {
        self.cupImageView.hidden = NO;
        self.cupNumLabel.hidden = NO;
    }
   
    int maxW = 25.0f;
    int minW = 7.0f;
    if ([UIDevice bm_isiPad])
    {
        maxW = 35.0f;
        minW = 10.0f;
    }
    
    CGFloat cupImageW = self.bm_width*0.1f ;
    
    if (self.bm_width*0.1f > maxW)
    {
        cupImageW = maxW;
    }
    else if (self.bm_width*0.1f < minW)
    {
        cupImageW = minW;
    }
        
    self.cupImageView.bm_width = self.cupImageView.bm_height = cupImageW;
    self.cupNumLabel.bm_width = self.bm_width*0.3f;
    self.cupNumLabel.bm_top = self.cupImageView.bm_top;
    self.cupNumLabel.bm_height = self.cupImageView.bm_height;
    self.cupNumLabel.bm_left = self.cupImageView.bm_right + 4.0f;
    CGFloat fontSize = self.cupImageView.bm_height-2.0f;
    if (fontSize<1.0f)
    {
        fontSize = 1.0f;
    }
    else if (fontSize>24.0f)
    {
        fontSize = 24.0f;
    }
    self.cupNumLabel.font = [UIFont systemFontOfSize:fontSize];
        
    self.brushImageView.frame = CGRectMake(self.bm_width - self.cupImageView.bm_width - 4, self.cupImageView.bm_originY, self.cupImageView.bm_width, self.cupImageView.bm_width);
    
    [self freshOtherIcon];
    
    CGFloat height = self.bm_width*0.1f;
    if ([UIDevice bm_isiPad])
    {
        minW = 12.0f;
    }
    else
    {
        minW = 10.0f;
    }
    if (height < minW)
    {
        height = minW;
    }
    
    self.nickNameLabel.frame = CGRectMake(4, self.bm_height-4.0f-height, self.bm_width*0.5f, height);
        
    fontSize = height-5.0f;
    if ([UIDevice bm_isiPad])
    {
        maxW = 20.0f;
    }
    else
    {
        maxW = 16.0f;
    }
    
    if (fontSize<1)
    {
        fontSize = 1.0f;
    }
    else if (fontSize>maxW)
    {
        fontSize = maxW;
    }
    self.nickNameLabel.font = [UIFont systemFontOfSize:fontSize];
    
    if ([UIDevice bm_isiPad])
    {
        maxW = 55.0f;
        minW = 20.0f;
    }
    else
    {
        maxW = 40.0f;
        minW = 15.0f;
    }
    
    CGFloat soundImageWidth = height*5.0f/3.0f;
    if (soundImageWidth > maxW)
    {
        soundImageWidth = maxW;
    }
    else if (soundImageWidth < minW)
    {
        soundImageWidth = minW;
    }
    
    self.soundImageView.frame = CGRectMake(self.bm_width-5.0f-soundImageWidth, self.bm_height-4.0f-height, soundImageWidth, height);
}

- (BOOL)getIsVertical
{
    BOOL isVertical = NO;
    
    CGFloat width = self.bm_width;
    CGFloat height = self.bm_height;
    
    CGFloat scaleVide = (width + 1.0f)/height;
    
    if ([YSLiveManager sharedInstance].room_IsWideScreen)
    {
        CGFloat scaleVideoW = 16.0 / 9.0;
        
        if (scaleVide < scaleVideoW)
        {
            isVertical = YES;
        }
    }
    else
    {
        CGFloat scaleVideoH = 4.0 / 3.0;
        if (scaleVide < scaleVideoH)
        {
            isVertical = YES;
        }
    }
    return isVertical;
}

- (void)freshOtherIcon
{
    CGFloat cupImageW = self.cupImageView.bm_width;
    
    if (self.lowWifiImageView.hidden == YES)
    {
        if ([self getIsVertical])
        {
            self.raiseHandImageView.frame = CGRectMake(self.brushImageView.bm_left, self.brushImageView.bm_bottom + 5.0f, cupImageW, cupImageW);
        }
        else
        {
            self.raiseHandImageView.frame = CGRectMake(self.brushImageView.bm_left - cupImageW - 4.0f, self.brushImageView.bm_top, cupImageW, cupImageW);
        }
    }
    else
    {
        if ([self getIsVertical])
        {
            self.lowWifiImageView.frame = CGRectMake(self.brushImageView.bm_left, self.brushImageView.bm_bottom + 5.0f, cupImageW, cupImageW);
            self.raiseHandImageView.frame = CGRectMake(self.brushImageView.bm_left, self.lowWifiImageView.bm_bottom + 5.0f, cupImageW, cupImageW);
        }
        else
        {
            self.lowWifiImageView.frame = CGRectMake(self.brushImageView.bm_left - cupImageW - 4.0f, self.brushImageView.bm_top, cupImageW, cupImageW);
            self.raiseHandImageView.frame = CGRectMake(self.lowWifiImageView.bm_left - cupImageW - 4, self.brushImageView.bm_top, cupImageW, cupImageW);
        }
    }
}
#if CH_OldGroup
- (void)setGroupRoomState:(CHGroupRoomState)groupRoomState
{
    _groupRoomState = groupRoomState;
    
    [self freshWithRoomUser];
}
#endif
/// 当前设备音量  音量大小 0 ～ 255
- (void)setIVolume:(NSUInteger)iVolume
{
    _iVolume = iVolume;
    
    if (self.audioState != CHDeviceFaultNone)
    {
        return;
    }
    if (self.roomUser.afail == CHDeviceFaultNone && self.roomUser.audioMute == CHSessionMuteState_Mute)
    {
        self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_selientSound");
        return;
    }

    CGFloat volumeScale = 255/3;
    
    if (iVolume < 5)
    {
        self.volumeStep = 0;
    }
    else if (iVolume<= volumeScale)
    {
        self.volumeStep = 1;
    }
    else if (iVolume<= volumeScale*2)
    {
        self.volumeStep = 2;
    }
    else if (iVolume > volumeScale*2)
    {
        self.volumeStep = 3;
    }
}

- (void)setVolumeStep:(NSUInteger)volumeStep
{
    if (volumeStep == _volumeStep)
    {
        return;
    }
    
    _volumeStep = volumeStep;
    
    switch (volumeStep)
    {
        case 1:
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_1Sound");
            break;
            
        case 2:
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_2Sound");
            break;
            
        case 3:
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_3Sound");
            break;
            
        case 0:
        default:
            self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_noSound");
            break;
    }
}

/// 奖杯数
- (void)setGiftNumber:(NSUInteger)giftNumber
{
    _giftNumber = giftNumber;
    
    if (self.roomUser.role != CHUserType_Teacher && self.roomUser.role != CHUserType_Assistant)
    {
        self.cupNumLabel.text = [NSString stringWithFormat:@"× %@", @(giftNumber)];
    }
    else
    {
        self.cupImageView.hidden = YES;
        self.cupNumLabel.hidden = YES;
        self.cupNumLabel.text = nil;
    }
}

/// 画笔颜色值
- (void)setBrushColor:(NSString *)brushColor
{
    _brushColor = brushColor;
    
    UIColor *color = [UIColor bm_colorWithHexString:brushColor];
    self.brushImageView.tintColor = color;
}

/// 画笔权限
- (void)setCanDraw:(BOOL)canDraw
{
    _canDraw = canDraw;
    self.brushImageView.hidden = !canDraw;
}

// 是否举手
- (void)setIsRaiseHand:(BOOL)isRaiseHand
{
    _isRaiseHand = isRaiseHand;
    
    self.raiseHandImageView.hidden = !isRaiseHand;
    
    [self freshOtherIcon];
}

/// 小黑板是否正在私聊
- (void)setIsPrivateChating:(BOOL)isPrivateChating
{
    _isPrivateChating = isPrivateChating;
    [self freshWithRoomUser];
}

/// 视频状态
- (void)setVideoState:(CHVideoViewVideoState)videoState
{
    _videoState = videoState;
    
    self.maskNoVideoBgView.hidden = YES;
    self.maskCloseVideoBgView.hidden = YES;
    self.homeMaskLabel.hidden = YES;
    
    self.loadingImageView.hidden = (videoState != CHVideoViewVideoState_Normal);

    BOOL isClassBegin = [YSLiveManager sharedInstance].isClassBegin;
    if (isClassBegin)
    {
        self.loadingImageView.image = YSSkinElementImage(@"videoView_loadingImage", @"icon_normal");;
    }
    else
    {
        self.loadingImageView.image = YSSkinElementImage(@"videoView_stateVideo", @"disableCam");

        return;
    }
    
    // 低端设备
    if (videoState & CHVideoViewVideoState_Low_end)
    {
        if (self.roomUser.role != CHUserType_Teacher && self.roomUser.role != CHUserType_ClassMaster && ![self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
            self.maskNoVideoBgView.hidden = NO;
            self.maskNoVideoLabel.text = YSLocalized(@"Prompt.LowDeviceTitle");
            
            return;
        }
        else
        {
            self.maskNoVideoLabel.text = nil;
        }
    }
    
    if (videoState & CHVideoViewVideoState_DeviceError)
    {
        self.maskCloseVideoBgView.hidden = NO;

        switch (self.videoDeviceState)
        {
            // 无设备
            case CHDeviceFaultNotFind:
            {
                self.maskCloseVideoImageView.image = YSSkinElementImage(@"videoView_stateVideo", @"noCam");
            }
                break;
                
            // 设备被禁用
            case CHDeviceFaultNotAuth:
            {
                self.maskCloseVideoImageView.image = YSSkinElementImage(@"videoView_stateVideo", @"disableCam");
            }
                break;
                
            // 设备被占用
            case CHDeviceFaultOccupied:
            {
                self.maskCloseVideoImageView.image = YSSkinElementImage(@"videoView_stateVideo", @"occupyCam");
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
                self.maskCloseVideoImageView.image = YSSkinElementImage(@"videoView_stateVideo", @"unknownCam");
            }
                break;
        }
        return;
    }

#if 0
    // 视频订阅失败
    if (videoState & CHVideoViewVideoState_SubscriptionFailed)
    {
        self.maskNoVideoBgView.hidden = NO;
        self.maskNoVideoLabel.text = YSLocalized(@"Prompt.VideoLoading");

        return;
    }
    
    // 视频播放失败
    if (videoState & CHVideoViewVideoState_PlayFailed)
    {
        self.maskNoVideoBgView.hidden = NO;
        self.maskNoVideoLabel.text = YSLocalized(@"Prompt.VideoBuffering");

        return;
    }
#endif
    
    // 用户关闭视频
    if (videoState & CHVideoViewVideoState_Close)
    {
        self.maskCloseVideoBgView.hidden = NO;
        self.maskCloseVideoImageView.image = YSSkinElementImage(@"videoView_stateVideo", @"closeCam");
        
        return;
    }
    
    // 弱网环境
    if (videoState & CHVideoViewVideoState_PoorInternet)
    {
        self.lowWifiImageView.hidden = NO;

        [self freshOtherIcon];
    }
    else
    {
        self.lowWifiImageView.hidden = YES;
    }
    
    // 用户进入后台
    if (videoState & CHVideoViewVideoState_InBackground)
    {
        if (self.roomUser.role == CHUserType_Student)
        {
            self.homeMaskLabel.hidden = NO;
            self.homeMaskLabel.text = YSLocalized(@"State.teacherInBackGround");
            
            return;
        }
    }
}

/// 摄像头设备状态
- (void)setVideoDeviceState:(CHDeviceFaultType)videoDeviceState
{
    _videoDeviceState = videoDeviceState;
    
    [self setVideoState:self.videoState];
}

/// 音频状态
- (void)setAudioState:(CHVideoViewAudioState)audioState
{
    _audioState = audioState;

    self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_noSound");
    
    // 设备不可用
    if (audioState & CHVideoViewAudioState_DeviceError)
    {
        switch (self.audioDeviceState)
        {
            // 无设备
            case CHDeviceFaultNotFind:
            {
                self.soundImageView.image = YSSkinElementImage(@"videoView_stateSound", @"noMic");
            }
                break;
                
            // 设备被禁用
            case CHDeviceFaultNotAuth:
            {
                self.soundImageView.image = YSSkinElementImage(@"videoView_stateSound", @"disableMic");
            }
                break;
                
            // 设备被占用
            case CHDeviceFaultOccupied:
            {
                self.soundImageView.image = YSSkinElementImage(@"videoView_stateSound", @"occupyMic");
            }
                break;
               
            // 设备打开失败
            default:
            {
                self.soundImageView.image = YSSkinElementImage(@"videoView_stateSound", @"unknownMic");
            }
                break;
        }

        return;
    }
    
#if 0
    // 音频订阅失败
    if (audioState & CHVideoViewAudioState_SubscriptionFailed)
    {
        self.soundImageView.hidden = YES;
        return;
    }
    
    // 音频播放失败
    if (audioState & CHVideoViewAudioState_PlayFailed)
    {
        self.soundImageView.hidden = YES;
        return;
    }
#endif
    
    // 用户关闭麦克风
    if (audioState & CHVideoViewAudioState_Close)
    {
        self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_selientSound");
        return;
    }
}

/// 麦克风设备状态
- (void)setAudioDeviceState:(CHDeviceFaultType)audioDeviceState
{
    _audioDeviceState = audioDeviceState;
    
    [self setAudioState:self.audioState];
}

- (void)freshWithRoomUserProperty:(CHRoomUser *)roomUser
{
    if (!roomUser)
    {
        return;
    }
    self.roomUser = roomUser;
    
    [self freshWithRoomUser];
}

- (void)freshWithRoomUser
{
    if (![self.roomUser.peerID isEqualToString:@"0"])
    {
        self.nickNameLabel.text = self.roomUser.nickName;
    }
    
    // 音量
    self.iVolume = self.roomUser.iVolume;
    
    CHDeviceFaultType vfail = [self.roomUser getVideoVfailWithSourceId:self.sourceId];
    if (self.isForPerch)
    {
        self.loadingImageView.hidden = (vfail != CHDeviceFaultNone);
        self.coverView.hidden = YES;
        
        BOOL deviceError = NO;
        if (vfail)
        {
            self.videoDeviceState = vfail;
            if (vfail != CHDeviceFaultNone)
            {
                deviceError = YES;
            }
        }

        if (deviceError)
        {
            self.videoState |= CHVideoViewVideoState_DeviceError;
        }
        else
        {
            self.videoState &= ~CHVideoViewVideoState_DeviceError;
        }
        
        return;
    }

    if (self.isPrivateChating)
    {
        self.loadingImageView.hidden = YES;

        self.maskCloseVideoBgView.hidden = NO;
        self.maskCloseVideoImageView.image = YSSkinElementImage(@"videoView_PrivateChat", @"iconNor");
        
        return;
    }
    else
    {
        self.maskCloseVideoBgView.hidden = YES;
    }
#if CH_OldGroup
    if (self.groupRoomState == CHGroupRoomState_Normal)
    {
        self.maskGroupRoomBgView.hidden = YES;
    }
    else
    {
        self.maskGroupRoomBgView.hidden = NO;
        
        if (self.groupRoomState == CHGroupRoomState_Discussing)
        {
            /// 讨论中
            [self.maskGroupRoomImageView setImage:YSSkinElementImage(@"videoView_groupRoom", @"discussing")];
        }
        else if (self.groupRoomState == CHGroupRoomState_PrivateChat)
        {
            [self.maskGroupRoomImageView setImage:YSSkinElementImage(@"videoView_groupRoom", @"privateChat")];
        }
        
        return;
    }
#endif
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
        if (!isInBackGround && (isInBackGround != self.roomUser.isInBackGround))
        {
            [[YSLiveManager sharedInstance] setPropertyOfUid:self.roomUser.peerID tell:CHRoomPubMsgTellAll propertyKey:sCHUserIsInBackGround value:@(NO)];
            
            [[YSLiveManager sharedInstance] serverLog:[NSString stringWithFormat:@"User:%@:%@:%@ isInBackGround %@",self.roomUser.nickName, self.roomUser.peerID, @(self.roomUser.isInBackGround), @(isInBackGround)]];
        }
    }
    
    // 画笔权限
    self.canDraw = self.roomUser.canDraw;
    // 奖杯数
    self.giftNumber = self.roomUser.giftNumber;
    
    // 画笔颜色
    NSString *brushColor = self.roomUser.primaryColor;
    if ([brushColor bm_isNotEmpty])
    {
        self.brushColor = brushColor;
    }
    
    // 视频相关
    
    // 低端设备
    BOOL low = [YSLiveManager sharedInstance].devicePerformance_Low;
    if (low)
    {
        self.videoState |= CHVideoViewVideoState_Low_end;
    }
    else
    {
        self.videoState &= ~CHVideoViewVideoState_Low_end;
    }
    
    // 设备不可用
    self.videoDeviceState = vfail;
    if (vfail != CHDeviceFaultNone)
    {
        self.videoState |= CHVideoViewVideoState_DeviceError;
    }
    else
    {
        self.videoState &= ~CHVideoViewVideoState_DeviceError;
    }
    
    
//        if (!self.roomUser.disableVideo)
//        {
//            // 设备禁用
//            deviceError = YES;
//            self.videoDeviceState = CHVideoViewVideoDeviceState_Disable;
//        }
//        if ([self.roomUser.properties bm_containsObjectForKey:sYSUserVideoFail])
//        {
//            if ([self.roomUser.properties bm_boolForKey:sYSUserHasVideo])
//            {
//                self.videoDeviceState = vfail;
//                if (vfail != YSDeviceFaultNone)
//                {
//                    deviceError = YES;
//                }
//            }
//            else
//            {
//                deviceError = YES;
//                // 设备禁用
//                self.videoDeviceState = YSDeviceFaultNotFind;
//            }
//        }
//        else
//        {
//            if (!deviceError && ![self.roomUser.properties bm_boolForKey:sYSUserHasVideo])
//            {
//                // 无设备
//                deviceError = YES;
//                // 设备禁用
//                self.videoDeviceState = YSDeviceFaultNotFind;
//            }
//        }

//        if (deviceError)
//        {
//            self.videoState |= CHVideoViewVideoState_DeviceError;
//        }
//        else
//        {
//            self.videoState &= ~CHVideoViewVideoState_DeviceError;
//        }
    
    
    if ([self.roomUser getVideoMuteWithSourceId:self.sourceId] == CHSessionMuteState_Mute)
    {
        // 关闭视频
        self.videoState |= CHVideoViewVideoState_Close;
    }
    else
    {
        self.videoState &= ~CHVideoViewVideoState_Close;
    }
    
    // 网络状态
    BOOL isPoorNetWork = [self.roomUser.properties bm_boolForKey:sCHUserNetWorkState];
    if (isPoorNetWork)
    {
        self.videoState |= CHVideoViewVideoState_PoorInternet;
    }
    else
    {
        self.videoState &= ~CHVideoViewVideoState_PoorInternet;
    }
    
    // 进入后台(home键)
    BOOL isInBackGround = self.roomUser.isInBackGround;
    if (isInBackGround)
    {
        self.videoState |= CHVideoViewVideoState_InBackground;
    }
    else
    {
        self.videoState &= ~CHVideoViewVideoState_InBackground;
    }
    
    // 音频相关
    self.audioDeviceState = self.roomUser.afail;
    if (self.roomUser.afail != CHDeviceFaultNone)
    {
        self.audioState |= CHVideoViewAudioState_DeviceError;
    }
    else
    {
        self.audioState &= ~CHVideoViewAudioState_DeviceError;
    }
    
    
        // 设备不可用
//        deviceError = NO;

//        if ([self.roomUser.properties bm_containsObjectForKey:sYSUserAudioFail])
//        {
//            if ([self.roomUser.properties bm_boolForKey:sYSUserHasAudio])
//            {
//                self.audioDeviceState = self.roomUser.afail;
//                if (self.roomUser.afail != YSDeviceFaultNone)
//                {
//                    deviceError = YES;
//                }
//            }
//            else
//            {
//                deviceError = YES;
//                self.audioDeviceState = YSDeviceFaultNotFind;
//            }
//        }
//        else
//        {
//
//            if (!deviceError && ![self.roomUser.properties bm_boolForKey:sYSUserHasAudio])
//            {
//                // 无设备
//                deviceError = YES;
//                // 设备禁用
//                self.audioDeviceState = YSDeviceFaultNotFind;
//            }
//        }

//        if (deviceError)
//        {
//            self.audioState |= CHVideoViewAudioState_DeviceError;
//        }
//        else
//        {
//            self.audioState &= ~CHVideoViewAudioState_DeviceError;
//        }
    
    
    if (self.roomUser.audioMute == CHSessionMuteState_Mute)
    {
        // 关闭音频
        self.audioState |= CHVideoViewAudioState_Close;
    }
    else
    {
        self.audioState &= ~CHVideoViewAudioState_Close;
    }
}

@end
