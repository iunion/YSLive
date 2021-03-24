//
//  LHDiceAnimationView.h
//  LHDiceAnimation
//
//  Created by ma c on 2018/6/11.
//  Copyright © 2018年 LIUHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSDiceAnimationView : UIView

/// 结束时的随机数字
@property(nonatomic, assign) NSInteger resultNum;

/// 结束时的随机数字
@property(nonatomic, strong) NSString *nickName;

/// 开始动画
- (void)diceBegainAnimals;

@end
