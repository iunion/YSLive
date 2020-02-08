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
    
    /// 课程id
    NSString *classId = [dic bm_stringTrimForKey:@"classId"];
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

    /// 课程id
    NSString *classId = [dic bm_stringTrimForKey:@"classId"];
    if (![classId bm_isNotEmpty])
    {
        return;
    }
    self.classId = classId;

    /// 标题
    if ([dic bm_containsObjectForKey:@"title"])
    {
        self.title = [dic bm_stringTrimForKey:@"title"];
    }
    /// 老师姓名
    if ([dic bm_containsObjectForKey:@"teacherName"])
    {
        self.teacherName = [dic bm_stringTrimForKey:@"teacherName"];
    }
    /// 课程主题
    if ([dic bm_containsObjectForKey:@"classGist"])
    {
        self.classGist = [dic bm_stringTrimForKey:@"classGist"];
    }
    /// 课程图标
    if ([dic bm_containsObjectForKey:@"classImage"])
    {
        self.classImage = [dic bm_stringTrimForKey:@"classImage"];
    }

    /// 开始时间
    if ([dic bm_containsObjectForKey:@"startTime"])
    {
        self.startTime = [dic bm_doubleForKey:@"startTime"];
    }
    /// 结束时间
    if ([dic bm_containsObjectForKey:@"endTime"])
    {
        self.endTime = [dic bm_doubleForKey:@"endTime"];
    }

    /// 当前状态
    self.classState = [dic bm_uintForKey:@"classState"];
}

@end


@implementation YSClassDetailModel

+ (instancetype)classDetailModelWithServerDic:(NSDictionary *)dic
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
            NSString *replayUrl = [dic bm_stringTrimForKey:@"replay"];
            if (replayUrl)
            {
                [self.classReplayList addObject:replayUrl];
            }
        }
    }
}

@end
