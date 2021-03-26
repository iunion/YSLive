//
//  CHBeautyView.h
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHBeautyView : UIView

/// 美白属性值
@property(nonatomic,assign,readonly) CGFloat whitenValue;

/// 瘦脸属性值
@property(nonatomic,assign,readonly) CGFloat thinFaceValue;

/// 大眼属性值
@property(nonatomic,assign,readonly) CGFloat bigEyeValue;

/// 磨皮属性值
@property(nonatomic,assign,readonly) CGFloat exfoliatingValue;

/// 红润属性值
@property(nonatomic,assign,readonly) CGFloat ruddyValue;

- (void)clearBeautyValues;

@end

NS_ASSUME_NONNULL_END
