//
//  YSCalendarCurriculumVC.m
//  YSAll
//
//  Created by 迁徙鸟 on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSCalendarCurriculumVC.h"
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
@property (strong, nonatomic) NSDate *nowDate;
@property (copy, nonatomic) NSString *nowDateStr;

/// 课表日历数据请求
@property (nonatomic, strong) NSURLSessionDataTask *calendarDataTask;

@property (strong, nonatomic) NSMutableDictionary *dateDict;

@end

@implementation YSCalendarCurriculumVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    
    self.bm_NavigationTitleTintColor = UIColor.whiteColor;
    self.bm_NavigationItemTintColor = UIColor.whiteColor;
    
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.Calendar") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:nil leftToucheEvent:nil rightItemTitle:nil rightItemImage:[UIImage imageNamed:@"onlineSchool_refresh"] rightToucheEvent:@selector(refreshBtnClick)];
    self.title = nil;
    
    [self setupUI];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    self.nowDateStr = [dateFormatter stringFromDate:currentDate];
    
    NSDictionary *dict = @{
        @"2020-02-02":@"共1节课",
        @"2020-02-05":@"共3节课",
        self.nowDateStr:@"共4节课",
        @"2020-02-15":@"共3节课",
        @"2020-02-25":@"共2节课",
    };
    
    self.dateDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [self getCalendarDatas];
}

- (void)getCalendarDatas
{
    BMWeakSelf
    [YSLiveApiRequest getCalendarCalendarWithdate:self.nowDateStr success:^(NSDictionary * _Nonnull calendarDict) {
        
        if ([calendarDict bm_isNotEmpty]) {
            NSArray * array = [calendarDict bm_arrayForKey:@"chargeinfo"];
            if (array.count) {
                for (NSDictionary * dict in array) {
                    NSString * keyStr = [dict bm_stringForKey:@"timestr"];
                    NSString * num = [dict bm_stringForKey:@"num"];
                    if ([keyStr bm_isNotEmpty] && [num bm_isNotEmpty])
                    {
                        NSString * value = [NSString stringWithFormat:@"共%@节",num];
                        
                        [weakSelf.dateDict setValue:value forKey:keyStr];
                    }
                }
                [self.MyCalendar reloadData];
            }
        }
        
    } failure:^(NSInteger errorCode,NSString *errorStr) {
        
        BMLog(@"errorCode = %ld,errorStr = %@",errorCode,errorStr);
        
        
    }];
}

//刷新
- (void)refreshBtnClick
{
//    NSDate *currentDate = [NSDate date];//获取当前时间，日期
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
//    dateFormatter.dateFormat = @"yyyy-MM-dd";
//    NSString * nowDateStr = [dateFormatter stringFromDate:currentDate];
//
//    self.dateDict = @{
//        @"2020-02-03":@"共1节课",
//        @"2020-02-04":@"共3节课",
//        nowDateStr:@"共4节课",
//        @"2020-02-17":@"共3节课",
//        @"2020-02-27":@"共2节课",
//    };
    [self getCalendarDatas];
    
        
//    [self.MyCalendar reloadData];
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupUI
{
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY 年 MM 月 "];//设定时间格式,这里可以设置成自己需要的格式
//    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    NSString * nowDateStr = [self.dateFormatter stringFromDate:currentDate];
    
    self.nowDate = [self.dateFormatter dateFromString:nowDateStr];
    
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
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date
{
    return UIColor.grayColor;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"点击的date %@",date);
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    BMLog(@"点击的date %@",[self.dateFormatter stringFromDate:date]);    
    
    NSString * dateString = [self.dateFormatter stringFromDate:date];
    
    if ([[self.dateDict allKeys] containsObject:dateString]) {
        
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
    
//    NSString * dateString = [self.dateFormatter stringFromDate:date];
//
//    if ([[self.dateDict allKeys] containsObject:dateString]) {
//
//        diyCell.dateDict = @{dateString:self.dateDict[dateString]};
//    }
}
//- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
//{
//    return monthPosition == FSCalendarMonthPositionCurrent;
//}
//
//- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
//{
//    return monthPosition == FSCalendarMonthPositionCurrent;
//}


@end
