//
//  YSInputView.m
//  YSEdu
//
//  Created by fzxm on 2019/10/10.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import "YSInputView.h"

@interface YSInputView()<UITextFieldDelegate>
/// 底部视图容器
@property (nonatomic, strong) UIView *bacView;
/// icon
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation YSInputView

- (instancetype)initWithFrame:(CGRect)frame withPlaceholder:(NSString *)placeholder withImageName:(NSString *)imageName
{

    if (self = [super initWithFrame:frame])
    {
        _bacView = [[UIView alloc] init];
        [self addSubview:_bacView];
        [self sendSubviewToBack:_bacView];
        
        _iconImageView = [[UIImageView alloc] init];
        [self addSubview:_iconImageView];
        
        _inputTextField = [[UITextField alloc] init];
        [self addSubview:_inputTextField];
        [_inputTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor bm_colorWithHex:0x333333 alpha:0.5f];
        [self addSubview:_lineView];
        [self setViewWithPlaceholderText:placeholder setImageName:imageName];
    }
    return self;
}

- (void)setViewWithPlaceholderText:(NSString *)placeholder setImageName:(NSString *)imageName
{
    _bacView.backgroundColor = [UIColor clearColor];
//    _bacView.layer.cornerRadius = 20;
//    _bacView.layer.masksToBounds = YES;
    
    if (placeholder)
    {
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
            NSForegroundColorAttributeName:YSColor_LoginPlaceholder,
            NSFontAttributeName:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 15)
        }];
        _inputTextField.attributedPlaceholder = attrString;
    }
    
    _inputTextField.textColor = [UIColor whiteColor];
    _inputTextField.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 15);
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputTextField.delegate = self;
    _inputTextField.tintColor = YSColor_LoginTextField;
    _inputTextField.enabled = YES;
    
    _iconImageView.image = [UIImage imageNamed:imageName];
    _iconImageView.contentMode = UIViewContentModeCenter;
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
    
    _bacView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    _iconImageView.frame = CGRectMake(25, 0, 15,CGRectGetHeight(_bacView.frame));
    
    _inputTextField.frame = CGRectMake(CGRectGetMaxX(_iconImageView.frame)+ 18, 0, CGRectGetWidth(_bacView.frame) - 70, CGRectGetHeight(_bacView.frame));
    _lineView.frame = CGRectMake(0, CGRectGetMaxY(_bacView.frame), self.frame.size.width, 1);
    
}


#pragma mark  -- TextFieldDelegate

- (void)textFieldDidChanged:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(inpuTextFieldDidChanged:)])
    {
        [self.delegate inpuTextFieldDidChanged:textField];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    // 准备开始输入 文本字段将成为第一响应者
    _bacView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    //剪切边界 如果视图上的子视图layer超出视图layer部分就截取掉 如果添加阴影这个属性必须是NO 不然会把阴影切掉
    _bacView.layer.masksToBounds = NO;
    //阴影半径，默认3
    _bacView.layer.shadowRadius = 3;
    //shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    _bacView.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
    // 阴影透明度，默认0
    _bacView.layer.shadowOpacity = 0.5f;

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _bacView.layer.masksToBounds = YES;
}

@end
