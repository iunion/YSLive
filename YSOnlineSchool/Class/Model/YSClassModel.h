//
//  YSClassModel.h
//  YSAll
//
//  Created by jiang deng on 2020/2/7.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 课程状态
typedef NS_ENUM(NSUInteger, YSClassState)
{
    YSClassState_Waiting,
    YSClassState_Beging,
    
    YSClassState_End
};

NS_ASSUME_NONNULL_BEGIN

@interface YSClassModel : NSObject

/// 课程id
@property (nonatomic, strong) NSString *classId;

/// 标题
@property (nonatomic, strong) NSString *title;
/// 老师姓名
@property (nonatomic, strong) NSString *teacherName;
/// 课程主题
@property (nonatomic, strong) NSString *classGist;
/// 课程图标
@property (nonatomic, strong) NSString *classImage;

/// 服务器当前时间
//@property (nonatomic, assign) NSTimeInterval currentTime;
/// 开始时间
@property (nonatomic, assign) NSTimeInterval startTime;
/// 结束时间
@property (nonatomic, assign) NSTimeInterval endTime;

///// 可进入教室倒计时时间
//@property (nonatomic, assign) NSUInteger canEnterCountdown;
///// 课程开始倒计时时间
//@property (nonatomic, assign) NSUInteger startCountdown;
///// 课程最后结束倒计时时间
//@property (nonatomic, assign) NSUInteger endCountdown;

/// 当前状态
@property (nonatomic, assign) YSClassState classState;

///// 是否可进入教室
//@property (nonatomic, assign) BOOL canEnterClass;

+ (nullable instancetype)classModelWithServerDic:(NSDictionary *)dic;
- (void)updateWithServerDic:(NSDictionary *)dic;

@end

@interface YSClassDetailModel : YSClassModel

// 相关联课程列表数据
@property (nonatomic, weak) YSClassModel *linkClassModel;

/// 课程简介
@property (nonatomic, strong) NSString *classInstruction;

/// 课程回放列表
@property (nonatomic, strong) NSMutableArray <NSString *> *classReplayList;


+ (nullable instancetype)classDetailModelWithServerDic:(NSDictionary *)dic;
+ (nullable instancetype)classDetailModelWithServerDic:(NSDictionary *)dic linkClass:(nullable YSClassModel *)linkClass;
- (void)updateWithServerDic:(NSDictionary *)dic;

- (CGFloat)calculateInstructionTextCellHeight;

@end

NS_ASSUME_NONNULL_END
