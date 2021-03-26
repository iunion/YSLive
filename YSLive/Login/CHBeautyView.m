//
//  CHBeautyView.m
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHBeautyView.h"

@interface CHBeautyView ()

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
//        self.backgroundColor = [YSSkinDefineColor(@"Color2") bm_changeAlpha:0.4];
        self.lableArray = [NSMutableArray array];
        self.sliderArray = [NSMutableArray array];
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    CGFloat buttonW = 60;
    CGFloat buttonH = 20;
    CGFloat sliderH = 15;
    
    CGFloat cellH = self.bm_height/5;
    CGFloat buttonTop = (cellH - buttonH - 5 - sliderH)/2;
    
    NSArray *titleArray = @[@"美白",@"瘦脸",@"大眼",@"磨皮",@"红润"];
    NSArray *imageStrArray = @[@"beautyWhiten",@"beautyThinFace",@"beautyBigEye",@"beautyExfoliating",@"beautyRuddy"];
    
    for (int i = 0; i < 5; i++)
    {
        UIButton *button = [self creatTitleButton:titleArray[i] image:imageStrArray[i]];
        button.frame = CGRectMake(20, i * cellH + buttonTop, buttonW, buttonH);
        
        UILabel *lable = [self creatProgressLable];
        lable.frame = CGRectMake(self.bm_width - buttonW - 20, i * cellH + buttonTop, buttonW, buttonH);
        [self.lableArray addObject:lable];
        
        UISlider *slider = [self creatProgressSliderWithTag:i+1];
        slider.frame = CGRectMake(20, button.bm_bottom + 5, self.bm_width - 2*20, sliderH);
        [self.sliderArray addObject:slider];
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
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = UI_FONT_12;
    [button setTitleColor:YSSkinDefineColor(@"WhiteColor") forState:UIControlStateNormal];
    [button setImage:YSSkinElementImage(imageString, @"iconNor") forState:UIControlStateNormal];
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
