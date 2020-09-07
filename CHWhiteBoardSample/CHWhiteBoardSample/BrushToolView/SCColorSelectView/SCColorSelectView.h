//
//  SCColorSelectView.h
//  YSLive
//
//  Created by fzxm on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCColorSelectView : UIView

@property (nonatomic, copy) void(^chooseBackBlock)(NSString * colorStr);

+ (NSArray *)colorArray;

- (void)setCurrentSelectColor:(NSString *)curColor;

@end

NS_ASSUME_NONNULL_END
