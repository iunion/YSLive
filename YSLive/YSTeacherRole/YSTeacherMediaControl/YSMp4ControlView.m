//
//  YSMp4ControlView.m
//  YSAll
//
//  Created by fzxm on 2020/1/7.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMp4ControlView.h"
#import "YSMediaSlider.h"

@interface YSMp4ControlView ()

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) YSMediaSlider *sliderView;
@property (nonatomic, assign) NSInteger duration;

@end

@implementation YSMp4ControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playBtn.frame = CGRectMake(40, 20, 26, 33);
//    self.playBtn.bm_centerY = self.bm_centerY;
    
    self.nameLabel.frame = CGRectMake( CGRectGetMaxX(self.playBtn.frame) + 12, 18, self.bm_width - 220, 17);
//    self.nameLabel.bm_left = self.playBtn.bm_right + 12;
    
    self.timeLabel.frame = CGRectMake( 0, 18, 100, 17);
    self.timeLabel.bm_right = self.bm_width - 30;
    
    self.sliderView.frame = CGRectMake(0, 0,self.bm_width - 120, 10);
    self.sliderView.bm_top = self.nameLabel.bm_bottom + 10;
    self.sliderView.bm_left = self.playBtn.bm_right + 12;
}

- (void)setup
{
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:playBtn];

    self.playBtn = playBtn;
    [playBtn setBackgroundImage:YSSkinElementImage(@"media_play", @"iconNor") forState:UIControlStateNormal];
    [playBtn setBackgroundImage:YSSkinElementImage(@"media_play", @"iconSel") forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
    nameLabel.textAlignment = NSTextAlignmentLeft;

    UILabel *timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake( 0, 18, 100, 17)];
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
    timeLabel.textAlignment = NSTextAlignmentRight;

    YSMediaSlider *sliderView = [[YSMediaSlider alloc] init];
    [self addSubview:sliderView];
    self.sliderView = sliderView;
//    sliderView.continuous = NO;
    sliderView.minimumTrackTintColor = YSSkinDefineColor(@"defaultTitleColor");
    sliderView.maximumTrackTintColor = YSSkinDefineColor(@"mediaSliderBgColor");
//    sliderView.thumbTintColor = [UIColor bm_colorWithHex:0x9DBEF3];
    [sliderView setThumbImage:YSSkinElementImage(@"media_slider", @"iconNor") forState:UIControlStateNormal];
    [sliderView addTarget:self action:@selector(sliderViewChange:) forControlEvents:UIControlEventValueChanged];
    [sliderView addTarget:self action:@selector(sliderViewStart:) forControlEvents:UIControlEventTouchDown];
    [sliderView addTarget:self action:@selector(sliderViewEnd:) forControlEvents:UIControlEventTouchUpInside];
    [sliderView addTarget:self action:@selector(sliderViewEnd:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)setMediaStream:(NSTimeInterval)duration pos:(NSTimeInterval)pos isPlay:(BOOL)isPlay fileName:(nonnull NSString *)fileName
{
    self.duration = duration;
    self.nameLabel.text = fileName;
    NSInteger current = pos;
    if (current <= 0)
    {
        current = 0;
    }
    NSString *currentTime = [self countDownStringDateFromTs:current/1000];
    NSString *totalTime = [self countDownStringDateFromTs:duration/1000];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTime,totalTime];
    self.isPlay = isPlay;
    CGFloat value = pos / duration;
    [self.sliderView setValue:value animated:NO];
}

- (void)setIsPlay:(BOOL)isPlay
{
    _isPlay = isPlay;
    self.playBtn.selected = !isPlay;
}

- (void)sliderViewChange:(YSMediaSlider *)sender
{
    NSString *currentTime = [self countDownStringDateFromTs:self.duration * sender.value/1000];
    NSString *totalTime = [self countDownStringDateFromTs:self.duration/1000];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTime,totalTime];
}

- (void)sliderViewStart:(YSMediaSlider *)sender
{
    [[YSLiveManager sharedInstance] pauseSharedMediaFile:self.mediaFileModel.fileUrl isPause:YES];
}

- (void)sliderViewEnd:(YSMediaSlider *)sender
{
    BMLog(@"sliderViewEnd: %@ ===========================", @(sender.value));

    if ([self.delegate respondsToSelector:@selector(sliderYSMp4ControlViewPos:withFileModel:)])
    {
        [self.delegate sliderYSMp4ControlViewPos:sender.value * self.duration withFileModel:self.mediaFileModel];
    }
    
    [[YSLiveManager sharedInstance] pauseSharedMediaFile:self.mediaFileModel.fileUrl isPause:NO];
}

- (void)playBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(playYSMp4ControlViewPlay:withFileModel:)])
    {
        [self.delegate playYSMp4ControlViewPlay:btn.selected withFileModel:self.mediaFileModel];
    }
}

- (NSString *)countDownStringDateFromTs:(NSUInteger)count
{
    if (count <= 0)
    {
        return @"00:00";
    }

    NSUInteger min = count/BMSECONDS_IN_MINUTE;
    NSUInteger second = count%BMSECONDS_IN_MINUTE;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)second];
}

@end
