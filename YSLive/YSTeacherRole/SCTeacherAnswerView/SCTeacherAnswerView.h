//
//  SCTeacherAnswerView.h
//  YSLive
//
//  Created by fzxm on 2019/12/31.
//  Copyright © 2019 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SCTeacherAnswerViewType)
{
    /// 发布答题
    SCTeacherAnswerViewType_AnswerPub,
//    /// 答题中
//    SCTeacherAnswerViewType_AnswerING,
    /// 统计
    SCTeacherAnswerViewType_Statistics,
    /// 详情
    SCTeacherAnswerViewType_Details,

};

typedef void (^SCTeacherAnswerSubmit)(NSArray *submitArr);
typedef void (^SCTeacherAnswerGetDetail)(SCTeacherAnswerViewType type);
typedef void (^SCTeacherEndAnswer)(BOOL isOpen);
typedef void (^SCTeacherAgainAnswer)(void);

typedef void (^SCTeacherCloseAnswer)(BOOL isAnswerIng);

@interface SCTeacherAnswerView : BMNoticeView
/// 发布答题
@property (nonatomic, copy) SCTeacherAnswerSubmit submitBlock;
/// 获取答题详情
@property (nonatomic, copy) SCTeacherAnswerGetDetail detailBlock;
/// 结束答题
@property (nonatomic, copy) SCTeacherEndAnswer endBlock;
/// 重新开始答题
@property (nonatomic, copy) SCTeacherAgainAnswer againBlock;
/// 关闭
@property (nonatomic, copy) SCTeacherCloseAnswer closeBlock;

@property (nonatomic, assign) BOOL isAnswerIng;
/// 答题时间
@property (nonatomic, strong) NSString *timeStr;
/// 详情数据
@property (nonatomic, strong) NSArray *answerDetailArr;


- (void)showTeacherAnswerViewType:(SCTeacherAnswerViewType)answerViewType
                           inView:(UIView *)inView
             backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                      topDistance:(CGFloat)topDistance;

/// 答题中的数据传入
/// @param statisticsDic 统计数据
/// @param totalUsers 总人数
/// @param rightResult 正确答案
- (void)setAnswerStatistics:(NSDictionary *)statisticsDic totalUsers:(NSInteger)totalUsers rightResult:(NSString *)rightResult;
/// 答题结果
/// @param staticsDic 统计数据
/// @param detailArr 学生数据
/// @param duration 用时
/// @param rightOption 正确答案
- (void)setAnswerResultWithStaticsDic:(NSDictionary *)staticsDic detailArr:(NSArray *)detailArr duration:(NSString *)duration rightOption:(NSString *)rightOption totalUsers:(NSUInteger)totalUsers;
@end

NS_ASSUME_NONNULL_END
