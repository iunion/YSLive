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

@property (nonatomic, strong) CHRoomUser *roomUser;

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
///弱网图标
@property (nonatomic, strong) UIImageView *lowWifiImage;
///举手图标
@property (nonatomic, strong) UIImageView *raiseHandImage;
/// 分组蒙版
@property (nonatomic, strong) UIView * maskGroupRoomView;
@property (nonatomic, strong) UIImageView *maskGroupRoomImage;

/// 视频状态
@property (nonatomic, assign) SCVideoViewVideoState videoState;
/// 摄像头设备状态
@property (nonatomic, assign) CHDeviceFaultType videoDeviceState;
/// 音频状态
@property (nonatomic, assign) SCVideoViewAudioState audioState;
/// 麦克风设备状态
@property (nonatomic, assign) CHDeviceFaultType audioDeviceState;

@end

@implementation SCVideoView

// 老师用
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId withDelegate:(id<SCVideoViewDelegate>)delegate
{
    return [self initWithRoomUser:roomUser withSourceId:sourceId isForPerch:NO withDelegate:delegate];
}

- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId isForPerch:(BOOL)isForPerch withDelegate:(id<SCVideoViewDelegate>)delegate
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
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId
{
    return [self initWithRoomUser:roomUser withSourceId:sourceId isForPerch:NO];
}

- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(NSString *)sourceId isForPerch:(BOOL)isForPerch
{
    self = [super init];
    if (self)
    {        
        if ([sourceId isEqualToString:sCHUserDefaultSourceId] && [roomUser.peerID isEqualToString:YSCurrentUser.peerID])
        {
            self.streamId = [NSString stringWithFormat:@"%@:video:%@",roomUser.peerID,sourceId];
        }
        
        self.roomUser = roomUser;
        self.sourceId = sourceId;
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
    self.backgroundColor = YSSkinDefineColor(@"Color9");
    
    UIView *sourceView = [[UIView alloc] init];
    sourceView.backgroundColor = UIColor.clearColor;
    sourceView.hidden = YES;
    [self addSubview:sourceView];
    self.sourceView = sourceView;
    
    ///正在加载中
    self.loadingImg = YSSkinElementImage(@"videoView_loadingImage", @"icon_normal");
    UIImageView * loadingImgView = [[UIImageView alloc]initWithImage:self.loadingImg];
    [loadingImgView setBackgroundColor:YSSkinDefineColor(@"Color9")];
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
    self.maskCloseVideoBgView.backgroundColor = YSSkinDefineColor(@"Color9");
    [maskBackView addSubview:self.maskCloseVideoBgView];
    self.maskCloseVideoBgView.hidden = YES;

    self.maskCloseImage = YSSkinElementImage(@"videoView_stateVideo", @"closeCam");
    
    self.maskCloseVideo = [[UIImageView alloc] initWithImage:self.maskCloseImage];
    self.maskCloseVideo.contentMode = UIViewContentModeScaleAspectFit;
    [self.maskCloseVideoBgView addSubview:self.maskCloseVideo];

    ///点击Home键提示蒙版
    self.homeMaskLab = [[UILabel alloc]init];
    self.homeMaskLab.text = YSLocalized(@"State.teacherInBackGround");

    if ([UIDevice bm_isiPad])
    {
        self.homeMaskLab.font = UI_FONT_12;
    }
    else
    {
        self.homeMaskLab.font = UI_FONT_10;
    }
    self.homeMaskLab.font = UI_FONT_12;
    self.homeMaskLab.textColor = YSSkinDefineColor(@"Color3");
    [maskBackView addSubview:self.homeMaskLab];
    [self.homeMaskLab setAdjustsFontSizeToFitWidth:YES];
    self.homeMaskLab.numberOfLines = 2;
    self.homeMaskLab.textAlignment = NSTextAlignmentCenter;
    self.homeMaskLab.backgroundColor = UIColor.clearColor;
    self.homeMaskLab.hidden = YES;
    
    //没有摄像头时的蒙版
    self.maskNoVideo = [[UIView alloc] init];
    self.maskNoVideo.backgroundColor = YSSkinDefineColor(@"Color9");;
    [maskBackView addSubview:self.maskNoVideo];
    self.maskNoVideo.hidden = YES;
    
    //没有连摄像头时的文字
    UILabel * maskNoVideoTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 85, 20)];
    maskNoVideoTitle.backgroundColor = [UIColor clearColor];
    if ([UIDevice bm_isiPad])
    {
        maskNoVideoTitle.font = UI_FONT_14;
    }
    else
    {
        maskNoVideoTitle.font = UI_FONT_12;
    }
    
    maskNoVideoTitle.textColor = YSSkinDefineColor(@"Color3");
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
    if ([UIDevice bm_isiPad])
    {
        self.cupNumLab.font = UI_FONT_14;
    }
    else
    {
        self.cupNumLab.font = UI_FONT_12;
    }
    self.cupNumLab.text = @"× 0";
    self.cupNumLab.textColor = YSSkinDefineColor(@"Color3");
    self.cupNumLab.adjustsFontSizeToFitWidth = YES;
    self.cupNumLab.minimumScaleFactor = 0.1;
    self.cupNumLab.hidden = NO;
    [self.backVideoView addSubview:self.cupNumLab];
    
    //画笔权限
    self.brushImageView = [[UIImageView alloc] init];
    UIImage *image = YSSkinElementImage(@"videoView_authorizeLab", @"iconNor");
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.brushImageView.image = image;
    self.brushImageView.hidden = NO;
    [self.backVideoView addSubview:self.brushImageView];
    
    //弱网图标
    self.lowWifiImage = [[UIImageView alloc] init];
    self.lowWifiImage.image = YSSkinElementImage(@"videoView_stateVideo", @"lowWifi");
    self.lowWifiImage.contentMode = UIViewContentModeScaleAspectFit;
    self.lowWifiImage.hidden = YES;
    [self.backVideoView addSubview:self.lowWifiImage];
    self.lowWifiImage.backgroundColor = UIColor.clearColor;
    
    //举手图标
    self.raiseHandImage = [[UIImageView alloc] init];
    self.raiseHandImage.image = YSSkinElementImage(@"videoView_handImageView", @"iconNor");
    self.raiseHandImage.hidden = YES;
    [self.backVideoView addSubview:self.raiseHandImage];
    self.raiseHandImage.backgroundColor = UIColor.clearColor;
    
    //用户名
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    if ([UIDevice bm_isiPad])
    {
        self.nickNameLab.font = UI_FONT_14;
    }
    else
    {
        self.nickNameLab.font = UI_FONT_12;
    }
    self.nickNameLab.textColor = YSSkinDefineColor(@"Color3");
    self.nickNameLab.adjustsFontSizeToFitWidth = YES;
    self.nickNameLab.minimumScaleFactor = 0.3;
    self.nickNameLab.hidden = NO;
    [self.backVideoView addSubview:self.nickNameLab];
    
    //声音图片
    self.soundImageView = [[UIImageView alloc] init];
    self.soundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backVideoView addSubview:self.soundImageView];
    
    if (self.isDragOut || self.isFullScreen)
    {
        self.nickNameLab.font = self.cupNumLab.font = self.dragFont;
    }
    else
    {
        self.nickNameLab.font = self.cupNumLab.font = self.notDragFont;
    }
    
    
    //分组
    UIView * maskGroupRoomView = [[UIView alloc]init];
    maskGroupRoomView.backgroundColor = YSSkinDefineColor(@"Color9");;
    [self.backVideoView addSubview:maskGroupRoomView];
    maskGroupRoomView.hidden = YES;
    self.maskGroupRoomView = maskGroupRoomView;
    
    self.maskGroupRoomImage = [[UIImageView alloc] init];
    self.maskGroupRoomImage.contentMode = UIViewContentModeScaleAspectFit;
    [maskGroupRoomView addSubview:self.maskGroupRoomImage];
    
    [self freshWithRoomUserProperty:self.roomUser];
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
            CGFloat oldScale = oldWidth/BMUI_SCREEN_WIDTH_ROTATE;
            CGFloat newScale = newWidth/BMUI_SCREEN_WIDTH_ROTATE;

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
            CHRoomModel * roomModel = [YSLiveManager sharedInstance].roomModel;
            
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
                
                //容错处理
                if (videowidth == 0 || videoheight == 0)
                {
                    videowidth = roomModel.videowidth;
                    videoheight = roomModel.videoheight;
                }
                
                CloudHubVideoEncoderConfiguration *config = [[CloudHubVideoEncoderConfiguration alloc] initWithWidth:videowidth height:videoheight frameRate:roomModel.videoframerate];
                
                [[CHSessionManager sharedInstance].cloudHubRtcEngineKit setVideoEncoderConfiguration:config];
            }
        }
    }
    
    CGFloat width = self.bm_height*0.7f;
    if (width>100)
    {
        width = 100;
    }
    self.loadingImgView.bm_size = CGSizeMake(width, width);
    [self.loadingImgView bm_centerInSuperView];
    
    self.backVideoView.frame = self.bounds;
    self.maskBackView.frame = self.bounds;
    self.maskCloseVideoBgView.frame = self.bounds;
    
    self.homeMaskLab.frame = CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height-20);
    self.maskNoVideo.frame = self.bounds;
    self.maskNoVideoTitle.frame = CGRectMake(2, 10, self.bm_width-4, self.bm_height-25);

    self.sourceView.frame = CGRectMake((self.bounds.size.width - 50)/2	, (self.bounds.size.height - 50)/2, 50, 50);

    self.maskCloseVideo.bm_size = CGSizeMake(width, width);
    [self.maskCloseVideo bm_centerInSuperView];

    self.maskGroupRoomView.frame = self.bounds;
    self.maskGroupRoomImage.bm_size = CGSizeMake(width, width);
    [self.maskGroupRoomImage bm_centerInSuperView];
    
    if (self.appUseTheType == CHRoomUseTypeLiveRoom || self.appUseTheType == CHRoomUseTypeMeeting || self.roomUser.role == CHUserType_Teacher || self.roomUser.role == CHUserType_Assistant)
    {
        self.cupImage.hidden = YES;
        self.cupNumLab.hidden = YES;
    }
    else
    {
        self.cupImage.hidden = NO;
        self.cupNumLab.hidden = NO;
    }
   
    int maxW = 25;
    int minW = 7;
    if ([UIDevice bm_isiPad])
    {
        maxW = 35;
        minW = 10;
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
        
    self.cupImage.bm_width = self.cupImage.bm_height = cupImageW;
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
    
    if (self.lowWifiImage.hidden == YES && self.raiseHandImage.hidden == NO)
    {
        if ([self getIsVertical])
        {
            self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX, self.brushImageView.bm_bottom + 5, self.cupImage.bm_width, self.cupImage.bm_width);
        }
        else
        {
            self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX-self.cupImage.bm_width - 4, self.brushImageView.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
        }
    }
    else
    {
        if ([self getIsVertical])
        {
            self.lowWifiImage.frame = CGRectMake(self.brushImageView.bm_originX, self.brushImageView.bm_bottom + 5, self.cupImage.bm_width, self.cupImage.bm_width);
            self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX, self.lowWifiImage.bm_bottom + 5, self.cupImage.bm_width, self.cupImage.bm_width);
        }
        else
        {
            self.lowWifiImage.frame = CGRectMake(self.brushImageView.bm_originX-self.cupImage.bm_width - 4, self.brushImageView.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
            self.raiseHandImage.frame = CGRectMake(self.lowWifiImage.bm_originX-self.cupImage.bm_width - 4, self.lowWifiImage.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
        }
    }
    
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
    
    self.nickNameLab.frame = CGRectMake(4, self.bm_height-4-height, self.bm_width*0.5f, height);
        
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
    self.nickNameLab.font = [UIFont systemFontOfSize:fontSize];
    
    if ([UIDevice bm_isiPad])
    {
        maxW = 55;
        minW = 20;
    }
    else
    {
        maxW = 40;
        minW = 15;
    }
    CGFloat soundImageWidth = height*5/3;
        
    if (soundImageWidth > maxW)
    {
        soundImageWidth = maxW;
    }
    else if (soundImageWidth < minW)
    {
        soundImageWidth = minW;
    }
    
    self.soundImageView.frame = CGRectMake(self.bm_width-5-soundImageWidth, self.bm_height-4-height, soundImageWidth, height);
}

- (void)setGroopRoomState:(SCGroopRoomState)groopRoomState
{
    _groopRoomState = groopRoomState;
    
    [self freshWithRoomUserProperty:self.roomUser];
 }

- (BOOL)getIsVertical
{
    BOOL isVertical = NO;
    
    CGFloat width = self.bm_width;
    CGFloat height = self.bm_height;
    
    CGFloat scaleVide = (width + 1)/height;
    
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

/// 当前设备音量  音量大小 0 ～ 32670
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
    
    if (self.roomUser.role != CHUserType_Teacher && self.roomUser.role != CHUserType_Assistant)
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
    
    if (self.raiseHandImage.hidden == NO)
    {
        if (self.lowWifiImage.hidden == NO)
        {
            if ([self getIsVertical])
            {
                self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX, self.lowWifiImage.bm_bottom + 5, self.cupImage.bm_width, self.cupImage.bm_width);
            }
            else
            {
                self.raiseHandImage.frame = CGRectMake(self.lowWifiImage.bm_originX-self.cupImage.bm_width - 4, self.lowWifiImage.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
            }
        }
        else
        {
            if ([self getIsVertical])
            {
                self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX, self.brushImageView.bm_bottom + 5, self.cupImage.bm_width, self.cupImage.bm_width);
            }
            else
            {
                self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX-self.cupImage.bm_width - 4, self.brushImageView.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
            }
        }
    }
}

/// 视频状态
- (void)setVideoState:(SCVideoViewVideoState)videoState
{
    _videoState = videoState;
    
    self.maskNoVideo.hidden = YES;
    self.maskCloseVideoBgView.hidden = YES;
    self.homeMaskLab.hidden = YES;
    
    BOOL isClassBegin = [YSLiveManager sharedInstance].isClassBegin;
    
    
    if (isClassBegin)
    {
        self.loadingImgView.image = self.loadingImg;
    }
    else
    {
        self.loadingImgView.hidden = NO;
        self.loadingImgView.image = YSSkinElementImage(@"videoView_stateVideo", @"disableCam");
        return;
    }
    
    // 低端设备
    if (videoState & SCVideoViewVideoState_Low_end)
    {
        if (self.roomUser.role != CHUserType_Teacher && self.roomUser.role != CHUserType_ClassMaster && ![self.roomUser.peerID isEqualToString:YSCurrentUser.peerID])
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
        self.maskCloseVideoBgView.hidden = NO;
        [self.maskCloseVideoBgView bm_bringToFront];
        switch (self.videoDeviceState)
        {
            // 无设备
            case CHDeviceFaultNotFind:
            {
                self.maskCloseVideo.image = YSSkinElementImage(@"videoView_stateVideo", @"noCam");
            }
                break;
                
            // 设备被禁用
            case CHDeviceFaultNotAuth:
            {
                self.maskCloseVideo.image = YSSkinElementImage(@"videoView_stateVideo", @"disableCam");
            }
                break;
                
            // 设备被占用
            case CHDeviceFaultOccupied:
            {
                self.maskCloseVideo.image = YSSkinElementImage(@"videoView_stateVideo", @"occupyCam");
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
                self.maskCloseVideo.image = YSSkinElementImage(@"videoView_stateVideo", @"unknownCam");
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
    if (videoState & SCVideoViewVideoState_PoorInternet)
    {
        self.lowWifiImage.hidden = NO;

        if (self.raiseHandImage.hidden == NO)
        {
            if ([self getIsVertical])
            {
                self.raiseHandImage.frame = CGRectMake(self.brushImageView.bm_originX, self.lowWifiImage.bm_bottom + 5, self.cupImage.bm_width, self.cupImage.bm_width);
            }
            else
            {
                self.raiseHandImage.frame = CGRectMake(self.lowWifiImage.bm_originX-self.cupImage.bm_width - 4, self.lowWifiImage.bm_originY, self.cupImage.bm_width, self.cupImage.bm_width);
            }
        }
        
        return;
    }
    else
    {
        self.lowWifiImage.hidden = YES;
    }
    
    // 用户进入后台
    if (videoState & SCVideoViewVideoState_InBackground)
    {
        if (self.roomUser.role == CHUserType_Student)
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
- (void)setVideoDeviceState:(CHDeviceFaultType)videoDeviceState
{
    _videoDeviceState = videoDeviceState;
    
    [self setVideoState:self.videoState];
}

/// 音频状态
- (void)setAudioState:(SCVideoViewAudioState)audioState
{
    _audioState = audioState;

    self.soundImageView.image = YSSkinElementImage(@"videoView_soundImageView", @"icon_noSound");
    
    // 设备不可用
    if (audioState & SCVideoViewAudioState_DeviceError)
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
    if (audioState & SCVideoViewAudioState_SubscriptionFailed)
    {
        self.soundImageView.hidden = YES;
        return;
    }
    
    // 音频播放失败
    if (audioState & SCVideoViewAudioState_PlayFailed)
    {
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
- (void)setAudioDeviceState:(CHDeviceFaultType)audioDeviceState
{
    _audioDeviceState = audioDeviceState;
    
    [self setAudioState:self.audioState];
}

- (void)setIsPrivateChating:(BOOL)isPrivateChating
{
    _isPrivateChating = isPrivateChating;
    [self freshWithRoomUserProperty:self.roomUser];
}

- (void)freshWithRoomUserProperty:(CHRoomUser *)roomUser
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
    
    CHDeviceFaultType vfail = [self.roomUser getVideoVfailWithSourceId:self.sourceId];
    if (self.isForPerch)
    {
        self.loadingImgView.hidden = (vfail != CHDeviceFaultNone);
        self.backVideoView.hidden = YES;
        
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
            self.videoState |= SCVideoViewVideoState_DeviceError;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_DeviceError;
        }
    }
    else
    {
        if (self.isPrivateChating)
        {
            self.loadingImgView.hidden = YES;
            self.maskCloseVideoBgView.hidden = NO;
            [self.maskCloseVideoBgView bm_bringToFront];
            
            self.maskCloseVideo.image = YSSkinElementImage(@"videoView_PrivateChat", @"iconNor");
            [self.backVideoView bm_bringToFront];
            return;
        }
        else
        {
            self.maskCloseVideoBgView.hidden = YES;
        }
        

        
        if (self.groopRoomState == SCGroopRoomState_Normal)
        {
            self.maskGroupRoomView.hidden = YES;
        }
        else
        {
            self.maskGroupRoomView.hidden = NO;
            [self.backVideoView bm_bringToFront];
            
            if (self.groopRoomState == SCGroopRoomState_Discussing)
            {   
                /// 讨论中
                [self.maskGroupRoomImage setImage:YSSkinElementImage(@"videoView_groupRoom", @"discussing")];
            }
            else if (self.groopRoomState == SCGroopRoomState_PrivateChat)
            {
                [self.maskGroupRoomImage setImage:YSSkinElementImage(@"videoView_groupRoom", @"privateChat")];
            }
            return;
        }

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
            }
            
            [[YSLiveManager sharedInstance] serverLog:[NSString stringWithFormat:@"User:%@:%@:%@ isInBackGround %@",self.roomUser.nickName, self.roomUser.peerID, @(self.roomUser.isInBackGround), @(isInBackGround)]];
        }
        
        self.canDraw = [self.roomUser.properties bm_boolForKey:sCHUserCandraw];
        self.giftNumber = [self.roomUser.properties bm_uintForKey:sCHUserGiftNumber];
        
        NSString *brushColor = [self.roomUser.properties bm_stringTrimForKey:sCHUserPrimaryColor];
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
        self.videoDeviceState = vfail;
        if (vfail != CHDeviceFaultNone)
        {
            self.videoState |= SCVideoViewVideoState_DeviceError;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_DeviceError;
        }
        

//        if (!self.roomUser.disableVideo)
//        {
//            // 设备禁用
//            deviceError = YES;
//            self.videoDeviceState = SCVideoViewVideoDeviceState_Disable;
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
//            self.videoState |= SCVideoViewVideoState_DeviceError;
//        }
//        else
//        {
//            self.videoState &= ~SCVideoViewVideoState_DeviceError;
//        }

        
        if ([self.roomUser getVideoMuteWithSourceId:self.sourceId] == CHSessionMuteState_Mute)
        {
            // 关闭视频
            self.videoState |= SCVideoViewVideoState_Close;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_Close;
        }
        
        // 网络状态
        BOOL isPoorNetWork = [self.roomUser.properties bm_boolForKey:sCHUserNetWorkState];
        if (isPoorNetWork)
        {
            self.videoState |= SCVideoViewVideoState_PoorInternet;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_PoorInternet;
        }
        
        // 进入后台(home键)
        BOOL isInBackGround = self.roomUser.isInBackGround;
        if (isInBackGround)
        {
            self.videoState |= SCVideoViewVideoState_InBackground;
        }
        else
        {
            self.videoState &= ~SCVideoViewVideoState_InBackground;
        }
        
        // 音频相关
        self.audioDeviceState = self.roomUser.afail;
        if (self.roomUser.afail != CHDeviceFaultNone)
        {
            self.audioState |= SCVideoViewAudioState_DeviceError;
        }
        else
        {
            self.audioState &= ~SCVideoViewAudioState_DeviceError;
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
//            self.audioState |= SCVideoViewAudioState_DeviceError;
//        }
//        else
//        {
//            self.audioState &= ~SCVideoViewAudioState_DeviceError;
//        }


        if (self.roomUser.audioMute == CHSessionMuteState_Mute)
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
