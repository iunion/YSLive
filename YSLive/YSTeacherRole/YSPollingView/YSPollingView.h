//
//  YSPollingView.h
//  YSLive
//
//  Created by 宁杰英 on 2020/3/24.
//  Copyright © 2020 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSPollingViewDelegate <NSObject>



@end

@interface YSPollingView : BMNoticeView

@property(nonatomic,weak) id<YSPollingViewDelegate> delegate;

- (void)showTeacherPollingViewInView:(UIView *)inView
                backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                         topDistance:(CGFloat)topDistance;

@end

NS_ASSUME_NONNULL_END
