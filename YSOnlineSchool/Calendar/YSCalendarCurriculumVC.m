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
#import "YSClassOneDayVC.h"

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

@property (strong, nonatomic) NSDictionary *dateDict;


@end

@implementation YSCalendarCurriculumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor colorWithRed:132 green:174 blue:246 alpha:1.0];
    self.view.backgroundColor = UIColor.grayColor;
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = @"我的课表";
    titleLab.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:titleLab];
    
    [self setupUI];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString * nowDateStr = [dateFormatter stringFromDate:currentDate];
    NSDate * nowDate = [dateFormatter dateFromString:nowDateStr];
    
    self.dateDict = @{
        @"2020-02-02":@"共1节课",
        @"2020-02-05":@"共3节课",
        nowDateStr:@"共4节课",
        @"2020-02-15":@"共3节课",
        @"2020-02-25":@"共2节课",
    };
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
    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    NSString * nowDateStr = [self.dateFormatter stringFromDate:currentDate];
    
    self.nowDate = [self.dateFormatter dateFromString:nowDateStr];
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(10,  80, self.view.frame.size.width-20, 400)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.swipeToChooseGesture.enabled = YES;
    calendar.allowsMultipleSelection = NO;
    [self.view addSubview:calendar];
    calendar.scrollEnabled = NO;
    self.MyCalendar = calendar;
    calendar.backgroundColor = UIColor.whiteColor;
    calendar.layer.cornerRadius = 30;
    
//    calendar.calendarHeaderView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
//    calendar.calendarWeekdayView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
//    calendar.appearance.eventSelectionColor = [UIColor redColor];
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[YSCalendarCell class] forCellReuseIdentifier:@"cell"];
    
    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
    [calendar addGestureRecognizer:scopeGesture];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    calendar.locale = locale;  // 设置周次是中文显示
    calendar.placeholderType = FSCalendarPlaceholderTypeFillHeadTail; //月份模式时，只显示当前月份
    calendar.firstWeekday = 2;     //设置周一为第一天
    //    calendar.appearance.headerDateFormat = @"yyyy年MM月";
//    calendar.appearance.titleTodayColor = [UIColor redColor];
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
    NSLog(@"点击的date %@",[self.dateFormatter stringFromDate:date]);
    [self configureVisibleCells];
//    FSCalendarCell *cell = [calendar cellForDate:date atMonthPosition:monthPosition];
    
    
    NSString * dateString = [self.dateFormatter stringFromDate:date];
    
    if ([[self.dateDict allKeys] containsObject:dateString]) {
        
        YSClassOneDayVC * classVC = [[YSClassOneDayVC alloc]init];
        NSString * dateString = [self.dateFormatter stringFromDate:date];
        classVC.selectDate = [self.dateFormatter dateFromString:dateString];
        [self.navigationController pushViewController:classVC animated:YES];
    }
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
//    YSClassOneDayVC * classVC = [[YSClassOneDayVC alloc]init];
//    NSString * dateString = [self.dateFormatter stringFromDate:date];
//    classVC.selectDate = [self.dateFormatter dateFromString:dateString];
//    [self.navigationController pushViewController:classVC animated:YES];
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
    
    NSString * dateString = [self.dateFormatter stringFromDate:date];
    
    if ([[self.dateDict allKeys] containsObject:dateString]) {
        
//        NSString * num = self.dateDict[dateString];
        
        diyCell.dateDict = @{dateString:self.dateDict[dateString]};
        
        
//        diyCell.selectionLayer.hidden = NO;
//        NSDate * dateKey = [self.dateFormatter dateFromString:dateString];
//
//        //日期比较
//        NSComparisonResult result = [dateKey compare:self.nowDate];
//        if (result == -1)
//        {//之前
//            diyCell.selectionLayer.fillColor = UIColor.yellowColor.CGColor;
//        }
//        else if (result == 1)
//        {//以后
//            diyCell.selectionLayer.fillColor = UIColor.greenColor.CGColor;
//        }
//        else
//        {//今天
//            diyCell.selectionLayer.fillColor = UIColor.purpleColor.CGColor;
//        }
//
//        diyCell.circleLab.text = [self.dateDict objectForKey:dateString];
//        [diyCell bringSubviewToFront:diyCell.circleLab];//不起作用
//    }
//    else
//    {
//        diyCell.selectionLayer.hidden = YES;
    }
}
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return monthPosition == FSCalendarMonthPositionCurrent;
}



- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return monthPosition == FSCalendarMonthPositionCurrent;
}


@end
