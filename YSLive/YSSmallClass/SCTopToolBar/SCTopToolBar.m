//
//  SCTopToolBar.m
//  YSLive
//
//  Created by fzxm on 2019/11/9.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTopToolBar.h"
#import "SCTopToolBarModel.h"

@interface SCTopToolBar ()

@property (nonatomic, strong) UILabel *roomIDL;
//@property (nonatomic, strong) UIImageView *signalLamp;
@property (nonatomic, strong) UILabel *signalStateL;
//@property (nonatomic, strong) UIImageView *timeImgView;
@property (nonatomic, strong) UILabel *timeL;

@property (nonatomic, strong) UIButton *microphoneBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) UIButton *exitBtn;

@end

@implementation SCTopToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    [self addSubview:self.roomIDL];
//    [self addSubview:self.signalLamp];
    [self addSubview:self.signalStateL];
//    [self addSubview:self.timeImgView];
    [self addSubview:self.timeL];
    
    [self addSubview:self.microphoneBtn];
    [self.microphoneBtn addTarget:self action:@selector(microphoneBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.photoBtn];
    [self.photoBtn addTarget:self action:@selector(photoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.cameraBtn];
    [self.cameraBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.exitBtn];
    [self.exitBtn addTarget:self action:@selector(exitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    BMWeakSelf
    [self.exitBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.centerY.bmmas_equalTo(0);
        make.height.width.bmmas_equalTo(48);
        make.left.bmmas_equalTo(10);
    }];
    
    [self.roomIDL bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
       
        make.centerY.bmmas_equalTo(0);
        make.left.bmmas_equalTo(weakSelf.exitBtn.bmmas_right).bmmas_offset(10);
        make.height.bmmas_equalTo(26);
        make.width.bmmas_equalTo(180);
    }];
//    self.roomIDL.layer.cornerRadius = 13;
//    self.roomIDL.layer.masksToBounds = YES;
    
//    [self.signalLamp mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.left.mas_equalTo(weakSelf.roomIDL.mas_right).mas_offset(10);
//        make.width.height.mas_equalTo(16);
//    }];
    
    [self.signalStateL bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.roomIDL.bmmas_right).bmmas_offset(5);
        make.centerY.bmmas_equalTo(0);
        make.height.bmmas_equalTo(26);
        make.right.bmmas_equalTo(weakSelf.timeL.bmmas_left).bmmas_offset(-5);
        
    }];
    

    
    [self.cameraBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.centerY.bmmas_equalTo(0);
        make.height.width.bmmas_equalTo(48);
        make.right.bmmas_equalTo(-10);
    }];
    
    [self.microphoneBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.centerY.bmmas_equalTo(0);
        make.height.width.bmmas_equalTo(48);
        make.right.bmmas_equalTo(weakSelf.cameraBtn.bmmas_left).bmmas_offset(-10);
    }];
    
    [self.photoBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.centerY.bmmas_equalTo(0);
        make.height.width.bmmas_equalTo(48);
        make.right.bmmas_equalTo(weakSelf.microphoneBtn.bmmas_left).bmmas_offset(-10);
    }];
    
    [self.timeL bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.centerY.bmmas_equalTo(0);
        make.height.bmmas_equalTo(26);
        make.width.bmmas_equalTo(90);
        make.right.bmmas_equalTo(weakSelf.photoBtn.bmmas_left).bmmas_offset(-10);
    }];
//    self.timeL.layer.cornerRadius = 13;
//    self.timeL.layer.masksToBounds = YES;
    
//    [self.timeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.height.width.mas_equalTo(22);
//        make.right.mas_equalTo(weakSelf.timeL.mas_left).mas_offset(-5);
//    }];
}

#pragma mark - topToolModel

- (void)setTopToolModel:(SCTopToolBarModel *)topToolModel
{
    _topToolModel = topToolModel;
    self.roomIDL.text = [NSString stringWithFormat:@"  %@：%@",YSLocalized(@"Label.roomid"),topToolModel.roomID];
//    NSString *netImg = @"";
    NSString *netText = @"";
    switch (topToolModel.netQuality)
    {
        case YSNetQuality_Excellent:
        case YSNetQuality_Good:
        {
//            netImg = @"sc_netquality_good";
            netText = YSLocalized(@"netstate.excellent");
            break;
        }
        case YSNetQuality_Accepted:
        case YSNetQuality_Bad:
        {
//            netImg = @"sc_netquality_good";
            netText = YSLocalized(@"netstate.medium");
            break;
        }
        case YSNetQuality_VeryBad:
        case YSNetQuality_Down:
        {
//            netImg = @"sc_netquality_good";
            netText = YSLocalized(@"netstate.bad");
            break;
        }
    }

//    float a = (float)topToolModel.lostRate * 100;
    
//    self.signalStateL.text = [NSString stringWithFormat:@" 丢包率: %d%%  网络延时: %@ms  网络状态: %@",(int)floor(a),@(topToolModel.netDelay),netText];
    self.signalStateL.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"State.NetworkState"), netText];

    
//    [self.signalLamp setImage:[UIImage imageNamed:netImg]];
    self.timeL.text = topToolModel.lessonTime;
}


#pragma mark - SEL

/// 麦克风
- (void)microphoneBtnClicked:(UIButton *)btn
{
//    BOOL noAudio = [YSUserDefault getAllMuteAudio];
    BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
    
    if (!isEveryoneNoAudio) {
        btn.selected = !btn.selected;
        if ([self.delegate respondsToSelector:@selector(microphoneProxyWithBtn:)])
        {
            [self.delegate microphoneProxyWithBtn:btn];
        }
    }
}

/// 照片
- (void)photoBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(photoProxyWithBtn:)])
    {
        [self.delegate photoProxyWithBtn:btn];
    }
}

/// 摄像头
- (void)cameraBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(cameraProxyWithBtn:)])
    {
        [self.delegate cameraProxyWithBtn:btn];
    }
}

/// 退出
- (void)exitBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(exitProxyWithBtn:)])
    {
        [self.delegate exitProxyWithBtn:btn];
    }
}

- (void)hideMicrophoneBtn:(BOOL)hide
{
    self.microphoneBtn.hidden = hide;
}

- (void)hidePhotoBtn:(BOOL)hide
{
    self.photoBtn.hidden = hide;
}

- (void)hideCameraBtn:(BOOL)hide
{
    self.cameraBtn.hidden = hide;
}

- (void)selectMicrophoneBtn:(BOOL)select
{
    self.microphoneBtn.selected = select;
}

//- (void)selectCameraBtn:(BOOL)select
//{
//    self.cameraBtn.selected = select;
//}


#pragma mark - Lazy

- (UILabel *)roomIDL
{
    if (!_roomIDL)
    {
        _roomIDL = [[UILabel alloc] init];
        _roomIDL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];//[UIColor bm_colorWithHex:0x82ABEC];
//        _roomIDL.backgroundColor = [UIColor bm_colorWithHex:0xFFE895];
        _roomIDL.textAlignment = NSTextAlignmentCenter;
        _roomIDL.font = [UIFont systemFontOfSize:14];
    }
    
    return _roomIDL;
}
//
//- (UIImageView *)signalLamp
//{
//    if (!_signalLamp)
//    {
//        _signalLamp = [[UIImageView alloc] init];
//    }
//    return _signalLamp;
//}

- (UILabel *)signalStateL
{
    if (!_signalStateL)
    {
        _signalStateL = [[UILabel alloc] init];
        _signalStateL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
        _signalStateL.textAlignment = NSTextAlignmentLeft;
        _signalStateL.font = [UIFont systemFontOfSize:14];
    }
    
    return _signalStateL;
}

//- (UIImageView *)timeImgView
//{
//    if (!_timeImgView)
//    {
//        _timeImgView = [[UIImageView alloc] init];
//        [_timeImgView setImage:[UIImage imageNamed:@"sc_topbar_time"]];
//    }
//    return _timeImgView;
//}

- (UILabel *)timeL
{
    if (!_timeL)
    {
        _timeL = [[UILabel alloc] init];
        _timeL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
//        _timeL.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF];
        _timeL.textAlignment = NSTextAlignmentCenter;
        _timeL.font = [UIFont fontWithName:@"Helvetica" size:14];
    }
    
    return _timeL;
}

- (UIButton *)microphoneBtn
{
    if (!_microphoneBtn)
    {
        // _microphoneBtn.selected == YES --> 话筒不可用
        _microphoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_microphoneBtn setImage:[UIImage imageNamed:@"sc_topbar_microphone_normal"] forState:UIControlStateNormal];
        [_microphoneBtn setImage:[UIImage imageNamed:@"sc_topbar_microphone_selected"] forState:UIControlStateSelected];
        //_microphoneBtn.hidden = YES;
    }
    return _microphoneBtn;
}

- (UIButton *)photoBtn
{
    if (!_photoBtn)
    {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoBtn setImage:[UIImage imageNamed:@"sc_topbar_photo_selected"] forState:UIControlStateNormal];
        //[_photoBtn setImage:[UIImage imageNamed:@"sc_topbar_photo_normal"] forState:UIControlStateNormal];
        //[_photoBtn setImage:[UIImage imageNamed:@"sc_topbar_photo_selected"] forState:UIControlStateSelected];
        //_photoBtn.hidden = YES;
    }
    return _photoBtn;
}

- (UIButton *)cameraBtn
{
    if (!_cameraBtn)
    {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setImage:[UIImage imageNamed:@"sc_topbar_camera_normal"] forState:UIControlStateNormal];
        [_cameraBtn setImage:[UIImage imageNamed:@"sc_topbar_camera_selected"] forState:UIControlStateSelected];
    }
    return _cameraBtn;
}

- (UIButton *)exitBtn
{
    if (!_exitBtn)
    {
        _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //[_exitBtn setImage:[UIImage imageNamed:@"sc_topbar_exit_normal"] forState:UIControlStateNormal];
        //[_exitBtn setImage:[UIImage imageNamed:@"sc_topbar_exit_selected"] forState:UIControlStateSelected];
        [_exitBtn setImage:[UIImage imageNamed:@"sc_topbar_exit_selected"] forState:UIControlStateNormal];
    }
    return _exitBtn;
}

@end
