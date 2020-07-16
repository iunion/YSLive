//
//  YSInputView.m
//  YSEdu
//
//  Created by fzxm on 2019/10/10.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import "YSInputView.h"

@interface YSInputView()<UITextFieldDelegate>

/// icon
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation YSInputView

- (instancetype)initWithFrame:(CGRect)frame withPlaceholder:(NSString *)placeholder withImage:(UIImage *)image
{
    if (self = [super initWithFrame:frame])
    {
        _iconImageView = [[UIImageView alloc] initWithImage:image];
        _iconImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconImageView];
        _iconImageView.hidden = YES;
        
        _inputTextField = [[UITextField alloc] init];
        [self addSubview:_inputTextField];
        [_inputTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        
        UIView * lineView = [[UIView alloc]init];
        lineView.backgroundColor = YSSkinDefineColor(@"login_lineColor");
        [self addSubview:lineView];
        self.lineView = lineView;
        
        [self setViewWithPlaceholderText:placeholder];
    }
    return self;
}

- (void)setViewWithPlaceholderText:(NSString *)placeholder
{
    if (placeholder)
    {
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
            NSForegroundColorAttributeName:YSSkinDefineColor(@"login_placeholderColor"),
            NSFontAttributeName:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 15)
        }];
        _inputTextField.attributedPlaceholder = attrString;
    }
    
    _inputTextField.textColor = YSColor_LoginTextField;
    _inputTextField.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 15);
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputTextField.delegate = self;
    _inputTextField.tintColor = YSColor_LoginTextField;
    _inputTextField.enabled = YES;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
        NSForegroundColorAttributeName:YSColor_LoginPlaceholder,
        NSFontAttributeName:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 15)
    }];
    _inputTextField.attributedPlaceholder = attrString;
}
- (void)layoutSubviews
{
    [super layoutSubviews];

//    _iconImageView.frame = CGRectMake(10, 0, 15,self.bm_height);
    
//    _inputTextField.frame = CGRectMake(CGRectGetMaxX(_iconImageView.frame)+ 18, 0, self.bm_width - 70, self.bm_height);
    _inputTextField.frame = CGRectMake(10, 0, self.bm_width - 20, self.bm_height);
    self.lineView.frame = CGRectMake(0, self.bm_height - 1.0, self.bm_width, 0.5);
}


#pragma mark  -- TextFieldDelegate

- (void)textFieldDidChanged:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(inpuTextFieldDidChanged:)])
    {
        [self.delegate inpuTextFieldDidChanged:textField];
    }
}


@end
