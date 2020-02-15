//
//  YSClassModel.m
//  YSAll
//
//  Created by jiang deng on 2020/2/7.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassModel.h"

@implementation YSClassModel

+ (instancetype)classModelWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return nil;
    }
    
    /// 课程id: curriculumid
    NSString *classId = [dic bm_stringTrimForKey:@"curriculumid"];
    if (![classId bm_isNotEmpty])
    {
        return nil;
    }
    
    YSClassModel *classModel = [[YSClassModel alloc] init];
    [classModel updateWithServerDic:dic];
    
    if ([classModel.classId bm_isNotEmpty])
    {
        return classModel;
    }
    else
    {
        return nil;
    }
}

- (void)updateWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return;
    }

    /// 课程id: curriculumid
    NSString *classId = [dic bm_stringTrimForKey:@"curriculumid"];
    if (![classId bm_isNotEmpty])
    {
        return;
    }
    self.classId = classId;

    /// 标题: coursename
    if ([dic bm_containsObjectForKey:@"coursename"])
    {
        self.title = [dic bm_stringTrimForKey:@"coursename"];
    }
    /// 老师姓名: teachername
    if ([dic bm_containsObjectForKey:@"teachername"])
    {
        self.teacherName = [dic bm_stringTrimForKey:@"teachername"];
    }
    else if ([dic bm_containsObjectForKey:@"nickname"])
    {
        self.teacherName = [dic bm_stringTrimForKey:@"nickname"];
    }

    /// 课程主题: periodname
    if ([dic bm_containsObjectForKey:@"periodname"])
    {
        self.classGist = [dic bm_stringTrimForKey:@"periodname"];
    }
    /// 课程图标: imageurl
     if ([dic bm_containsObjectForKey:@"imageurl"])
    {
        self.classImage = [dic bm_stringTrimForKey:@"imageurl"];
    }

    /// 开始时间: starttime 格式2018-05-09 16:30:00
    if ([dic bm_containsObjectForKey:@"starttime"])
    {
        NSString *dateStr = [dic bm_stringTrimForKey:@"starttime"];
        self.startTimeStr = dateStr;
        NSDate *date = [NSDate bm_dateFromString:dateStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.startTime = [date timeIntervalSince1970];
    }
    /// 结束时间: endtime 格式2018-05-09 16:30:00
    if ([dic bm_containsObjectForKey:@"endtime"])
    {
        NSString *dateStr = [dic bm_stringTrimForKey:@"endtime"];
        self.endTimeStr = dateStr;
        NSDate *date = [NSDate bm_dateFromString:dateStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.endTime = [date timeIntervalSince1970];
    }

    /// toteachid id = 1854;
    if ([dic bm_containsObjectForKey:@"toteachid"])
    {
        self.toTeachId = [dic bm_stringTrimForKey:@"toteachid"];
    }
    else if ([dic bm_containsObjectForKey:@"id"])
    {
        self.toTeachTimeId = [dic bm_stringTrimForKey:@"id"];
        self.toTeachId = self.toTeachTimeId;
    }

    /// lessonsid = 1564;
    if ([dic bm_containsObjectForKey:@"lessonsid"])
    {
        self.lessonsId = [dic bm_stringTrimForKey:@"lessonsid"];
    }

    /// 当前状态: buttonstatus 0未开始 1进教室 2去评价 回放 3回放
    /// classstatus
    if ([dic bm_containsObjectForKey:@"buttonstatus"])
    {
        self.classState = [dic bm_uintForKey:@"buttonstatus"];
    }
    else if ([dic bm_containsObjectForKey:@"status"])
    {
        self.classState = [dic bm_uintForKey:@"status"];
    }
    if (self.classState > YSClassState_Begin )
    {
        self.classState = YSClassState_End;
    }
    
    self.classDic = dic;
}

@end


@implementation YSClassDetailModel

+ (instancetype)classDetailModelWithServerDic:(NSDictionary *)dic
{
    return [YSClassDetailModel classDetailModelWithServerDic:dic linkClass:nil];
}

+ (instancetype)classDetailModelWithServerDic:(NSDictionary *)dic linkClass:(YSClassModel *)linkClass
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return nil;
    }
    
    /// 课程id
    NSString *classId = [dic bm_stringTrimForKey:@"classId"];
    if (![classId bm_isNotEmpty])
    {
        return nil;
    }
    
    YSClassDetailModel *classDetailModel = [[YSClassDetailModel alloc] init];
    classDetailModel.linkClassModel = linkClass;
    [classDetailModel updateWithServerDic:dic];
    
    if ([classDetailModel.classId bm_isNotEmpty])
    {
        return classDetailModel;
    }
    else
    {
        return nil;
    }
}

- (void)updateWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return;
    }

    [super updateWithServerDic:dic];
    
    if (![self.classId bm_isNotEmpty])
    {
        return;
    }

    self.classInstruction = [dic bm_stringTrimForKey:@"classInstruction"];

    if ([dic bm_containsObjectForKey:@"classReplayList"])
    {
        self.classReplayList = [[NSMutableArray alloc] init];
        NSArray *replayList = [dic bm_arrayForKey:@"classReplayList"];
        for (NSDictionary *dic in replayList)
        {
            YSClassReviewModel *classReviewModel = [YSClassReviewModel classReviewModelWithServerDic:dic];
            if (classReviewModel)
            {
                [self.classReplayList addObject:classReviewModel];
            }
        }
    }
    
    if (self.linkClassModel)
    {
        // 状态
        self.linkClassModel.classState = self.classState;
    }
}

- (CGFloat)calculateInstructionTextCellHeight
{
    CGFloat height = [self.classInstruction bm_heightToFitWidth:(UI_SCREEN_WIDTH-15.0f*2.0f) withFont:[UIFont systemFontOfSize:12.0f]];
    
    return height+50.0f+10.0f;
}

//- (CGFloat)calculateMediumCellHeight
//{
//    CGFloat height = self.classReplayList.count * (YSClassReplayView_Height+YSClassReplayView_Gap);
//    
//    return height+45.0f+5.0f;
//}

@end

@implementation YSClassReplayListModel

+ (instancetype)classReplayListModelWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return nil;
    }
    
    YSClassReplayListModel *classReplayListModel = [[YSClassReplayListModel alloc] init];
    [classReplayListModel updateWithServerDic:dic];
    
    return classReplayListModel;
}

- (void)updateWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return;
    }
    
    /// 课节名称: lessonsname
    self.lessonsName = [dic bm_stringTrimForKey:@"lessonsname"];

    /// 课程回放列表: video
    NSArray *videoArray = [dic bm_arrayForKey:@"video"];
    NSMutableArray *classReplayList = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in videoArray)
    {
        if ([dic bm_isNotEmptyDictionary])
        {
            YSClassReviewModel *classReviewModel = [YSClassReviewModel classReviewModelWithServerDic:dic];
            if (classReviewModel)
            {
                [classReplayList addObject:classReviewModel];
            }
        }
    }
    if ([classReplayList bm_isNotEmpty])
    {
        self.classReplayList = classReplayList;
    }
}

- (CGFloat)calculateMediumCellHeight
{
    CGFloat height = YSClassReplayView_NoDateHeight;
    if ([self.classReplayList bm_isNotEmpty])
    {
        height = self.classReplayList.count * (YSClassReplayView_Height+YSClassReplayView_Gap);
    }
    
    return height+45.0f+5.0f;
}

@end

@implementation YSClassReviewModel

+ (instancetype)classReviewModelWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return nil;
    }
    
    YSClassReviewModel *classModel = [[YSClassReviewModel alloc] init];
    [classModel updateWithServerDic:dic];
    
    if ([classModel.linkUrl bm_isNotEmpty])
    {
        return classModel;
    }
    else
    {
        return nil;
    }
}

- (void)updateWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return;
    }
    
    /// 链接: https_playpath
    NSString *linkUrl = [dic bm_stringTrimForKey:@"https_playpath"];
    if (![linkUrl bm_isNotEmpty])
    {
        return;
    }
    
    self.linkUrl = linkUrl;
    
    /// 标题编号: part
    self.part = [dic bm_stringTrimForKey:@"part" withDefault:@""];
    
    /// 时长: duration
    NSString *duration = [dic bm_stringTrimForKey:@"duration"];
    NSUInteger hour = 0;
    NSUInteger minute = 0;
    NSUInteger second = 0;
    NSUInteger location = 0;
    NSRange rang = [duration rangeOfString:@"时"];
    if (rang.location != NSNotFound && rang.location > location)
    {
        NSRange hrang = NSMakeRange(location, rang.location-location);
        NSString *hs = [duration substringWithRange:hrang];
        
        hour = [hs integerValue];
        location = rang.location + 1;
    }
    
    rang = [duration rangeOfString:@"分"];
    if (rang.location != NSNotFound && rang.location > location)
    {
        NSRange mrang = NSMakeRange(location, rang.location-location);
        NSString *ms = [duration substringWithRange:mrang];
        
        minute = [ms integerValue];
        location = rang.location + 1;
    }

    rang = [duration rangeOfString:@"秒"];
    if (rang.location != NSNotFound && rang.location > location)
    {
        NSRange srang = NSMakeRange(location, rang.location-location);
        NSString *ss = [duration substringWithRange:srang];
        
        second = [ss integerValue];
    }
    minute = minute + hour*60;

    self.duration = [NSString stringWithFormat:@"%@'%@''", @(minute), @(second)];
    /// 存储大小: size
    double size = [dic bm_doubleForKey:@"size"];
    NSArray *tokens = [NSArray arrayWithObjects:@"B", @"K", @"M", @"G", @"T", nil];
    self.size = [NSString bm_storeStringWithBitSize:size tokens:tokens];
}


@end
