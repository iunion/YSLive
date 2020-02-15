//
//  YSCircleProgress.h
//  YSAll
//
//  Created by jiang deng on 2020/2/15.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSCircleProgress : UIView

/// 进度
@property (nonatomic, assign) CGFloat progress;
/// 圈内颜色
@property (nonatomic, strong) UIColor *innerColor;

/// 圈线底色
@property (nonatomic, strong) UIColor *lineBgColor;
/// 圈线(进度)颜色
@property (nonatomic, strong) UIColor *lineProgressColor;

/// 宽度
@property (nonatomic, assign) CGFloat lineWidth;


@end

NS_ASSUME_NONNULL_END
