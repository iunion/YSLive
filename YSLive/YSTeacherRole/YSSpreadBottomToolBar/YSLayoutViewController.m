//
//  YSLayoutViewController.m
//  YSAll
//
//  Created by 马迪 on 2020/12/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLayoutViewController.h"

#define Margin 2

#define BtnHeight 50

@interface YSLayoutViewController ()

@property (nonatomic, strong) UIView *backView;

@end

@implementation YSLayoutViewController


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
    {
        CGRect layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame;
        self.backView.frame = layoutFrame;
    }
    else
    {
        self.backView.frame = self.view.frame;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    
    self.backView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backView.backgroundColor = UIColor.purpleColor;
    self.backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backView];
    
    [self setupUI];
    
}

- (void)setupUI
{
    [self.backView bm_removeAllSubviews];
    
    //综合布局
    self.aroundLayoutBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") image:YSSkinElementImage(@"videoPop_soundButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_soundButton", @"iconSel")];
    self.aroundLayoutBtn.frame = CGRectMake(0, 0, self.view.bm_width, BtnHeight);
    self.aroundLayoutBtn.disabledImage = YSSkinElementImage(@"videoPop_soundButton", @"iconDis");
    self.aroundLayoutBtn.disabledText = YSLocalized(@"Button.MutingAudio");
    self.aroundLayoutBtn.tag = SCVideoViewControlTypeAudio;
//    self.aroundLayoutBtn.enabled = YES;
    [self.backView addSubview:self.aroundLayoutBtn];
    [self.aroundLayoutBtn setBackgroundColor:UIColor.redColor];
    
    //平铺布局
    self.videoLayoutBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") image:YSSkinElementImage(@"videoPop_soundButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_soundButton", @"iconSel")];
    self.videoLayoutBtn.frame = CGRectMake(0, BtnHeight, self.view.bm_width, BtnHeight);
    self.videoLayoutBtn.disabledImage = YSSkinElementImage(@"videoPop_soundButton", @"iconDis");
    self.videoLayoutBtn.disabledText = YSLocalized(@"Button.MutingAudio");
    self.videoLayoutBtn.tag = SCVideoViewControlTypeAudio;
//    self.videoLayoutBtn.enabled = YES;
    [self.backView addSubview:self.videoLayoutBtn];
    
    //双师布局
    self.doubleLayoutBtn = [self creatButtonWithTitle:YSLocalized(@"Button.OpenAudio") selectTitle:YSLocalized(@"Button.CloseAudio") image:YSSkinElementImage(@"videoPop_soundButton", @"iconNor") selectImage:YSSkinElementImage(@"videoPop_soundButton", @"iconSel")];
    self.doubleLayoutBtn.frame = CGRectMake(0, 2*BtnHeight, self.view.bm_width, BtnHeight);
    self.doubleLayoutBtn.disabledImage = YSSkinElementImage(@"videoPop_soundButton", @"iconDis");
    self.doubleLayoutBtn.disabledText = YSLocalized(@"Button.MutingAudio");
    self.doubleLayoutBtn.tag = SCVideoViewControlTypeAudio;
//    self.doubleLayoutBtn.enabled = YES;
    [self.backView addSubview:self.doubleLayoutBtn];
    
    self.view.frame = CGRectMake(0, 0, 80, BtnHeight *3);
    self.preferredContentSize = CGSizeMake(80, BtnHeight *3);
    
}

- (void)userBtnsClick:(UIButton *)sender
{
    NSLog(@"djjdjd");
}


///创建button
- (BMImageTitleButtonView *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle image:(UIImage *)image selectImage:(UIImage *)selectImage
{
    BMImageTitleButtonView * button = [[BMImageTitleButtonView alloc]init];
    button.userInteractionEnabled = YES;
    button.type = BMImageTitleButtonView_ImageTop;
    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
    button.textNormalColor = YSSkinDefineColor(@"defaultTitleColor");
    button.textFont= UI_FONT_10;
    button.normalText = title;
    
    if (selectTitle.length)
    {
        button.selectedText = selectTitle;
    }
    
    button.normalImage = image;
    if (selectImage)
    {
        button.selectedImage = selectImage;
    }
    return button;
}

///移动button上图片和文字的位置（图片在上，文字在下）
- (void)moveButtonTitleAndImageWithButton:(UIButton *)button
{
    CGFloat margin = 18;
    if ([UIDevice bm_isiPad])
    {
        margin = 13;
    }

    button.imageEdgeInsets = UIEdgeInsetsMake(0,margin, button.titleLabel.bounds.size.height + 10.0f, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(button.currentImage.size.width + 0.0f, -(button.currentImage.size.width), 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}


@end
