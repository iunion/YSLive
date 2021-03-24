//
//  YSPassWordAlert.m
//  YSLive
//
//  Created by fzxm on 2019/10/23.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSPassWordAlert.h"

#define ViewWidth       (306)
#define ViewHeight      (210)
#define ViewBottomGap   (60)

@interface YSPassWordAlert ()
<
    UITextFieldDelegate
>

@property (nonatomic, strong) UIView *bacView;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UITextField *passWordField;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *sureBtn;

/// 确定按钮的回调
@property (nonatomic, copy) NoticeViewSureBtnClicked sureBtnBlock;

@end

@implementation YSPassWordAlert
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.showAnimationType = BMNoticeViewShowAnimationSlideInFromBottom;
        self.noticeMaskBgEffectView.alpha = 0.8;
        self.noticeMaskBgEffect = nil;//[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
//        self.noticeMaskBgColor = [UIColor clearColor];
    }
    return self;
}

+ (void)showPassWordInputAlerWithTopDistance:(CGFloat)topDistance inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets sureBlock:(NoticeViewSureBtnClicked)clicked dismissBlock:(BMNoticeViewDismissBlock)dismissBlock
{
    YSPassWordAlert * alert = [[YSPassWordAlert alloc] init];
    alert.sureBtnBlock = clicked;
    //alert.shouldDismissOnTapOutside = NO;
    
    alert.topDistance = topDistance;
    alert.backgroundEdgeInsets = backgroundEdgeInsets;
    alert.bacView.bm_size = CGSizeMake(ViewWidth, ViewHeight);
    [alert.bacView bm_roundedRect:18];

    [alert.bacView addSubview:alert.titleL];
    alert.titleL.bm_size = CGSizeMake(150, 20);
    alert.titleL.bm_centerX = alert.bacView.bm_centerX;
    alert.titleL.bm_top = alert.bacView.bm_top + 30;

    [alert.bacView addSubview:alert.msgLabel];
    alert.msgLabel.bm_height = 14;
    alert.msgLabel.bm_width = ViewWidth - 48 - 48;
    alert.msgLabel.bm_top = alert.titleL.bm_bottom + 20;
    alert.msgLabel.bm_left = alert.bacView.bm_left + 48;
    
    [alert.bacView addSubview:alert.passWordField];
    alert.passWordField.bm_height = 30;
    alert.passWordField.bm_width = ViewWidth - 48 - 48;
    alert.passWordField.bm_left = alert.msgLabel.bm_left;
    alert.passWordField.bm_top = alert.msgLabel.bm_bottom + 20;
    
    [alert.bacView addSubview:alert.lineView];
    alert.lineView.bm_height = 1;
    alert.lineView.bm_width = ViewWidth - 48 - 48;
    alert.lineView.bm_left = alert.passWordField.bm_left;
    alert.lineView.bm_top = alert.passWordField.bm_bottom + 5;

    [alert.bacView addSubview:alert.sureBtn];
    alert.sureBtn.bm_height = 32;
    alert.sureBtn.bm_width = ViewWidth - 60 - 60;
    alert.sureBtn.bm_centerX = alert.bacView.bm_centerX;
    alert.sureBtn.bm_bottom = alert.bacView.bm_bottom - 28;
    
    [alert.sureBtn bm_roundedRect:15];
    
    [alert showWithView:alert.bacView inView:inView showBlock:nil dismissBlock:dismissBlock];
    [alert.passWordField becomeFirstResponder];
}

- (void)sureBtn:(UIButton *)btn
{
    if (self.sureBtnBlock)
    {
        self.sureBtnBlock(self.passWordField.text);
    }
    [self dismiss:btn];
}

- (void)secureBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.passWordField.secureTextEntry = !btn.selected;
}


#pragma mark -
#pragma mark Lazy

- (UIView *)bacView
{
    if (!_bacView)
    {
        _bacView = [[UIView alloc] init];
        _bacView.backgroundColor = [UIColor whiteColor];
    }
    
    return _bacView;
}

- (UILabel *)titleL
{
    if (!_titleL)
    {
        _titleL = [[UILabel alloc] init];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.font = [UIFont systemFontOfSize:21];
        _titleL.textColor = [UIColor bm_colorWithHex:0x282828];
        _titleL.text = YSLocalized(@"Prompt.prompt");// @"提示";
    }

    return _titleL;
}

- (UILabel *)msgLabel
{
    if (!_msgLabel)
    {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 13);
        _msgLabel.textColor = [UIColor bm_colorWithHex:0x282828];
        _msgLabel.text = YSLocalized(@"Error.NeedPwd");// @"房间需要密码，请输入";
    }
    
    return _msgLabel;
}

- (UITextField *)passWordField
{
    if (!_passWordField)
    {
        _passWordField = [[UITextField alloc] init];
        _passWordField.textAlignment = NSTextAlignmentLeft;
        _passWordField.textColor = [UIColor bm_colorWithHex:0x282828];
        _passWordField.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
        _passWordField.placeholder = YSLocalized(@"Prompt.inputPlaceholder");// @"请输入房间密码";
        _passWordField.rightViewMode = UITextFieldViewModeAlways;
        _passWordField.secureTextEntry = YES;
        _passWordField.delegate = self;
        
        UIButton * secureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [secureBtn addTarget:self action:@selector(secureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        secureBtn.frame = CGRectMake(10, 10, 30, 30);
        [secureBtn setImage:YSSkinElementImage(@"passwordAlert", @"iconNor") forState:UIControlStateNormal];
        [secureBtn setImage:YSSkinElementImage(@"passwordAlert", @"iconSel") forState:UIControlStateSelected];
        _passWordField.rightView = secureBtn;
        _passWordField.clearsOnBeginEditing = NO;
    }
       
    return _passWordField;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor bm_colorWithHex:0xBFBFBF];
    }
    
    return _lineView;
}

- (UIButton *)sureBtn
{
    if (!_sureBtn)
    {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setTitle:YSLocalized(@"Prompt.OK") forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureBtn setBackgroundColor:[UIColor bm_colorWithHex:0x0177FF]];
        [_sureBtn addTarget:self action:@selector(sureBtn:) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    
    return _sureBtn;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{

    NSString *allStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField.isSecureTextEntry==YES)
    {
        textField.text= allStr;
        return NO;
    }
    return YES;
}

@end
