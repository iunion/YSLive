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
        self.startTime = [dic bm_doubleForKey:@"starttime"];
    }
    /// 结束时间: endtime 格式2018-05-09 16:30:00
    if ([dic bm_containsObjectForKey:@"endtime"])
    {
        self.endTime = [dic bm_doubleForKey:@"endtime"];
    }
    
    /// 当前状态: buttonstatus 0未开始 1进教室 2去评价 回放 3回放
    self.classState = [dic bm_uintForKey:@"classState"];
    if (self.classState > YSClassState_Begin )
    {
        self.classState = YSClassState_End;
    }
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

- (CGFloat)calculateMediumCellHeight
{
    CGFloat height = self.classReplayList.count * (YSClassReplayView_Height+YSClassReplayView_Gap);
    
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
    
    NSString *linkUrl = [dic bm_stringTrimForKey:@"linkUrl"];
    if (![linkUrl bm_isNotEmpty])
    {
        return;
    }
    
    self.linkUrl = linkUrl;
    
    self.title = [dic bm_stringTrimForKey:@"title"];
    self.during = [dic bm_stringTrimForKey:@"during"];
    self.size = [dic bm_stringTrimForKey:@"size"];
}


@end
