//
//  NKAVPlayerView.m
//  NKAVPlayer
//
//  Created by 宁杰英 on 2020/2/7.
//  Copyright © 2020 YS. All rights reserved.
//


#import "YSSchoolAVPlayerView.h"

@interface YSSchoolAVPlayerView()
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *returnBtn;
@property (nonatomic, strong) UIView *bacView;
@property (nonatomic, assign) CGRect shrinkRect;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger allSeconds;
@property (nonatomic, assign) BOOL isHide;

@end

@implementation YSSchoolAVPlayerView
- (AVPlayer *)avPlayer
{
    if (_avPlayer == nil) {
        _avPlayer = [[AVPlayer alloc] init];
        // 设置默认音量
//        _avPlayer.volume = 0.5;
        // 获取系统声音
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        CGFloat currentVolume = audioSession.outputVolume;
        _avPlayer.volume = currentVolume;
    }
    return _avPlayer;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (instancetype)init
{
    if (self = [super init]) {
        // 让view的layerClass为AVPlayerLayer类，那么self.layer就为AVPlayerLayer的实例
        self.playerLayer = (AVPlayerLayer *)self.layer;
        self.playerLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
        // 初始化playerLayer的player
        self.playerLayer.player = self.avPlayer;
        [self settingControlUI];
        
    }
    return self;
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem
{
    if (self = [super init]) {
        self.playerLayer = (AVPlayerLayer *)self.layer;
        self.playerLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
        self.playerLayer.player = self.avPlayer;
        
        _playerItem = playerItem;
        [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
        
        [self settingControlUI];
        
    }
    return self;
}

- (void)settingControlUI
{
//    self.controlView = [[NKAVPlayerControlView alloc] initWithFrame:self.bounds];
//    [self addSubview:_controlView];
//
//    [self.controlView.playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
//    [self.controlView.pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
//    [self.controlView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.controlView.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    __weak typeof(self) weakSelf = self;
//    self.controlView.playerSilder.tapChangeValue = ^(float value) {
//        CMTime duration = weakSelf.playerItem.duration;
//        [weakSelf.playerItem seekToTime:CMTimeMake(CMTimeGetSeconds(duration) * value, 1.0) completionHandler:^(BOOL finished) {
//
//        }];
//    };
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toHiddenView:)];
    [self addGestureRecognizer:tap];
    self.isHide = NO;
    
    UIView *topView = [[UIView alloc] init];
    self.topView = topView;
    [self addSubview:topView];
    self.topView.backgroundColor = [UIColor bm_colorWithHex:0x6D7278 alpha:0.39];
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.topView addSubview:returnBtn];
    self.returnBtn = returnBtn;
    [returnBtn setImage:[UIImage imageNamed:@"ysteacher_closemp4_normal"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(returnBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *bacView = [[UIView alloc] init];
    self.bacView = bacView;
    [self addSubview:bacView];
    self.bacView.backgroundColor = [UIColor bm_colorWithHex:0x6D7278 alpha:0.39];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bacView addSubview:playBtn];
    
    self.playBtn = playBtn;
    [playBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_media_play_Selected"] forState:UIControlStateNormal];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_media_play_Normal"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [self.bacView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    
    
    UILabel *timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake( 0, 18, 100, 17)];
    [self.bacView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    
    
    UISlider *sliderView = [[UISlider alloc] init];
    [self.bacView addSubview:sliderView];
    self.sliderView = sliderView;
    sliderView.minimumTrackTintColor = [UIColor bm_colorWithHex:0xFFE895];
    sliderView.maximumTrackTintColor = [UIColor bm_colorWithHex:0xDEEAFF];
    [sliderView setThumbImage:[UIImage imageNamed:@"scteacher_sliderView_Normal"] forState:UIControlStateNormal];
    [sliderView addTarget:self action:@selector(sliderViewChange:) forControlEvents:UIControlEventValueChanged];
    [sliderView addTarget:self action:@selector(sliderViewStart:) forControlEvents:UIControlEventTouchDown];
    [sliderView addTarget:self action:@selector(sliderViewEnd:) forControlEvents:UIControlEventTouchUpInside];
    [sliderView addTarget:self action:@selector(sliderViewEnd:) forControlEvents:UIControlEventTouchUpOutside];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topView.frame = CGRectMake(0,0, self.bounds.size.width, 40);
    self.returnBtn.frame = CGRectMake(self.topView.bounds.size.width - 50, 10, 20, 20);

    
    self.bacView.frame = CGRectMake(30, self.bounds.size.height - 90, self.bounds.size.width - 60, 70);

    self.bacView.layer.cornerRadius = 35;
    self.playBtn.frame = CGRectMake(40, 18, 26, 33);
    
    self.nameLabel.text = @"爱德克斯积分哈萨克的";
    self.nameLabel.frame = CGRectMake( CGRectGetMaxX(self.playBtn.frame) + 12, 18, self.bacView.bm_width - 220, 17);
    
    self.timeLabel.frame = CGRectMake( 0, 18, 100, 17);
    self.timeLabel.bm_right = self.bacView.bm_right - 60;
    
    self.sliderView.frame = CGRectMake(0, 0,self.bacView.bm_width - 120, 10);
    self.sliderView.bm_top = self.nameLabel.bm_bottom + 10;
    self.sliderView.bm_left = self.playBtn.bm_right + 12;
}

- (void)settingPlayerItemWithUrl:(NSURL *)playerUrl
{
    [self settingPlayerItem:[[AVPlayerItem alloc] initWithURL:playerUrl]];
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:playerUrl];
    CMTime time = [avUrl duration];
    NSInteger seconds = ceil(time.value/time.timescale);
    self.allSeconds = seconds;
}

- (void)settingPlayerItem:(AVPlayerItem *)playerItem
{
    _playerItem = playerItem;
    [self removeObserver];
    self.playBtn.selected = NO;
    [self.avPlayer pause];
    /*
     replaceCurrentItemWithPlayerItem: 用于切换视频
     */
    // 设置当前playerItem
    [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];

    [self addObserver];
}

- (void)removeObserver
{
    // 移除监听 和通知
    // 监控它的status也可以获得播放状态
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    // 缓冲加载
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    // 播放完成
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.avPlayer removeTimeObserver:self.timeObserver];
}

- (void)addObserver{
    
    // 监控它的status也可以获得播放状态
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    //监控缓冲加载
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    //监控播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];
    
    //监控时间进度(根据API提示，如果要监控时间进度，这个对象引用计数器要+1，retain)
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 获取 item 当前播放秒
        float currentPlayTime = (double)weakSelf.avPlayer.currentItem.currentTime.value/ weakSelf.avPlayer.currentItem.currentTime.timescale;
        [weakSelf updateVideoSlider:currentPlayTime];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        // 播放状态
        AVPlayerItemStatus status = [[change objectForKey:@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                self.playBtn.selected = NO;
                [self.avPlayer play];
            }
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"加载失败");
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"未知资源");
                break;
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
    }
    else if ([keyPath isEqualToString:@"rate"]) {
        // rate=1:播放，rate!=1:非播放
        
    } else if ([keyPath isEqualToString:@"currentItem"])
    {
       
    }
}

- (void)playFinished:(NSNotification *)notifi
{
    [self.playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
    self.playBtn.selected = YES;
    
}

- (void)playBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected)
    {
        [self.avPlayer pause];
    }
    else
    {
        
        [self.avPlayer play];
    }
}

- (void)returnBtnClicked:(UIButton *)btn
{
    
    [self removeFromSuperview];
    if (self.closeBlock)
    {
        self.closeBlock();
    }

}

- (void)toHiddenView:(UITapGestureRecognizer *)tap
{
    self.isHide = !self.isHide;
    self.topView.hidden = self.isHide;
    self.bacView.hidden = self.isHide;

}

// 更新进度条时间
- (void)updateVideoSlider:(float)currentPlayTime
{
    CMTime duration = _playerItem.duration;
//    self.timeLabel.text = [NSString stringWithFormat:@"%.0f:%.0f", currentPlayTime, CMTimeGetSeconds(duration)];
    int current ;
    current = ceil(currentPlayTime);
    NSString *currentTime = [self countDownStringDateFromTs:current];
    NSString *totalTime = [self countDownStringDateFromTs:self.allSeconds];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTime,totalTime];
    self.sliderView.value = currentPlayTime / CMTimeGetSeconds(duration);
}

- (void)sliderViewChange:(UISlider *)sender
{
    NSString *currentTime = [self countDownStringDateFromTs:self.allSeconds * sender.value];
    NSString *totalTime = [self countDownStringDateFromTs:self.allSeconds];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTime,totalTime];
}

- (void)sliderViewStart:(UISlider *)sender
{
    self.playBtn.selected = YES;
    [self.avPlayer pause];
}

- (void)sliderViewEnd:(UISlider *)sender
{
    
    CMTime duration = self.playerItem.duration;
    BMWeakSelf
    [self.playerItem seekToTime:CMTimeMake(CMTimeGetSeconds(duration) * sender.value, 1.0) completionHandler:^(BOOL finished) {
        if (finished)
        {
            weakSelf.playBtn.selected = NO;
            [weakSelf.avPlayer play];
        }
    }];

}

- (NSString *)countDownStringDateFromTs:(NSUInteger)count
{
    if (count <= 0)
    {
        return @"00:00";
    }
    NSUInteger min = count/SECONDS_IN_MINUTE;
    NSUInteger second = count%SECONDS_IN_MINUTE;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)second];
}

- (void)dealloc
{
    [self removeObserver];
    // 注销通知
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.avPlayer = nil;
}


@end
