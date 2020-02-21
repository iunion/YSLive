//
//  YSStudentTimerView.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/21.
//  Copyright © 2020 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSStudentTimerView : BMNoticeView
- (void)showYSStudentTimerViewInView:(UIView *)inView
                backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                         topDistance:(CGFloat)topDistance;
- (void)showTimeInterval:(NSInteger)timeInterval;
@end

NS_ASSUME_NONNULL_END
