//
//  YSTeacherResponder.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/18.
//  Copyright © 2020 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, YSTeacherResponderType)
{
    /// 发布抢答
    YSTeacherResponderType_Start,
    /// 抢答中
    YSTeacherResponderType_ING,
    /// 结果
    YSTeacherResponderType_Result,

};

@interface YSTeacherResponder : BMNoticeView
- (void)showYSTeacherResponderType:(YSTeacherResponderType)responderType
                            inView:(UIView *)inView
              backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                       topDistance:(CGFloat)topDistance;

@end

NS_ASSUME_NONNULL_END
