//
//  YSCalendarCurriculumVC.m
//  YSAll
//
//  Created by 迁徙鸟 on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSCalendarCurriculumVC.h"
#import "AppDelegate.h"
#import "FSCalendar.h"
#import "YSCalendarCell.h"
#import "YSClassDayList.h"

#import "FSCalendarCollectionView.h"

#import "YSLiveApiRequest.h"

@interface YSCalendarCurriculumVC ()
<
FSCalendarDataSource,
FSCalendarDelegate,
FSCalendarDelegateAppearance
>

@property (weak, nonatomic) FSCalendar *MyCalendar;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (copy, nonatomic) NSString *nowDateStr;

/// 课表日历数据请求
@property (nonatomic, strong) NSURLSessionDataTask *calendarDataTask;

@property (strong, nonatomic) NSMutableDictionary *dateDict;

@end

@implementation YSCalendarCurriculumVC


- (NSMutableDictionary *)dateDict
{
    if (!_dateDict) {
        self.dateDict = [NSMutableDictionary dictionary];
    }
    return _dateDict;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    
    self.bm_NavigationTitleTintColor = UIColor.whiteColor;
    self.bm_NavigationItemTintColor = UIColor.whiteColor;
    
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.Calendar") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:nil leftToucheEvent:nil rightItemTitle:nil rightItemImage:[UIImage imageNamed:@"onlineSchool_refresh"] rightToucheEvent:@selector(getCalendarDatas)];
    self.title = nil;
    
    [self setupUI];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    self.nowDateStr = [dateFormatter stringFromDate:currentDate];

    [self getCalendarDatas];
}

#warning 测试代码先不要删
- (void)backAction:(id)sender
{
    [GetAppDelegate logoutOnlineSchool];
}

#pragma mark - 获取学生课程列表当月数据
- (void)getCalendarDatas
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
    
    [self.calendarDataTask cancel];
    self.calendarDataTask = nil;
    
    AFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    
    YSUserRoleType schoolUserType = [YSSchoolUser shareInstance].userRoleType;
    NSString * userId = [YSSchoolUser shareInstance].userId;
    NSString * organId = [YSSchoolUser shareInstance].organId;
    
    NSMutableURLRequest *request = [YSLiveApiRequest getClassListWithUserId:userId WithOrganId:organId WithUserType:schoolUserType Withdate:self.nowDateStr];

    if (request)
    {
        BMWeakSelf
        self.calendarDataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (error)
            {
                [weakSelf.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
            else
            {
                [self.progressHUD bm_hideAnimated:NO];
                
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                if ([responseDic bm_isNotEmptyDictionary])
                {
                    
                    NSInteger statusCode = [responseDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (statusCode == YSSuperVC_StatusCode_Succeed)
                    {
                        NSArray * allDate = [responseDic bm_arrayForKey:@"data"];
                        
                        NSString * month = [weakSelf.nowDateStr substringToIndex:7];
                        if ([allDate bm_isNotEmpty])
                        {
                            for (NSArray * arr in allDate)
                            {
                                for (NSDictionary * dict in arr)
                                {
                                    if ([[dict bm_stringForKey:@"timestr"] containsString:month] && ([dict bm_uintForKey:@"num"]>0 || [[dict bm_stringForKey:@"timestr"] isEqualToString:weakSelf.nowDateStr]))
                                    {
                                        [weakSelf.dateDict setValue:dict[@"num"] forKey:dict[@"timestr"]];
                                    }
                                }
                            }
                            [weakSelf.MyCalendar reloadData];
                            return;
                        }
                    }
                    else
                    {
                        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLocalized(@"Error.ServerError")];
                        if ([weakSelf checkRequestStatus:statusCode message:message responseDic:responseDic])
                        {
                            [weakSelf.progressHUD bm_hideAnimated:NO];
                        }
                        else
                        {
                            [weakSelf.progressHUD bm_showAnimated:NO withText:message delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
                        }
                        return;
                    }
                }
                [weakSelf.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
        }];
        [self.calendarDataTask resume];
    }
    else
    {
         [self.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

//UI
- (void)setupUI
{
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(10,  50, self.view.frame.size.width-20, 400)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.swipeToChooseGesture.enabled = NO;
    calendar.allowsMultipleSelection = NO;
    [self.view addSubview:calendar];
    calendar.scrollEnabled = NO;
    self.MyCalendar = calendar;
    calendar.backgroundColor = UIColor.whiteColor;
    calendar.layer.cornerRadius = 16;
    
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[YSCalendarCell class] forCellReuseIdentifier:@"cell"];
    
    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
    [calendar addGestureRecognizer:scopeGesture];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    calendar.locale = locale;  // 设置周次是中文显示
    calendar.placeholderType = FSCalendarPlaceholderTypeFillHeadTail; //月份模式时，只显示当前月份
    calendar.firstWeekday = 2;     //设置周一为第一天
    calendar.headerHeight = 60.0f;
    
    [self.MyCalendar selectDate:[NSDate date] scrollToDate:NO];
    self.MyCalendar.accessibilityIdentifier = @"calendar";
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date])
    {
        return @"今";
    }
    return nil;
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date
{
    
    return UIColor.whiteColor;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"点击的date %@",date);
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSString * dateString = [self.dateFormatter stringFromDate:date];
    
    if ([[self.dateDict allKeys] containsObject:dateString] && [self.dateDict bm_uintForKey:dateString]>0)
    {
        YSClassDayList *classVC = [[YSClassDayList alloc] init];
        classVC.selectedDate = date;
        classVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:classVC animated:YES];
    }
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    YSCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition
{
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

- (void)configureVisibleCells
{
    [self.MyCalendar.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [self.MyCalendar dateForCell:obj];
        FSCalendarMonthPosition position = [self.MyCalendar monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}

- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    YSCalendarCell *diyCell = (YSCalendarCell *)cell;
    
    NSString *dateString = [date bm_stringWithFormat:@"yyyy-MM-dd"];
    if ([[self.dateDict allKeys] containsObject:dateString])
    {
        diyCell.dateDict = @{dateString:self.dateDict[dateString]};
    }
    else
    {
        diyCell.dateDict = nil;
    }
}


@end
