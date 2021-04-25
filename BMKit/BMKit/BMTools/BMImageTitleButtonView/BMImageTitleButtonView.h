//
//  BMImageTitleButtonView.h
//  YSAll
//
//  Created by jiang deng on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMImageTitleButtonViewType)
{
    BMImageTitleButtonView_ImageTop,
    BMImageTitleButtonView_ImageBottom
};


@interface BMImageTitleButtonView : UIControl

@property (nonatomic, assign) BMImageTitleButtonViewType type;

@property (nullable, nonatomic, strong) UIImage *normalImage;
@property (nullable, nonatomic, strong) UIImage *selectedImage;
@property (nullable, nonatomic, strong) UIImage *disabledImage;

@property (nullable, nonatomic, strong) UIColor *textNormalColor;
@property (nullable, nonatomic, strong) UIColor *textSelectedColor;
@property (nullable, nonatomic, strong) UIColor *textDisabledColor;
@property (nullable, nonatomic, strong) NSString *normalText;
@property (nullable, nonatomic, strong) NSString *selectedText;
@property (nullable, nonatomic, strong) NSString *disabledText;

@property (nullable, nonatomic, strong) NSAttributedString *normalAttributedText;
@property (nullable, nonatomic, strong) NSAttributedString *selectedAttributedText;
@property (nullable, nonatomic, strong) NSAttributedString *disabledAttributedText;

@property (nullable, nonatomic, strong) UIFont *textFont;

@property (nonatomic, assign) CGFloat imageTextGap;
@property (nonatomic, assign) CGFloat textGap;

@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) BOOL textAdjustsFontSizeToFitWidth;
@property (nonatomic, assign) CGFloat textMinimumScaleFactor;

@end

NS_ASSUME_NONNULL_END
