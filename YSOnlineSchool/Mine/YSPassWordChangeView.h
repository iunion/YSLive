//
//  YSPassWordChangeView.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/8.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSPassWordChangeViewDelegate <NSObject>

- (void)inpuTextFieldDidChanged:(UITextField *)textField;

@end


@interface YSPassWordChangeView : UIView

@property (nonatomic, weak) id <YSPassWordChangeViewDelegate> delegate;
@property (nonatomic, strong) UITextField * inputTextField;

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title placeholder:(NSString *)placeholder;

@end


NS_ASSUME_NONNULL_END
