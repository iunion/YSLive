//
//  CHPermissionsView.m
//  YSLive
//
//  Created by jiang deng on 2021/3/29.
//  Copyright © 2021 CH. All rights reserved.
//

#define CHPermissionsView_IconWidth         20.0f
#define CHPermissionsView_BtnWidth          30.0f

#define CHPermissionsView_Gap               20.0f
#define CHPermissionsView_LeftGap           20.0f

#define CHPermissionsView_SGap              10.0f

#import "CHPermissionsView.h"
#import <BMKit/BMImageTextView.h>

@interface CHPermissionsView ()

@property (nonatomic, strong) UIImageView *camIcon;
@property (nonatomic, strong) UILabel *camLabel;
@property (nonatomic, strong) UIImageView *micIcon;
@property (nonatomic, strong) UILabel *micLabel;
@property (nonatomic, strong) UIImageView *speakIcon;
@property (nonatomic, strong) UILabel *speakLabel;
@property (nonatomic, strong) UIImageView *beautyIcon;
@property (nonatomic, strong) UILabel *beautyLabel;

@property (nonatomic, strong) UIButton *camButton;
@property (nonatomic, strong) UIButton *speakButton;
@property (nonatomic, strong) UIButton *beautyButton;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) BMImageTextView *hMirrorBtn;
@property (nonatomic, strong) BMImageTextView *vMirrorBtn;

@property (nonatomic, strong) UIView *lineView1;
@property (nonatomic, strong) UIView *lineView2;
@property (nonatomic, strong) UIView *lineView3;

@property (nonatomic, strong) UIImageView *volumBgImage;
@property (nonatomic, strong) UIImageView *volumImage;

@end

@implementation CHPermissionsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
        
        self.frame = frame;
    }
    
    return self;
}

- (void)setupView
{
    self.backgroundColor = UIColor.clearColor;
    
    BMWeakSelf
    
    // 摄像头
    UIImageView *camIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"permissions_cam_icon"]];
    camIcon.frame = CGRectMake(CHPermissionsView_LeftGap, CHPermissionsView_Gap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    [self addSubview:camIcon];
    self.camIcon = camIcon;
    
    UILabel *camLabel = [[UILabel alloc] initWithFrame:CGRectMake(camIcon.bm_right + 4.0f, CHPermissionsView_Gap, 80.0f, CHPermissionsView_IconWidth)];
    camLabel.font = [UIFont systemFontOfSize:12.0f];
    camLabel.textColor = UIColor.whiteColor;
    camLabel.text = YSLocalized(@"BeautySet.Cam");
    [self addSubview:camLabel];
    self.camLabel = camLabel;

    UIButton *camButton = [[UIButton alloc] init];
    [camButton setImage:[UIImage imageNamed:@"permissions_camswitch"] forState:UIControlStateNormal];
    [camButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:camButton];
    self.camButton = camButton;

    // 麦克风镜像
    BMImageTextView *hMirrorBtn = [[BMImageTextView alloc] initWithImage:@"permissions_unmirror" text:YSLocalized(@"BeautySet.Cam.HMirror") height:30.0f gap:4.0f];
    hMirrorBtn.textColor = UIColor.whiteColor;
    [self addSubview:hMirrorBtn];
    self.hMirrorBtn = hMirrorBtn;
    self.hMirrorBtn.imageTextViewClicked = ^(BMImageTextView * _Nonnull imageTextView) {

        weakSelf.beautySetModel.hMirror = !weakSelf.beautySetModel.hMirror;
        if (weakSelf.beautySetModel.hMirror)
        {
            weakSelf.hMirrorBtn.imageName = @"permissions_mirror";
        }
        else
        {
            weakSelf.hMirrorBtn.imageName = @"permissions_unmirror";
        }

        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onPermissionsViewChanged:value:)])
        {
            [weakSelf.delegate onPermissionsViewChanged:CHPermissionsViewChange_HMirror value:weakSelf.beautySetModel.hMirror];
        }
    };

    BMImageTextView *vMirrorBtn = [[BMImageTextView alloc] initWithImage:@"permissions_unmirror" text:YSLocalized(@"BeautySet.Cam.VMirror") height:30.0f gap:4.0f];
    vMirrorBtn.textColor = UIColor.whiteColor;
    [self addSubview:vMirrorBtn];
    self.vMirrorBtn = vMirrorBtn;
    [self.vMirrorBtn layoutSubviews];
    self.vMirrorBtn.imageTextViewClicked = ^(BMImageTextView * _Nonnull imageTextView) {
        
        weakSelf.beautySetModel.vMirror = !weakSelf.beautySetModel.vMirror;
        if (weakSelf.beautySetModel.vMirror)
        {
            weakSelf.vMirrorBtn.imageName = @"permissions_mirror";
        }
        else
        {
            weakSelf.vMirrorBtn.imageName = @"permissions_unmirror";
        }

        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onPermissionsViewChanged:value:)])
        {
            [weakSelf.delegate onPermissionsViewChanged:CHPermissionsViewChange_VMirror value:weakSelf.beautySetModel.vMirror];
        }
    };

    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = UIColor.whiteColor;
    [self addSubview:lineView1];
    self.lineView1 = lineView1;
    
    // 麦克风
    UIImageView *micIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"permissions_mic_icon"]];
    micIcon.frame = CGRectMake(CHPermissionsView_LeftGap, self.lineView1.bm_bottom+CHPermissionsView_SGap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    [self addSubview:micIcon];
    self.micIcon = micIcon;
    
    UILabel *micLabel = [[UILabel alloc] initWithFrame:CGRectMake(micIcon.bm_right + 4.0f, self.lineView1.bm_bottom+CHPermissionsView_SGap, 80.0f, CHPermissionsView_IconWidth)];
    micLabel.font = [UIFont systemFontOfSize:12.0f];
    micLabel.textColor = UIColor.whiteColor;
    micLabel.text = YSLocalized(@"BeautySet.Mic");
    [self addSubview:micLabel];
    self.micLabel = micLabel;

    // 麦克风音量
    UIImageView *volumBgImage = [[UIImageView alloc] init];
    volumBgImage.image = [UIImage bm_resizedImageModeTileWithName:@"permissions_unprogress"];
    [self addSubview:volumBgImage];
    self.volumBgImage = volumBgImage;

    UIImageView *volumImage = [[UIImageView alloc] init];
    volumImage.image = [UIImage bm_resizedImageModeTileWithName:@"permissions_progress"];
    [self addSubview:volumImage];
    self.volumImage = volumImage;

    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = UIColor.whiteColor;
    [self addSubview:lineView2];
    self.lineView2 = lineView2;
    
    // 扬声器
    UIImageView *speakIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"permissions_speaker_icon"]];
    speakIcon.frame = CGRectMake(CHPermissionsView_LeftGap, self.lineView2.bm_bottom+CHPermissionsView_SGap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    [self addSubview:speakIcon];
    self.speakIcon = speakIcon;
    
    UILabel *speakLabel = [[UILabel alloc] initWithFrame:CGRectMake(speakIcon.bm_right + 4.0f, self.lineView2.bm_bottom+CHPermissionsView_SGap, 80.0f, CHPermissionsView_IconWidth)];
    speakLabel.font = [UIFont systemFontOfSize:12.0f];
    speakLabel.textColor = UIColor.whiteColor;
    speakLabel.text = YSLocalized(@"BeautySet.Speaker");
    [self addSubview:speakLabel];
    self.speakLabel = speakLabel;

    UIButton *speakButton = [[UIButton alloc] init];
    [speakButton setImage:[UIImage imageNamed:@"permissions_audioplay"] forState:UIControlStateNormal];
    [speakButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:speakButton];
    self.speakButton = speakButton;

    UIView *lineView3 = [[UIView alloc] init];
    lineView3.backgroundColor = UIColor.whiteColor;
    [self addSubview:lineView3];
    self.lineView3 = lineView3;
    
    // 扬声器
    UIImageView *beautyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"permissions_beauty_icon"]];
    beautyIcon.frame = CGRectMake(CHPermissionsView_LeftGap, self.lineView3.bm_bottom+CHPermissionsView_SGap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    [self addSubview:beautyIcon];
    self.beautyIcon = beautyIcon;
    
    UILabel *beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(beautyIcon.bm_right + 4.0f, self.lineView3.bm_bottom+CHPermissionsView_SGap, 80.0f, CHPermissionsView_IconWidth)];
    beautyLabel.font = [UIFont systemFontOfSize:12.0f];
    beautyLabel.textColor = UIColor.whiteColor;
    beautyLabel.text = YSLocalized(@"BeautySet.Beauty");
    [self addSubview:beautyLabel];
    self.beautyLabel = beautyLabel;

    UIButton *beautyButton = [[UIButton alloc] init];
    [beautyButton setImage:[UIImage imageNamed:@"permissions_beautyset"] forState:UIControlStateNormal];
    [beautyButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:beautyButton];
    self.beautyButton = beautyButton;
    
    // permissions_cam_icon permissions_camswitch permissions_audiopause permissions_audioplay
    // permissions_beautyset permissions_beauty_icon permissions_mic_icon permissions_speaker_icon
    // permissions_unmirror permissions_mirror permissions_progress permissions_unprogress
}

- (void)setBeautySetModel:(CHBeautySetModel *)beautySetModel
{
    _beautySetModel = beautySetModel;
    
    if (!beautySetModel.cameraPermissions)
    {
        self.hMirrorBtn.userInteractionEnabled = NO;
        self.hMirrorBtn.textColor = UIColor.grayColor;
        self.hMirrorBtn.imageName = @"permissions_unmirror";
        
        self.vMirrorBtn.userInteractionEnabled = NO;
        self.vMirrorBtn.textColor = UIColor.grayColor;
        self.vMirrorBtn.imageName = @"permissions_unmirror";

        self.camButton.enabled = NO;
    }
    
    if (!beautySetModel.microphonePermissions)
    {
        self.volumBgImage.image = [UIImage bm_resizedImageModeTileWithName:@"permissions_unprogress"];
        self.volumImage.hidden = YES;
    }
}

- (void)setFrame:(CGRect)frame
{
    CGFloat width = frame.size.width;
    
    self.camIcon.frame = CGRectMake(CHPermissionsView_LeftGap, CHPermissionsView_Gap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    self.camLabel.frame = CGRectMake(self.camIcon.bm_right + 4.0f, CHPermissionsView_Gap, 80.0f, CHPermissionsView_IconWidth);
    self.camButton.frame = CGRectMake(width-CHPermissionsView_LeftGap-CHPermissionsView_BtnWidth, CHPermissionsView_Gap, CHPermissionsView_BtnWidth, CHPermissionsView_BtnWidth);
    self.camButton.bm_centerY = self.camIcon.bm_centerY;

    self.hMirrorBtn.bm_top = self.camIcon.bm_bottom + CHPermissionsView_SGap;
    self.hMirrorBtn.bm_left = CHPermissionsView_LeftGap;

    self.vMirrorBtn.bm_top = self.camIcon.bm_bottom + CHPermissionsView_SGap;
    self.vMirrorBtn.bm_left = width-CHPermissionsView_LeftGap-self.vMirrorBtn.bm_width;
    
    self.lineView1.frame = CGRectMake(CHPermissionsView_LeftGap, self.hMirrorBtn.bm_bottom + CHPermissionsView_Gap, width-CHPermissionsView_LeftGap*2.0f, BMSINGLE_LINE_WIDTH);
    
    self.micIcon.frame = CGRectMake(CHPermissionsView_LeftGap, self.lineView1.bm_bottom+CHPermissionsView_Gap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    self.micLabel.frame = CGRectMake(self.micIcon.bm_right + 4.0f, self.lineView1.bm_bottom+CHPermissionsView_Gap, 80.0f, CHPermissionsView_IconWidth);

    self.volumBgImage.frame = CGRectMake(CHPermissionsView_LeftGap, self.micIcon.bm_bottom + CHPermissionsView_SGap, width-CHPermissionsView_LeftGap*2.0f, 14.0f);
    self.volumImage.frame = CGRectMake(CHPermissionsView_LeftGap, self.micIcon.bm_bottom + CHPermissionsView_SGap, 80.0f, 14.0f);
    
    self.lineView2.frame = CGRectMake(CHPermissionsView_LeftGap, self.volumBgImage.bm_bottom + CHPermissionsView_Gap, width-CHPermissionsView_LeftGap*2.0f, BMSINGLE_LINE_WIDTH);
    
    self.speakIcon.frame = CGRectMake(CHPermissionsView_LeftGap, self.lineView2.bm_bottom+CHPermissionsView_Gap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    self.speakLabel.frame = CGRectMake(self.speakIcon.bm_right + 4.0f, self.lineView2.bm_bottom+CHPermissionsView_Gap, 80.0f, CHPermissionsView_IconWidth);

    self.speakButton.frame = CGRectMake(width-CHPermissionsView_LeftGap-CHPermissionsView_BtnWidth, CHPermissionsView_Gap, CHPermissionsView_BtnWidth, CHPermissionsView_BtnWidth);
    self.speakButton.bm_centerY = self.speakIcon.bm_centerY;

    self.lineView3.frame = CGRectMake(CHPermissionsView_LeftGap, self.speakIcon.bm_bottom + CHPermissionsView_Gap, width-CHPermissionsView_LeftGap*2.0f, BMSINGLE_LINE_WIDTH);
    
    self.beautyIcon.frame = CGRectMake(CHPermissionsView_LeftGap, self.lineView3.bm_bottom+CHPermissionsView_Gap, CHPermissionsView_IconWidth, CHPermissionsView_IconWidth);
    self.beautyLabel.frame = CGRectMake(self.beautyIcon.bm_right + 4.0f, self.lineView3.bm_bottom+CHPermissionsView_Gap, 80.0f, CHPermissionsView_IconWidth);

    self.beautyButton.frame = CGRectMake(width-CHPermissionsView_LeftGap-CHPermissionsView_BtnWidth, CHPermissionsView_Gap, CHPermissionsView_BtnWidth, CHPermissionsView_BtnWidth);
    self.beautyButton.bm_centerY = self.beautyIcon.bm_centerY;
    
    frame.size.height = self.beautyLabel.bm_bottom + CHPermissionsView_Gap;
    
    [super setFrame:frame];
}

- (void)changeVolumLevel:(CGFloat)volumLevel
{
    self.volumImage.bm_width = self.volumBgImage.bm_width * volumLevel;
}

- (void)stopPlay
{
    self.isPlaying = NO;
    [self.speakButton setImage:[UIImage imageNamed:@"permissions_audioplay"] forState:UIControlStateNormal];
}

- (void)btnClick:(UIButton *)btn
{
    CHPermissionsViewChangeType changeType = CHPermissionsViewChange_None;
    BOOL value = NO;
    if (btn == self.camButton)
    {
        changeType = CHPermissionsViewChange_Cam;
        self.beautySetModel.switchCam = !self.beautySetModel.switchCam;
        value = self.beautySetModel.switchCam;
    }
    else if (btn == self.speakButton)
    {
        changeType = CHPermissionsViewChange_Play;
        self.isPlaying = !self.isPlaying;
        value = self.isPlaying;

        if (self.isPlaying)
        {
            [self.speakButton setImage:[UIImage imageNamed:@"permissions_audiopause"] forState:UIControlStateNormal];
        }
        else
        {
            [self.speakButton setImage:[UIImage imageNamed:@"permissions_audioplay"] forState:UIControlStateNormal];
        }
    }
    else if (btn == self.beautyButton)
    {
        changeType = CHPermissionsViewChange_BeautySet;
    }

    if (changeType == CHPermissionsViewChange_None)
    {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPermissionsViewChanged:value:)])
    {
        [self.delegate onPermissionsViewChanged:changeType value:value];
    }
}

@end
