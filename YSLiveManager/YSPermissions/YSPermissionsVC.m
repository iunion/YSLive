//
//  YSPermissionsVC.m
//  YSLive
//
//  Created by 马迪 on 2019/12/17.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSPermissionsVC.h"
#import "YSPermissionsVResultView.h"
#import <AVFoundation/AVFoundation.h>

#ifdef YSLIVE
#import "YSMainVC.h"
#endif
#if YSCLASS
#import "SCMainVC.h"
#endif

#import <AVFoundation/AVFoundation.h> //音频视频框架

/// 检测类型
typedef NS_ENUM(NSInteger, YSPermissionsType)
{
    /** 开始 */
    YSPermissionsTypeStart,
    /** 扬声器 */
    YSPermissionsTypeReproducer,
    /** 摄像头 */
    YSPermissionsTypeCamera,
    /** 麦克风 */
    YSPermissionsTypeMicrophonic,
    /** 结果 */
    YSPermissionsTypeResult,
};

@interface YSPermissionsVC ()<AVAudioPlayerDelegate>

///音频播放器
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioSession *session;

/// 背景
@property (nonatomic, strong) UIImageView *backImageView;
/// 检测类型
@property (nonatomic, strong) UILabel *titleLab;
/// 白色展示区
@property (nonatomic, strong) UIView *whiteView;

/// 白色展示区核心提示lab
@property (nonatomic, strong) UILabel *centerLab;
/// 提示动画
@property (nonatomic, strong) UIImageView *animateView;
/// 摄像头  麦克风图标
@property (nonatomic, strong) UIImageView *topImageView;

/// 扬声器结果lab
@property (nonatomic, strong) YSPermissionsVResultView *reproducerLab;
/// 摄像头结果lab
@property (nonatomic, strong) YSPermissionsVResultView *cameraLab;
/// 麦克风结果lab
@property (nonatomic, strong) YSPermissionsVResultView *microphonicLab;

/// 开始/继续按钮
@property (nonatomic, strong) UIButton *continueBtn;
/// 播放按钮
@property (nonatomic, strong) UIButton *playAudioBtn;
/// 再次按钮
@property (nonatomic, strong) UIButton *againBtn;
/// 检测类型
@property (nonatomic, assign) YSPermissionsType permissionsType;
/// 文本文字
@property (nonatomic, strong) NSString *permissionsMessage;

@end

@implementation YSPermissionsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

//只是为了触发 获取摄像头权限
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (deviceInput)
    {
        deviceInput = nil;
    }
    
    [self.view addSubview:self.backImageView];

    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    /// 白色展示区
    UIView *whiteView = [[UIView alloc]init];
    whiteView.backgroundColor = UIColor.whiteColor;
    whiteView.layer.cornerRadius = 26;
    [self.view addSubview:whiteView];
    self.whiteView = whiteView;

    /// 提示动画
    UIImageView *animateView = [[UIImageView alloc]initWithFrame:CGRectMake(19, UI_SCREEN_HEIGHT-284-143, 91, 143)];
    [self.view addSubview:animateView];
    animateView.animationImages = @[[UIImage imageNamed:@"Permissions1"],[UIImage imageNamed:@"Permissions2"],[UIImage imageNamed:@"Permissions3"],[UIImage imageNamed:@"Permissions4"]];
    animateView.animationDuration = 1.0;
    animateView.animationRepeatCount = 0;
    [animateView startAnimating];
    self.animateView = animateView;
    
    /// 提示文字
    UILabel *centerLab = [[UILabel alloc]initWithFrame:CGRectZero];
    centerLab.numberOfLines = 0;
    centerLab.font = UI_FONT_14;
    centerLab.textColor = [UIColor bm_colorWithHex:0x6D7278];
    [self.view addSubview:centerLab];
    self.centerLab = centerLab;
    
    /// 检测项目
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 22)];
    
    titleLab.font = UI_FONT_16;
    titleLab.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
    self.titleLab = titleLab;
    self.titleLab.bm_centerX = self.view.bm_centerX;
   
    /// 图标
    UIImageView * topImageView = [[UIImageView alloc] init];
    topImageView.frame = CGRectMake(0, 0, 40, 40);
    [self.view addSubview:topImageView];
    topImageView.hidden = YES;
    self.topImageView = topImageView;

    /// 扬声器检测结果
    YSPermissionsVResultView *reproducerLab = [[YSPermissionsVResultView alloc]initWithFrame:CGRectMake(0, 0, 170, 20)];
    [self.view addSubview:reproducerLab];
    reproducerLab.permissionColor = [UIColor bm_colorWithHex:0x82ABEC];
    reproducerLab.noPermissionColor = [UIColor bm_colorWithHex:0xBE2B2B];
    reproducerLab.title = YSLocalized(@"Permissions.Speaker");
    reproducerLab.permissionText = YSLocalized(@"Permissions.Normal");
    reproducerLab.noPermissionText = YSLocalized(@"Permissions.CanNotHear");

    self.reproducerLab = reproducerLab;
    reproducerLab.hidden = YES;
    
    /// 摄像头检测结果
    YSPermissionsVResultView *cameraLab = [[YSPermissionsVResultView alloc]initWithFrame:CGRectMake(0, 0, 170, 20)];
    [self.view addSubview:cameraLab];
    cameraLab.permissionColor = [UIColor bm_colorWithHex:0x82ABEC];
    cameraLab.noPermissionColor = [UIColor bm_colorWithHex:0xBE2B2B];
    cameraLab.title = YSLocalized(@"Permissions.Camera");
    cameraLab.permissionText = YSLocalized(@"Permissions.Allow");
    cameraLab.noPermissionText = YSLocalized(@"Permissions.Ban");

    self.cameraLab = cameraLab;
    cameraLab.hidden = YES;
    
    /// 麦克风检测结果
    YSPermissionsVResultView *microphonicLab = [[YSPermissionsVResultView alloc]initWithFrame:CGRectMake(0, 0, 170, 20)];
    [self.view addSubview:microphonicLab];
    microphonicLab.permissionColor = [UIColor bm_colorWithHex:0x82ABEC];
    microphonicLab.noPermissionColor = [UIColor bm_colorWithHex:0xBE2B2B];
    microphonicLab.title = YSLocalized(@"Permissions.Microphone");
    microphonicLab.permissionText = YSLocalized(@"Permissions.Allow");
    microphonicLab.noPermissionText = YSLocalized(@"Permissions.Ban");
    
    self.microphonicLab = microphonicLab;
    microphonicLab.hidden = YES;
    
    /// 开始/继续按钮
    UIButton *continueBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 96, 34)];
    continueBtn.bm_centerX = self.view.bm_centerX;
    [continueBtn setBackgroundImage:[UIImage imageNamed:@"permissions_Btn"] forState:UIControlStateNormal];
    [continueBtn setBackgroundImage:[UIImage imageNamed:@"permissions_BtnSelect"] forState:UIControlStateHighlighted];
    [continueBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    [continueBtn setTitle:YSLocalized(@"tool.start") forState:UIControlStateNormal];
    continueBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [continueBtn addTarget:self action:@selector(continueBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueBtn];
    self.continueBtn = continueBtn;
    
    /// 播放音频
    UIButton *playAudioBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    playAudioBtn.bm_centerX = self.view.bm_centerX;
    [playAudioBtn setImage:[UIImage imageNamed:@"permissions_PlayBtn"] forState:UIControlStateNormal];
    [playAudioBtn setTitleColor:[UIColor bm_colorWithHex:0x5A8CDC] forState:UIControlStateNormal];
    [playAudioBtn setTitle:YSLocalized(@"Permissions.ListenAgain") forState:UIControlStateNormal];
    playAudioBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    playAudioBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    float  spacing = 5;//图片和文字的上下间距
    CGSize imageSize = playAudioBtn.imageView.frame.size;
    CGSize titleSize = playAudioBtn.titleLabel.frame.size;
    CGSize textSize = [playAudioBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : playAudioBtn.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    playAudioBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    playAudioBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
    [playAudioBtn addTarget:self action:@selector(playAudioBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playAudioBtn];
    self.playAudioBtn = playAudioBtn;
    self.playAudioBtn.hidden = YES;
    
    ///再次
    UIButton *againBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 96, 34)];
    againBtn.bm_centerX = self.view.bm_centerX;
    [againBtn setBackgroundImage:[UIImage imageNamed:@"permissions_Btn"] forState:UIControlStateNormal];
    [againBtn setBackgroundImage:[UIImage imageNamed:@"permissions_BtnSelect"] forState:UIControlStateHighlighted];
    [againBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    [againBtn setTitle:YSLocalized(@"Permissions.Again") forState:UIControlStateNormal];
    againBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [againBtn addTarget:self action:@selector(againBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:againBtn];
    self.againBtn = againBtn;
    self.againBtn.hidden = YES;

    self.permissionsType = YSPermissionsTypeStart;
}


#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    return NO;
}

/// 2.返回支持的旋转方向
/// iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - 设置类型 并在此赋值 一些属性
- (void)setPermissionsType:(YSPermissionsType)permissionsType
{
    _permissionsType = permissionsType;
    
    self.playAudioBtn.hidden = YES;
    self.againBtn.hidden = YES;
    self.topImageView.hidden = YES;
    self.reproducerLab.hidden = YES;
    self.cameraLab.hidden = YES;
    self.microphonicLab.hidden = YES;
    
    NSString * string = @"";

    ///查看摄像头权限
    BOOL isCamera = [self cameraPermissionsService];
    ///查看麦克风权限
    BOOL isOpenMicrophone = [self microphonePermissionsService];
    /// 扬声器权限
    BOOL isReproducer = [YSUserDefault getReproducerPermission];
    switch (self.permissionsType)
    {
        case YSPermissionsTypeStart:
            
            string = YSLocalized(@"Permissions.TotalTitle");
            [self.continueBtn setTitle:YSLocalized(@"tool.start") forState:UIControlStateNormal];
            self.titleLab.text = @"";
            break;
        case YSPermissionsTypeReproducer:
            
            string = YSLocalized(@"Permissions.checkTitle_Sound");
            [self.continueBtn setTitle:YSLocalized(@"Permissions.CanHear") forState:UIControlStateNormal];
            [self.againBtn setTitle:YSLocalized(@"Permissions.CanNotHear") forState:UIControlStateNormal];
            self.titleLab.text = YSLocalized(@"Permissions.SpeakerCheck");
            self.playAudioBtn.hidden = NO;
            self.againBtn.hidden = NO;
                break;
        case YSPermissionsTypeCamera:
            
            string = YSLocalized(@"Permissions.checkTitle_Camera");
            [self.topImageView setImage:[UIImage imageNamed:@"permissions_NoCamera"]];
            [self.continueBtn setTitle:YSLocalized(@"Permissions.Continue") forState:UIControlStateNormal];
            self.titleLab.text = YSLocalized(@"Permissions.CameraCheck");
            self.topImageView.hidden = NO;
                break;
        case YSPermissionsTypeMicrophonic:
            
            string = YSLocalized(@"Permissions.checkTitle_Microphone");
            [self.continueBtn setTitle:YSLocalized(@"Permissions.Continue") forState:UIControlStateNormal];
            [self.topImageView setImage:[UIImage imageNamed:@"permissions_NoSound"]];
            self.titleLab.text = YSLocalized(@"Permissions.MicrophoneCheck");
            self.topImageView.hidden = NO;
                break;
            
        case YSPermissionsTypeResult:
            
            if (!isOpenMicrophone || !isCamera || !isReproducer)
            {
                string = YSLocalized(@"Permissions.checkTitle_Fail");
            }
            else
            {
                string = YSLocalized(@"Permissions.checkTitle_Accomplish");
            }
            
            [self.continueBtn setTitle:YSLocalized(@"Permissions.Continue") forState:UIControlStateNormal];
            [self.againBtn setTitle:YSLocalized(@"Permissions.Again") forState:UIControlStateNormal];
            self.titleLab.text = YSLocalized(@"Permissions.Report");
            self.againBtn.hidden = NO;
            self.reproducerLab.hidden = NO;
            self.cameraLab.hidden = NO;
            self.microphonicLab.hidden = NO;
            
            [self.reproducerLab freshWithResult:isReproducer];
            
            [self.cameraLab freshWithResult:isCamera];
            
            [self.microphonicLab freshWithResult:isOpenMicrophone];
                break;
        default:
            break;
    }

    self.permissionsMessage = string;
    
    NSString *filePath = [self chinaOrEnglishWithPermissionsType:permissionsType];
    if (filePath)
    {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
        self.player.delegate = self;
        [self.player setVolume:1.0];
        [self.player play];
    }
}

#pragma mark - 设置提示文本 并在此修改 frame
- (void)setPermissionsMessage:(NSString *)permissionsMessage
{
    _permissionsMessage = permissionsMessage;
    self.whiteView.frame = CGRectMake(49, 0, UI_SCREEN_WIDTH - 49 - 49, 200);
    self.whiteView.bm_bottom = self.view.bm_bottom - 300;
    CGSize maxSize = CGSizeMake(self.whiteView.bm_width-60-25, CGFLOAT_MAX);
    CGSize size = [permissionsMessage bm_sizeToFit:maxSize withFont:UI_FONT_14 lineBreakMode:NSLineBreakByWordWrapping];
    
    self.centerLab.frame = CGRectMake(0, 0, size.width, size.height);
    self.centerLab.text = self.permissionsMessage;
    switch (self.permissionsType)
    {
        case YSPermissionsTypeStart:
            
            self.whiteView.bm_height = size.height+2*21;
            self.centerLab.bm_top = self.whiteView.bm_top + 20;
            self.continueBtn.bm_top = self.whiteView.bm_bottom + 22;
            break;
        case YSPermissionsTypeReproducer:
            
            self.whiteView.bm_height = size.height+2*21;
            self.centerLab.bm_top = self.whiteView.bm_top + 20;
            self.playAudioBtn.bm_top = self.whiteView.bm_bottom + 22;
            self.continueBtn.bm_top = self.playAudioBtn.bm_bottom + 20;
            self.againBtn.bm_top = self.continueBtn.bm_bottom + 20;
            
            break;
        case YSPermissionsTypeCamera:
        case YSPermissionsTypeMicrophonic:
            
            self.whiteView.bm_height = size.height+2*21 + self.topImageView.bm_height + 25;
            self.topImageView.bm_top = self.whiteView.bm_top + 25;
            self.centerLab.bm_top = self.topImageView.bm_bottom + 21;
            self.continueBtn.bm_top = self.whiteView.bm_bottom + 22;
            break;
        case YSPermissionsTypeResult:
            self.whiteView.bm_height = size.height + 21*2 + 20 *3 + 8 * 3 + 20;
            self.centerLab.bm_top = self.whiteView.bm_top + 20;
            
            self.reproducerLab.bm_top = self.centerLab.bm_bottom + 21 ;
            
            self.cameraLab.bm_top = self.reproducerLab.bm_bottom + 8;
            
            self.microphonicLab.bm_top = self.cameraLab.bm_bottom + 8;
            
            self.continueBtn.bm_top = self.whiteView.bm_bottom + 22;
            self.againBtn.bm_top = self.continueBtn.bm_bottom + 20;
            break;
        default:
           
            break;
    }
    self.centerLab.bm_left = self.whiteView.bm_left + 57;
    self.centerLab.bm_right = self.whiteView.bm_right - 21;
    self.titleLab.bm_bottom = self.whiteView.bm_top - 10;
    self.topImageView.bm_centerX = self.centerLab.bm_centerX;
    self.reproducerLab.bm_centerX = self.centerLab.bm_centerX;
    self.microphonicLab.bm_centerX = self.centerLab.bm_centerX;
    self.cameraLab.bm_centerX = self.centerLab.bm_centerX;
    self.animateView.bm_bottom = self.whiteView.bm_bottom + 20;
}

#pragma mark - 继续  听得见 按钮
- (void)continueBtnClicked:(UIButton *)btn
{
    ///查看摄像头权限
    BOOL isCamera = [self cameraPermissionsService];
    ///查看麦克风权限
    BOOL isOpenMicrophone = [self microphonePermissionsService];
    /// 扬声器权限
    BOOL isReproducer = [YSUserDefault getReproducerPermission];

    switch (self.permissionsType)
    {
        case YSPermissionsTypeStart:
            if (!isReproducer)
            {
                self.permissionsType = YSPermissionsTypeReproducer;
                return;
            }
            if (!isCamera)
            {
                self.permissionsType = YSPermissionsTypeCamera;
                return;
            }
            if (!isOpenMicrophone)
            {
                self.permissionsType = YSPermissionsTypeMicrophonic;
                return;
            }
            self.permissionsType = YSPermissionsTypeResult;
            break;
        case YSPermissionsTypeReproducer:
        {
            [YSUserDefault setReproducerPermission:YES];
            if (!isCamera)
            {
                self.permissionsType = YSPermissionsTypeCamera;
                return;
            }
            if (!isOpenMicrophone)
            {
                self.permissionsType = YSPermissionsTypeMicrophonic;
                return;
            }
            self.permissionsType = YSPermissionsTypeResult;
        }
                break;
        case YSPermissionsTypeCamera:
            if (!isOpenMicrophone)
            {
                self.permissionsType = YSPermissionsTypeMicrophonic;
                return;
            }
            self.permissionsType = YSPermissionsTypeResult;
                break;
        case YSPermissionsTypeMicrophonic:
            self.permissionsType = YSPermissionsTypeResult;
                break;
        case YSPermissionsTypeResult:
            [self.player stop];
            if (_toJoinRoom)
            {
                _toJoinRoom();
            }
            [self.navigationController popViewControllerAnimated:NO];
                break;
        default:
            break;
    }
}

#pragma mark - 选取不同的提示音路径

- (NSString *)chinaOrEnglishWithPermissionsType:(YSPermissionsType )permissionsType
{
    ///查看摄像头权限
    BOOL isCamera = [self cameraPermissionsService];
    ///查看麦克风权限
    BOOL isOpenMicrophone = [self microphonePermissionsService];
    /// 扬声器权限
    BOOL isReproducer = [YSUserDefault getReproducerPermission];
    
    // iOS 获取设备当前语言和地区的代码
    NSString *currentLanguageRegion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"YSResources.bundle"]];
    NSString *filePath = nil;
    
    switch (permissionsType)
    {
        case YSPermissionsTypeStart:
            break;
        case YSPermissionsTypeReproducer:
        {
            if([currentLanguageRegion bm_containString:@"zh-Hant"] || [currentLanguageRegion bm_containString:@"zh-Hans"])
            {
                filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeakerDetection_China.mp3"];
            }
            else

            {
                filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"SpeakerDetection_English.mp3"];
            }
        }
                break;
        case YSPermissionsTypeCamera:
            if ([currentLanguageRegion isEqualToString:@"zh-Hans-CN"] || [currentLanguageRegion isEqualToString:@"zh-Hant-CN"])
            {
                filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"CameraDetection_China.mp3"];
            }
            else
            {
                filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"CameraDetection_English.mp3"];
            }
                break;
        case YSPermissionsTypeMicrophonic:
            if ([currentLanguageRegion isEqualToString:@"zh-Hans-CN"] || [currentLanguageRegion isEqualToString:@"zh-Hant-CN"])
            {
                filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"MicrophoneDetection_China.mp3"];
            }
            else
            {
                filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"MicrophoneDetection_English.mp3"];
            }
                break;
        case YSPermissionsTypeResult:
            if (!isOpenMicrophone || !isCamera || !isReproducer)
            {
                if ([currentLanguageRegion isEqualToString:@"zh-Hans-CN"] || [currentLanguageRegion isEqualToString:@"zh-Hant-CN"])
                {
                    filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"TestReportAbnormal_China.mp3"];
                }
                else
                {
                    filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"TestReportAbnormal_English.mp3"];
                }
            }
            else
            {
                if ([currentLanguageRegion isEqualToString:@"zh-Hans-CN"] || [currentLanguageRegion isEqualToString:@"zh-Hant-CN"])
                {
                    filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"TestReportNormal_China.mp3"];
                }
                else
                {
                    filePath = [[bundle resourcePath] stringByAppendingPathComponent:@"TestReportNormal_English.mp3"];
                }
            }

                break;
        default:
            break;
    }
    
    return filePath;
}

#pragma mark - 再次播放
- (void)playAudioBtnClicked:(UIButton *)btn
{
    [self.player stop];
    self.player.currentTime = 0;
    [self.player play];
}

#pragma mark - 听不见 重新检测 按钮
- (void)againBtnClicked:(UIButton *)btn
{
    if (self.permissionsType == YSPermissionsTypeReproducer)
    {
        [YSUserDefault setReproducerPermission:NO];
    }
        
    ///查看摄像头权限
    BOOL isCamera = [self cameraPermissionsService];
    ///查看麦克风权限
    BOOL isOpenMicrophone = [self microphonePermissionsService];

    /// 扬声器权限
    if (self.permissionsType == YSPermissionsTypeResult)
    {
        self.permissionsType = YSPermissionsTypeStart;
        [self.player stop];
        return;
    }
    
    if (!isCamera)
    {
        self.permissionsType = YSPermissionsTypeCamera;
        return;
    }
    if (!isOpenMicrophone)
    {
        self.permissionsType = YSPermissionsTypeMicrophonic;
        return;
    }
    self.permissionsType = YSPermissionsTypeResult;
}


#pragma mark - 查看麦克风权限
- (BOOL)microphonePermissionsService
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    return permissionStatus == AVAudioSessionRecordPermissionGranted;
}

#pragma mark - 查看摄像头权限
- (BOOL)cameraPermissionsService
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus == AVAuthorizationStatusAuthorized;
}


#pragma mark - Lazy
- (UIImageView *)backImageView
{
    if (!_backImageView)
    {
        _backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backImageView.backgroundColor = [UIColor whiteColor];
        [_backImageView setImage:[UIImage imageNamed:@"ysall_login_background"]];
        _backImageView.userInteractionEnabled = YES;
    }
    return _backImageView;
}

@end
