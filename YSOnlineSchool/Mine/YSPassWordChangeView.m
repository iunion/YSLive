//
//  YSPassWordChangeView.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/8.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSPassWordChangeView.h"
@interface YSPassWordChangeView()
<
    UITextFieldDelegate
>

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation YSPassWordChangeView

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title placeholder:(NSString *)placeholder
{
    if (self = [super initWithFrame:frame])
    {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.textColor = YSSkinOnlineDefineColor(@"placeholderColor");
        self.titleLabel = titleLabel;
        [self addSubview:self.titleLabel];
        self.titleLabel.text = title;
        

        
        _inputTextField = [[UITextField alloc] init];
        [_inputTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        if (placeholder)
        {
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
                NSForegroundColorAttributeName:[UIColor bm_colorWithHex:0xC3C3C3],
                NSFontAttributeName:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 14)
            }];
            _inputTextField.attributedPlaceholder = attrString;
        }
        _inputTextField.backgroundColor = [UIColor whiteColor];
        _inputTextField.textColor = YSColor_LoginTextField;
        _inputTextField.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 14);
        _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputTextField.secureTextEntry = YES;
        _inputTextField.delegate = self;
        _inputTextField.tintColor = YSColor_LoginTextField;
        _inputTextField.enabled = YES;
        
        _inputTextField.layer.cornerRadius = 20;
        _inputTextField.layer.masksToBounds = YES;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 40)];
        _inputTextField.leftView = view;
        _inputTextField.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview:self.inputTextField];
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(10, 10, 100, 20);
    _inputTextField.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame) + 10, 0, self.bm_width - self.titleLabel.bm_right - 10 - 40, 40);
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
