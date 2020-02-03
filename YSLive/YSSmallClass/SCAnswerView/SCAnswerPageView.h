//
//  SCAnswerPageView.h
//  YSLive
//
//  Created by fzxm on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// pageAction 1=left 2=right
typedef void (^SCAnswerPageViewBlock)(NSUInteger currentPage ,NSInteger pageAction);
@interface SCAnswerPageView : UIView
/// 是否可以翻页
@property (nonatomic, assign) BOOL allowPaging;
/// 左右翻页的回调
@property (nonatomic, copy) SCAnswerPageViewBlock pageBlock;

/// 初始化 当前页以及总页数
/// @param total 总页数
/// @param currentPage 当前页
- (void)scAnswer_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage;
@end

NS_ASSUME_NONNULL_END
