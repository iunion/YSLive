//
//  YSInputView.h
//  YSEdu
//
//  Created by fzxm on 2019/10/10.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSInputViewDelegate;

@interface YSInputView : UIView

@property (nonatomic, weak) id <YSInputViewDelegate> delegate;

@property (nonatomic, strong) UITextField * inputTextField;

- (instancetype)initWithFrame:(CGRect)frame withPlaceholder:(NSString *)placeholder withImageName:(NSString *)imageName;

@end

@protocol YSInputViewDelegate <NSObject>

- (void)inpuTextFieldDidChanged:(UITextField *)textField;

@optional


@end

NS_ASSUME_NONNULL_END
