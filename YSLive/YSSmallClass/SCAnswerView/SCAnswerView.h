//
//  SCAnswerView.h
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SCAnswerViewType)
{
    /// 答题中
    SCAnswerViewType_AnswerIng,
    /// 统计
    SCAnswerViewType_Statistics,
    /// 详情
    SCAnswerViewType_Details,

};

typedef void (^SCAnswerViewFirstSubmitBlock)(NSArray *submitArr);
typedef void (^SCAnswerViewNextSubmitBlock)(NSArray *addAnwserResault,NSArray *delAnwserResault,NSArray *notChangeAnwserResault);
@interface SCAnswerView : BMNoticeView
@property (nonatomic, strong) NSArray *dataSource;
/// 单选 多选
@property (nonatomic, assign) BOOL isSingle;
/// 第一次提交答案的回调
@property (nonatomic, copy) SCAnswerViewFirstSubmitBlock firstSubmitBlock;
/// 修改答案的回调
@property (nonatomic, copy) SCAnswerViewNextSubmitBlock nextSubmitBlock;


/// 设置答题结果数据
/// @param staticsDic 答题统计
/// @param detailArr 答题详情
/// @param duration 答题时间
/// @param myResult 我的答案
/// @param rightOption 正确答案
/// @param totalUsers 答题人数
- (void)setAnswerResultWithStaticsDic:(NSDictionary *)staticsDic
                            detailArr:(NSArray *)detailArr
                             duration:(NSString *)duration
                             myResult:(NSArray *)myResult
                          rightOption:(NSString *)rightOption
                           totalUsers:(NSUInteger)totalUsers;

- (void)showWithAnswerViewType:(SCAnswerViewType)answerViewType
                                  inView:(UIView *)inView
                    backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                             topDistance:(CGFloat)topDistance;
@end

NS_ASSUME_NONNULL_END
