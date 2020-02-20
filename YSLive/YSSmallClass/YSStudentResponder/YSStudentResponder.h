//
//  YSStudentResponder.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/20.
//  Copyright © 2020 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSStudentResponder : BMNoticeView
@property (nonatomic, strong, readonly) UILabel *titleL;
- (void)showInView:(UIView *)inView
    backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
        topDistance:(CGFloat)topDistance;
- (void)setTitleName:(NSString *)title;
- (void)setProgress:(CGFloat)progress;
@end

NS_ASSUME_NONNULL_END
