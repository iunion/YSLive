//
//  YSEyeCareVC.m
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSEyeCareVC.h"
#import "YSEyeCareManager.h"
#import "YSSlider.h"
#import "LMJDropdownMenu.h"

@interface YSEyeCareVC ()
<
    LMJDropdownMenuDataSource,
    LMJDropdownMenuDelegate
>

@property (nonatomic, strong) YSSlider *sliderView;
@property (nonatomic, strong) UILabel *brightnessLabel;

@end

@implementation YSEyeCareVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bm_NavigationItemTintColor = [UIColor whiteColor];
    self.bm_NavigationTitleTintColor = [UIColor whiteColor];
    [self bm_setNavigationWithTitle:YSLocalized(@"EyeProtection.Btnsetup") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:nil rightToucheEvent:nil];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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


- (void)setupUI
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH-40.0f, 50.0f)];
    label1.text = YSLocalized(@"EyeProtection.Title");
    label1.font = UI_FONT_18;
    label1.numberOfLines = 0;
    label1.textColor = [UIColor bm_colorWithHex:0x828282];
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    [label1 bm_centerHorizontallyInSuperViewWithTop:kBMScale_H(60.0f)];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.exclusiveTouch = YES;
    switchView.onTintColor = [UIColor bm_colorWithHex:0x97B7EB];
    switchView.on = [[YSEyeCareManager shareInstance] getEyeCareModeStatus];
    [switchView addTarget:self action:@selector(switchValueDidChange:) forControlEvents:UIControlEventValueChanged];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140.0f, switchView.bm_height)];
    [view addSubview:switchView];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0f, view.bm_height)];
    label2.text = YSLocalized(@"EyeProtection.Open");
    label2.font = UI_FONT_18;
    label2.textColor = [UIColor bm_colorWithHex:0x828282];
    [view addSubview:label2];
    label2.bm_left = switchView.bm_right + 6.0f;
    CGFloat width = [label2 bm_labelSizeToFitHeight:label2.bm_height].width;
    label2.bm_width = width;
    view.bm_width = switchView.bm_width + 6.0f + width;

    [self.view addSubview:view];
    [view bm_centerHorizontallyInSuperViewWithTop:label1.bm_bottom+kBMScale_H(20.0f)];

    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH-40.0f, 50.0f)];
    label3.text = YSLocalized(@"EyeProtection.NightTitle");
    label3.font = UI_FONT_18;
    label3.numberOfLines = 0;
    label3.textColor = [UIColor bm_colorWithHex:0x828282];
    label3.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label3];
    [label3 bm_centerHorizontallyInSuperViewWithTop:view.bm_bottom + kBMScale_H(50.0f)];

    UISwitch *switchView1 = [[UISwitch alloc] init];
    switchView1.exclusiveTouch = YES;
    switchView1.onTintColor = [UIColor bm_colorWithHex:0x97B7EB];
    switchView1.on = [[YSEyeCareManager shareInstance] getEyeCareNeverRemind];
    [switchView1 addTarget:self action:@selector(switch1ValueDidChange:) forControlEvents:UIControlEventValueChanged];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140.0f, switchView.bm_height)];
    [view1 addSubview:switchView1];
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0f, view.bm_height)];
    label6.text = YSLocalized(@"EyeProtection.NeverRemind");
    label6.font = UI_FONT_18;
    label6.textColor = [UIColor bm_colorWithHex:0x828282];
    [view1 addSubview:label6];
    label6.bm_left = switchView1.bm_right + 6.0f;
    width = [label6 bm_labelSizeToFitHeight:label6.bm_height].width;
    label6.bm_width = width;
    view1.bm_width = switchView1.bm_width + 6.0f + width;

    [self.view addSubview:view1];
    [view1 bm_centerHorizontallyInSuperViewWithTop:label3.bm_bottom+kBMScale_H(10.0f)];
    
    YSSlider *sliderView = [[YSSlider alloc] initWithFrame:CGRectMake(0, 0, kBMScale_W(200.0f), 24.0f)];
    [sliderView addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    sliderView.maximumValue = 100.0f;
    sliderView.minimumValue = 0.0f;
    sliderView.tintColor = [UIColor bm_colorWithHex:0x97B7EB];
    [sliderView setThumbImage:[UIImage imageNamed:@"eyecareslider"] forState:UIControlStateNormal];
    [self.view addSubview:sliderView];
    [sliderView bm_centerHorizontallyInSuperViewWithTop:view1.bm_bottom + kBMScale_H(20.0f)];
    sliderView.value = ceil([UIScreen mainScreen].brightness * 100);

    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BMUI_SCREEN_WIDTH-40.0f, 40.0f)];
    label4.text = [NSString stringWithFormat:@"%@: %@%%", YSLocalized(@"EyeProtection.ScreenBrightness"), @(ceil([UIScreen mainScreen].brightness * 100))];
    label4.font = UI_FONT_14;
    label4.textColor = [UIColor bm_colorWithHex:0x828282];
    label4.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4];
    [label4 bm_centerHorizontallyInSuperViewWithTop:sliderView.bm_bottom + kBMScale_H(10.0f)];
    self.brightnessLabel = label4;
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400.0f, 40.0f)];
    label5.text = YSLocalized(@"EyeProtection.Period");
    label5.font = UI_FONT_18;
    label5.textColor = [UIColor bm_colorWithHex:0x828282];
    [self.view addSubview:label5];
    width = [label5 bm_labelSizeToFitHeight:label5.bm_height].width;
    label5.bm_width = width+120.0f+4.0f;
    [label5 bm_centerHorizontallyInSuperViewWithTop:label4.bm_bottom + kBMScale_H(50.0f)];

    LMJDropdownMenu *menu = [[LMJDropdownMenu alloc] init];
    [menu setFrame:CGRectMake(0, 0, 120.0f, 40.0f)];
    menu.dataSource = self;
    menu.delegate   = self;
    
    menu.layer.borderColor  = [UIColor bm_colorWithHex:0x828282].CGColor;
    menu.layer.borderWidth  = 1.0f;
    menu.layer.cornerRadius = 6.0f;
    
    //menu.title = @"Please Select";
    menu.titleFont = [UIFont boldSystemFontOfSize:18];
    menu.titleColor = [UIColor bm_colorWithHex:0x828282];
    menu.titleBgColor = [UIColor whiteColor];
    
    menu.rotateIcon = [[UIImage imageNamed:@"eyecarearrow"] bm_imageWithTintColor:[UIColor bm_colorWithHex:0x828282]];
    menu.rotateIconSize = CGSizeMake(15, 15);

    menu.optionBgColor = [UIColor clearColor];
    menu.optionFont = [UIFont systemFontOfSize:16];
    menu.optionTextColor = [UIColor bm_colorWithHex:0x828282];
    menu.optionLineColor = [UIColor bm_colorWithHex:0xDDDDDD];
    menu.optionSelectedTextColor = [UIColor bm_colorWithHex:0x5A8CDC];
    NSUInteger index = [[YSEyeCareManager shareInstance] getEyeCareModeRemindTime];
    if (index == 60)
    {
        index = 1;
    }
    else
    {
        index = 0;
    }
    [menu resetSelectedAtIndex:index];
    menu.bm_top = label5.bm_top;
    menu.bm_right = label5.bm_right;

    [self.view addSubview:menu];
    
#if 0
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScale_W(200.0f), 50)];
    [btn setTitle:YSLocalized(@"Prompt.OK") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    btn.titleLabel.font = UI_FONT_18;
    [btn bm_roundedRect:25.0f borderWidth:4.0f borderColor:[UIColor bm_colorWithHex:0x9DB7E7]];
    btn.backgroundColor = [UIColor bm_colorWithHex:0x648CD6];
    [btn addTarget:self action:@selector(onClickOk:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn bm_centerInSuperView];
    btn.bm_bottom = self.view.bm_height-btn.bm_height-kScale_H(60.0f);
#endif
}

- (void)switchValueDidChange:(UISwitch *)switchView
{
    [[YSEyeCareManager shareInstance] switchEyeCareWithWindowMode:switchView.isOn];
}

- (void)switch1ValueDidChange:(UISwitch *)switchView
{
    [[YSEyeCareManager shareInstance] setEyeCareNeverRemind:switchView.isOn];
}

- (void)sliderValueDidChange:(UISlider *)sliderView
{
    NSInteger brightness = ceil(sliderView.value);
    self.brightnessLabel.text = [NSString stringWithFormat:@"%@: %@%%", YSLocalized(@"EyeProtection.ScreenBrightness"), @(brightness)];
    [[UIScreen mainScreen] setBrightness:brightness*0.01];
}

- (void)onClickOk:(UIButton*)sender
{
    [self backAction:nil];
}

#pragma mark - LMJDropdownMenu DataSource

- (NSUInteger)numberOfOptionsInDropdownMenu:(LMJDropdownMenu *)menu
{
    return 2;
}

- (CGFloat)dropdownMenu:(LMJDropdownMenu *)menu heightForOptionAtIndex:(NSUInteger)index
{
    return 40.0f;
}

- (NSString *)dropdownMenu:(LMJDropdownMenu *)menu titleForOptionAtIndex:(NSUInteger)index
{
    switch (index)
    {
        case 0:
            return YSLocalized(@"EyeProtection.Period.30");
            
        case 1:
            return YSLocalized(@"EyeProtection.Period.60");

        default:
            return YSLocalized(@"EyeProtection.Period.30");
    }
}

#pragma mark - LMJDropdownMenu Delegate

- (void)dropdownMenu:(LMJDropdownMenu *)menu didSelectOptionAtIndex:(NSUInteger)index optionTitle:(NSString *)title
{
    switch (index)
    {
        case 0:
            [[YSEyeCareManager shareInstance] setEyeCareModeRemindTime:30];
            break;
            
        case 1:
            [[YSEyeCareManager shareInstance] setEyeCareModeRemindTime:60];
            break;

        default:
            [[YSEyeCareManager shareInstance] setEyeCareModeRemindTime:30];
            break;
    }
}

@end
