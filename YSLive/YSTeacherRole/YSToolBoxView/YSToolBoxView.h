//
//  YSToolBoxView.h
//  YSLive
//
//  Created by fzxm on 2020/6/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YSToolBoxViewDelegate <NSObject>
- (void)closeToolBoxView;

@end


@interface YSToolBoxView : BMNoticeView

@property(nonatomic,weak) id<YSToolBoxViewDelegate> delegate;

- (void)showToolBoxViewInView:(UIView *)inView
                backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                         topDistance:(CGFloat)topDistance
                            userRole:(YSUserRoleType)roleType;
@end

NS_ASSUME_NONNULL_END
