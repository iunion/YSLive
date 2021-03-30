//
//  CHBeautyView.m
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHBeautyView.h"


#define cellH 53

#define leftMargin 20
#define buttonW 100
#define buttonH 20
#define sliderH 15
#define buttonTop (cellH - buttonH - 5 - sliderH)/2

#define viewHeight cellH * self.sliderArray.count


@interface CHBeautyView ()

/// 标题button的数组
@property(nonatomic,strong) NSMutableArray *titleBtnArray;
/// 进度lable的数组
@property(nonatomic,strong) NSMutableArray *lableArray;
/// 进度条的数组
@property(nonatomic,strong) NSMutableArray *sliderArray;

/// 美白属性值
@property(nonatomic,assign) CGFloat whitenValue;

/// 瘦脸属性值
@property(nonatomic,assign) CGFloat thinFaceValue;

/// 大眼属性值
@property(nonatomic,assign) CGFloat bigEyeValue;

/// 磨皮属性值
@property(nonatomic,assign) CGFloat exfoliatingValue;

/// 红润属性值
@property(nonatomic,assign) CGFloat ruddyValue;


@end

@implementation CHBeautyView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleBtnArray = [NSMutableArray array];
        self.lableArray = [NSMutableArray array];
        self.sliderArray = [NSMutableArray array];
        
        [self setupView];
        
        self.frame = frame;
    }
    
    return self;
}

- (void)setupView
{
    NSArray *titleArray = @[@"BeautySet.Whitening",@"BeautySet.ThinFace",@"BeautySet.BigEyes",@"BeautySet.Exfoliating",@"BeautySet.Ruddy"];
    NSArray *imageStrArray = @[@"beauty_whiten",@"beauty_thinFace",@"beauty_bigEye",@"beauty_exfoliating",@"beauty_ruddy"];
    
    for (int i = 0; i < titleArray.count; i++)
    {
        UIButton *button = [self creatTitleButton:titleArray[i] image:imageStrArray[i]];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.titleBtnArray addObject:button];
        
        UILabel *lable = [self creatProgressLable];
        [self.lableArray addObject:lable];
        
        UISlider *slider = [self creatProgressSliderWithTag:i+1];
        [self.sliderArray addObject:slider];
    }
}

- (void)setFrame:(CGRect)frame
{
    frame.size.height = viewHeight;
    
    [super setFrame:frame];

    for (NSInteger i = 0; i < self.sliderArray.count; i++)
    {
        UIButton *button = [self.titleBtnArray bm_safeObjectAtIndex:i];
        button.frame = CGRectMake(leftMargin, i * cellH + buttonTop, buttonW, buttonH);

        UILabel *lable = [self.lableArray bm_safeObjectAtIndex:i];
        lable.frame = CGRectMake(self.bm_width - buttonW - leftMargin, i * cellH + buttonTop, buttonW, buttonH);

        UISlider *slider = [self.sliderArray bm_safeObjectAtIndex:i];
        slider.frame = CGRectMake(leftMargin, button.bm_bottom + 5, self.bm_width - 2*leftMargin, sliderH);
    }
}

- (void)clearBeautyValues
{
    self.whitenValue = self.thinFaceValue = self.bigEyeValue = self.exfoliatingValue = self.ruddyValue = 0.0;
    for (UISlider * slider in self.sliderArray)
    {
        slider.value = 0.0;
    }
}

- (UIButton *)creatTitleButton:(NSString *)title image:(NSString *)imageString
{
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:YSLocalized(title) forState:UIControlStateNormal];
    button.titleLabel.font = UI_FONT_12;
    [button setTitleColor:YSSkinDefineColor(@"WhiteColor") forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageString] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self addSubview:button];
    button.userInteractionEnabled = NO;
    
    return button;
}

- (UILabel *)creatProgressLable
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment= NSTextAlignmentRight;
    label.textColor = YSSkinDefineColor(@"Color3");
    label.font = UI_FONT_12;
    label.text = @"0 %";
    [self addSubview:label];
    
    return label;
}

- (UISlider *)creatProgressSliderWithTag:(NSInteger)tag;
{
    UISlider *slider = [[UISlider alloc]init];
    slider.tag = tag;
    [slider setThumbImage:YSSkinOnlineElementImage(@"online_video_spot", @"iconNor") forState:UIControlStateNormal];
    slider.minimumTrackTintColor = YSSkinDefineColor(@"Color4");
    slider.maximumTrackTintColor = YSSkinDefineColor(@"WhiteColor");
    // slider开始滑动事件
    [slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    [self addSubview:slider];
    
    return slider;
}

#pragma mark - slider事件
// slider开始滑动事件
- (void)progressSliderTouchBegan:(UISlider *)slider
{
}
// slider滑动中事件
- (void)progressSliderValueChanged:(UISlider *)slider
{
    NSInteger value = 100 * slider.value;
    
    UILabel *lab = self.lableArray[slider.tag - 1];
    
    lab.text = [NSString stringWithFormat:@"%ld %%",value];

    
}
// slider结束滑动事件
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    switch (slider.tag)
    {
        case 1:
            self.whitenValue = slider.value;
            break;
        case 2:
            self.thinFaceValue = slider.value;
            break;
        case 3:
            self.bigEyeValue = slider.value;
            break;
        case 4:
            self.exfoliatingValue = slider.value;
            break;
        case 5:
            self.ruddyValue = slider.value;
            break;
            
        default:
            break;
    }

}


@end
