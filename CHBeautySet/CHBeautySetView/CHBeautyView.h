//
//  CHBeautyView.h
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHBeautySetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHBeautyView : UIView

/// 美颜数据
@property (nonatomic, weak) CHBeautySetModel *beautySetModel;

/// 美颜开关
@property (nonatomic, assign) BOOL beautySwitch;

- (instancetype)initWithFrame:(CGRect)frame itemGap:(CGFloat)gap;

- (void)clearBeautyValues;

@end

NS_ASSUME_NONNULL_END
