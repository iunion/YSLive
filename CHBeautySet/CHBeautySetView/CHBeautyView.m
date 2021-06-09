//
//  CHBeautyView.m
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHBeautyView.h"


//#define CHBeautyView_Gap                20.0f
#define CHBeautyView_LeftGap            20.0f

#define CHBeautyView_IconWidth          20.0f
#define CHBeautyView_sliderHeight       30.0f
#define CHBeautyView_LabelWidth         100.0f

#define CHBeautyView_SGap               6.0f

@interface CHBeautyView ()

/// 标题button的数组
@property(nonatomic,strong) NSMutableArray *titleIconArray;
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

@property (nonatomic, assign) CGFloat gap;

@end

@implementation CHBeautyView

- (instancetype)initWithFrame:(CGRect)frame itemGap:(CGFloat)gap
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.gap = gap;

        self.titleIconArray = [NSMutableArray array];
        self.lableArray = [NSMutableArray array];
        self.sliderArray = [NSMutableArray array];
        
        [self setupView];
        
        self.frame = frame;
    }
    
    return self;
}

- (void)setupView
{
    self.backgroundColor = UIColor.clearColor;

//    NSArray *titleArray = @[@"BeautySet.Whitening", @"BeautySet.ThinFace", @"BeautySet.BigEyes", @"BeautySet.Exfoliating", @"BeautySet.Ruddy"];
//    NSArray *imageStrArray = @[@"beauty_whiten", @"beauty_thinFace", @"beauty_bigEye", @"beauty_exfoliating", @"beauty_ruddy"];
    
    NSArray *titleArray = @[@"BeautySet.Whitening", @"BeautySet.Exfoliating", @"BeautySet.Ruddy"];
    NSArray *imageStrArray = @[@"beauty_whiten", @"beauty_exfoliating", @"beauty_ruddy"];
    
    for (NSUInteger i = 0; i < titleArray.count; i++)
    {
        BMImageTextView *titleIconView = [self creatTitleIcon:titleArray[i] image:imageStrArray[i]];
        [self.titleIconArray addObject:titleIconView];
        
        UILabel *lable = [self creatProgressLable];
        [self.lableArray addObject:lable];
        
        UISlider *slider = [self creatProgressSliderWithTag:i+1];
        [self.sliderArray addObject:slider];
    }
}

- (BMImageTextView *)creatTitleIcon:(NSString *)title image:(NSString *)imageString
{
    BMImageTextView *titleIconView = [[BMImageTextView alloc] initWithImage:imageString text:YSLocalized(title) height:CHBeautyView_IconWidth gap:4.0f];
    titleIconView.imageSize = CGSizeMake(CHBeautyView_IconWidth, CHBeautyView_IconWidth);
    titleIconView.textFont = UI_FONT_12;
    titleIconView.textColor = UIColor.whiteColor;
    [self addSubview:titleIconView];
    titleIconView.userInteractionEnabled = NO;
    
    return titleIconView;
}

- (UILabel *)creatProgressLable
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CHBeautyView_LabelWidth, CHBeautyView_IconWidth)];
    label.textAlignment= NSTextAlignmentRight;
    label.textColor = UIColor.whiteColor;
    label.font = UI_FONT_12;
    label.text = @"0 %";
    [self addSubview:label];
    
    return label;
}

- (UISlider *)creatProgressSliderWithTag:(NSInteger)tag;
{
    UISlider *slider = [[UISlider alloc]init];
    slider.tag = tag;
    [slider setThumbImage:[UIImage imageNamed:@"beauty_slider"] forState:UIControlStateNormal];
    slider.minimumTrackTintColor = [UIColor bm_colorWithHex:0x82ABEC];
    slider.maximumTrackTintColor = UIColor.whiteColor;
    // slider开始滑动事件
    [slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    [self addSubview:slider];
    
    return slider;
}

- (void)setBeautySwitch:(BOOL)beautySwitch
{
    _beautySwitch = beautySwitch;
    
    self.beautySetModel.beautySwitch = beautySwitch;
    if (beautySwitch)
    {
        for (UISlider *slider in self.sliderArray)
        {
            slider.minimumTrackTintColor = [UIColor bm_colorWithHex:0x82ABEC];
            slider.userInteractionEnabled = YES;
        }
    }
    else
    {
        for (UISlider *slider in self.sliderArray)
        {
            slider.minimumTrackTintColor = [UIColor bm_colorWithHex:0xC4C4C4];
            slider.userInteractionEnabled = NO;
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    CGFloat width = frame.size.width;
    CGFloat cellHeight = CHBeautyView_IconWidth + CHBeautyView_SGap + CHBeautyView_sliderHeight + self.gap;

    for (NSUInteger i = 0; i < self.sliderArray.count; i++)
    {
        BMImageTextView *titleIconView = [self.titleIconArray bm_safeObjectAtIndex:i];
        titleIconView.bm_origin = CGPointMake(CHBeautyView_LeftGap, i*cellHeight + self.gap);

        UILabel *lable = [self.lableArray bm_safeObjectAtIndex:i];
        lable.bm_origin = CGPointMake(width - CHBeautyView_LeftGap - CHBeautyView_LabelWidth, i*cellHeight + self.gap);

        UISlider *slider = [self.sliderArray bm_safeObjectAtIndex:i];
        slider.frame = CGRectMake(CHBeautyView_LeftGap, titleIconView.bm_bottom + CHBeautyView_SGap, width - CHBeautyView_LeftGap*2, CHBeautyView_sliderHeight);
    }
    
    frame.size.height = cellHeight*self.sliderArray.count + self.gap;
    
    [super setFrame:frame];
}

- (void)setBeautySetModel:(CHBeautySetModel *)beautySetModel
{
    _beautySetModel = beautySetModel;
    
    for (UISlider * slider in self.sliderArray)
    {
        switch (slider.tag)
        {
            // 美白值
            case 1:
                slider.value = self.beautySetModel.whitenValue;
                break;
            
//            // 瘦脸值
//            case 2:
//                slider.value = self.beautySetModel.thinFaceValue;
//                break;
//
//            // 大眼值
//            case 3:
//                slider.value = self.beautySetModel.bigEyeValue;
//                break;
//
//            // 磨皮值
//            case 4:
//                slider.value = self.beautySetModel.exfoliatingValue;
//                break;
//
//            // 红润值
//            case 5:
//                slider.value = self.beautySetModel.ruddyValue;
//                break;
                
                // 磨皮值
            case 2:
                slider.value = self.beautySetModel.exfoliatingValue;
                break;
                
                // 红润值
            case 3:
                slider.value = self.beautySetModel.ruddyValue;
                break;
                
            default:
                break;
        }
        
        UILabel *label = self.lableArray[slider.tag - 1];
        label.text = [NSString stringWithFormat:@"%@ %%", @(slider.value*100)];
    }
}

- (void)clearBeautyValues
{
    self.beautySetModel.whitenValue = self.beautySetModel.exfoliatingValue = self.beautySetModel.ruddyValue = 0.0f;
    
    self.beautySetModel = self.beautySetModel;
}


#pragma mark - slider事件

- (void)progressSliderTouchBegan:(UISlider *)slider
{
    
}

// slider滑动中事件
- (void)progressSliderValueChanged:(UISlider *)slider
{
    NSNumber *value = [NSNumber numberWithFloat:100.0f * slider.value];
    
    UILabel *label = self.lableArray[slider.tag - 1];
    
    label.text = [NSString stringWithFormat:@"%@ %%", @(value.integerValue)];
}

// slider结束滑动事件
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    switch (slider.tag)
    {
        // 美白值
        case 1:
            self.beautySetModel.whitenValue = slider.value;
            break;
        /*
        // 瘦脸值
        case 2:
            self.beautySetModel.thinFaceValue = slider.value;
            break;
           
        // 大眼值
        case 3:
            self.beautySetModel.bigEyeValue = slider.value;
            break;
            
        // 磨皮值
        case 4:
            self.beautySetModel.exfoliatingValue = slider.value;
            break;
            
        // 红润值
        case 5:
            self.beautySetModel.ruddyValue = slider.value;
            break;
         */
            // 磨皮值
            case 2:
                self.beautySetModel.exfoliatingValue = slider.value;
                break;
                
            // 红润值
            case 3:
                self.beautySetModel.ruddyValue = slider.value;
                break;
         
        default:
            break;
    }
}

@end
