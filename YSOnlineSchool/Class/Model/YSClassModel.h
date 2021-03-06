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
    YSClassState_Begin,
    
    YSClassState_End
};

#define YSClassReplayView_Height        (60.0f)
#define YSClassReplayView_Gap           (15.0f)
#define YSClassReplayView_NoDateHeight  (30.0f)

NS_ASSUME_NONNULL_BEGIN

@class YSClassReviewModel;
@interface YSClassModel : NSObject

// {"code":0,"data":{"data":[{"organid":1,"curriculumid":566,"gradename":"\u9093\u8001\u5e08\u5f00\u8bfe\u4e86","starttime":"2020-02-10 22:00:00","endtime":"2020-02-10 23:40:00","schedulingid":710,"intime":"2020-02-10","timekey":"44,45,46,47","coursename":"\u9093\u8001\u5e08\u5f00\u8bfe\u4e86","type":2,"teacherid":332,"toteachid":1781,"periodname":"\u9093\u8001\u5e08\u5f00\u8bfe\u4e860","periodsort":0,"classhour":null,"lessonsid":1491,"imageurl":"","generalize":"<p>\u9093\u8001\u5e08\u5f00\u8bfe\u4e86<\/p>","teachername":"\u9093\u8001\u5e08","buttonstatus":2,"organname":"\u4e91\u67a2\u7f51\u6821\u673a\u6784\u540e\u53f0"}],"pageinfo":{"pagesize":20,"pagenum":1,"total":1}},"info":"\u64cd\u4f5c\u6210\u529f"}

//{
//    classstatus = 0;
//    courseimage = "";
//    coursename = "\U9093\U8001\U5e08\U76f4\U64ad";
//    curriculumid = 581;
//    endtime = "2020-02-15 14:00:00";
//    hourslong = "00:10";
//    id = 1854;
//    lessonsid = 1564;
//    nickname = "\U9093\U8001\U5e08";
//    periodname = "\U9093\U8001\U5e08\U76f4\U64ad0";
//    periodsort = 0;
//    schedulingid = 725;
//    starttime = "2020-02-15 13:50:00";
//    status = 1;
//    statusinfo = "\U67e5\U770b";
//    sum = 1;
//    teacherid = 343;
//    type = 3;
//}

/// 课程id: curriculumid
@property (nonatomic, strong) NSString *classId;

/// 标题: coursename
@property (nonatomic, strong) NSString *title;
/// 老师姓名: teachername nickname
@property (nonatomic, strong) NSString *teacherName;
/// 课程主题: periodname
@property (nonatomic, strong) NSString *classGist;
/// 课程图标: imageurl
@property (nonatomic, strong) NSString *classImage;

/// 服务器当前时间
//@property (nonatomic, assign) NSTimeInterval currentTime;
/// 开始时间: starttime 格式2018-05-09 16:30:00
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, strong) NSString *startTimeStr;
/// 结束时间: endtime 格式2018-05-09 16:30:00
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, strong) NSString *endTimeStr;

/// toteachid
@property (nonatomic, strong) NSString *toTeachId;

/// id = 1854;
@property (nonatomic, strong) NSString *toTeachTimeId;

/// lessonsid = 1564;
@property (nonatomic, strong) NSString *lessonsId;


/// 当前状态: buttonstatus 0未开始 1进教室 2去评价 回放 3回放 classstatusß
@property (nonatomic, assign) YSClassState classState;

@property (nonatomic, strong) NSDictionary *classDic;

+ (nullable instancetype)classModelWithServerDic:(NSDictionary *)dic;
- (void)updateWithServerDic:(NSDictionary *)dic;

@end


@interface YSClassDetailModel : YSClassModel

// 相关联课程列表数据
@property (nonatomic, weak) YSClassModel *linkClassModel;

/// 课程简介
@property (nonatomic, strong) NSString *classInstruction;

/// 课程回放列表
@property (nonatomic, strong) NSMutableArray <YSClassReviewModel *> *classReplayList;


+ (nullable instancetype)classDetailModelWithServerDic:(NSDictionary *)dic;
+ (nullable instancetype)classDetailModelWithServerDic:(NSDictionary *)dic linkClass:(nullable YSClassModel *)linkClass;
- (void)updateWithServerDic:(NSDictionary *)dic;

- (CGFloat)calculateInstructionTextCellHeight;
//- (CGFloat)calculateMediumCellHeight;

@end

@interface YSClassReplayListModel : NSObject

/// 课节名称: lessonsname
@property (nonatomic, strong) NSString *lessonsName;

/// 课程回放列表: video
@property (nonatomic, strong) NSMutableArray <YSClassReviewModel *> *classReplayList;

+ (nullable instancetype)classReplayListModelWithServerDic:(NSDictionary *)dic;
- (void)updateWithServerDic:(NSDictionary *)dic;

- (CGFloat)calculateMediumCellHeight;

@end

@interface YSClassReviewModel : NSObject

/// 标题编号: part
@property (nonatomic, strong) NSString *part;
/// 时长: duration
@property (nonatomic, strong) NSString *duration;
/// 存储大小: size
@property (nonatomic, strong) NSString *size;

/// 链接: https_playpath
@property (nonatomic, strong) NSString *linkUrl;

+ (nullable instancetype)classReviewModelWithServerDic:(NSDictionary *)dic;
- (void)updateWithServerDic:(NSDictionary *)dic;

@end


//{
//        "code": "成功的时候返回0,失败或者异常返回其他",
//        "data": {
//                "teachername": "老师名称",
//                "starttime": "上课时间",
//                "lessonsname": "课节名称",
//                "video": {
//                        "playpath": "视频片段url",
//                        "https_playpath": "视频https片段",
//                        "duration": "时长时分秒",
//                        "part": "片段编号1,2"
//                }
//        },
//        "info": "成功的时候返回操作成功,失败或者异常返回其他"
//}

NS_ASSUME_NONNULL_END
