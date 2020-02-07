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

/// 开始时间
@property (nonatomic, assign) NSTimeInterval startTime;
/// 结束时间
@property (nonatomic, assign) NSTimeInterval endTime;

/// 当前状态
@property (nonatomic, assign) YSClassState classState;

+ (nullable instancetype)classModelWithServerDic:(NSDictionary *)dic;
- (void)updateWithServerDic:(NSDictionary *)dic;

@end

@interface YSClassDetailModel : YSClassModel

/// 课程简介
@property (nonatomic, strong) NSString *classInstruction;

/// 课程回放列表
@property (nonatomic, strong) NSMutableArray <NSString *> *classReplayList;


+ (nullable instancetype)classDetailModelWithServerDic:(NSDictionary *)dic;
- (void)updateWithServerDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
