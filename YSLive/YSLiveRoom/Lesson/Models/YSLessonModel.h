//
//  YSLessonModel.h
//  YSLive
//
//  Created by fzxm on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//通知类型
typedef NS_ENUM(NSUInteger, YSLessonNotifyType)
{
    /// 公告
    YSLessonNotifyType_Message,
    /// 通知
    YSLessonNotifyType_Status,
};

@interface YSLessonModel : NSObject

/// 房间号
@property (nonatomic, strong) NSString *roomId;
/// 课堂名字
@property (nonatomic, strong) NSString * name;
/// 课堂名字高度
@property (nonatomic, assign) CGFloat nameHeight;
/// 开始时间
@property (nonatomic, strong) NSString *publishTime;
//
///// 结束时间
//@property (nonatomic, strong) NSString * endTime;

/// 通知详情
@property (nonatomic, strong) NSString * details;
/// 通知详情文字高度
@property (nonatomic, assign) CGFloat detailsHeight;
/// 通知详情(翻译后)
@property (nonatomic, strong) NSString * detailTrans;
/// 通知详情文字高度(翻译后)
@property (nonatomic, assign) CGFloat translatHeight;

/// 通知类型
@property (nonatomic, assign) YSLessonNotifyType notifyType;

/// 是否展开
@property (nonatomic, assign) BOOL isOpen;



@end

NS_ASSUME_NONNULL_END
