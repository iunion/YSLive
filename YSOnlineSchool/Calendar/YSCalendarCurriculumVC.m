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

#import "YSMonthListView.h"

@interface YSCalendarCurriculumVC ()
<
    FSCalendarDataSource,
    FSCalendarDelegate,
    FSCalendarDelegateAppearance,
    UIGestureRecognizerDelegate
>

@property (weak, nonatomic) FSCalendar *MyCalendar;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (copy, nonatomic) NSString *nowDateStr;

/// 课表日历数据请求
@property (nonatomic, strong) NSURLSessionDataTask *calendarDataTask;

@property (strong, nonatomic) NSMutableDictionary *dateDict;

///切换日期的UI----
@property (nonatomic, strong) UIButton *lastBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *monthBtn;

///可切换的月份数组
@property(nonatomic,strong)NSMutableArray *chooseDateArr;
///可切换的月份的弹出view
@property (nonatomic, strong) YSMonthListView * monthListTableView;


@end

@implementation YSCalendarCurriculumVC



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
    
    [self selectMonthUI];
    
    [self setupUI];
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    [self bringSomeViewToFront];
    
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

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectMonthUI
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    dateFormatter.dateFormat = @"yyyy MM月";
    NSString * month = [dateFormatter stringFromDate:currentDate];
    
    UIButton *monthBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bm_width - 113)/2, 23, 113, 26)];
    [monthBtn setBackgroundColor:UIColor.whiteColor];
    [monthBtn setImage:[UIImage imageNamed:@"onlineSchool_allMonth"] forState:UIControlStateNormal];
    [monthBtn setTitle:month forState:UIControlStateNormal];
    [monthBtn setTitleColor:[UIColor bm_colorWithHex:0x828282] forState:UIControlStateNormal];
    monthBtn.titleLabel.font = UI_FONT_16;
    monthBtn.layer.cornerRadius = 26/2;
    monthBtn.layer.masksToBounds = YES;
    [monthBtn addTarget:self action:@selector(monthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    monthBtn.tag = 2;
    [self.view addSubview:monthBtn];
    self.monthBtn = monthBtn;
    
    monthBtn.imageEdgeInsets = UIEdgeInsetsMake(0, monthBtn.frame.size.width - monthBtn.imageView.frame.origin.x - monthBtn.imageView.frame.size.width, 0, 0);
    monthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - monthBtn.imageView.frame.size.width-10, 0, 10);
    
    UIButton *lastBtn = [[UIButton alloc]init];
    [lastBtn setBackgroundColor:UIColor.whiteColor];
    [lastBtn setImage:[UIImage imageNamed:@"onlineSchool_lastNonth_normal"] forState:UIControlStateNormal];
    [lastBtn setImage:[UIImage imageNamed:@"onlineSchool_lastNonth_select"] forState:UIControlStateSelected];
    lastBtn.layer.cornerRadius = 26/2;
    lastBtn.layer.masksToBounds = YES;
    [lastBtn addTarget:self action:@selector(monthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    lastBtn.tag = 1;
    [self.view addSubview:lastBtn];
    self.lastBtn = lastBtn;
    
    UIButton *nextBtn = [[UIButton alloc]init];
    [nextBtn setBackgroundColor:UIColor.whiteColor];
    [nextBtn setImage:[UIImage imageNamed:@"onlineSchool_nextNonth_normal"] forState:UIControlStateNormal];
    [nextBtn setImage:[UIImage imageNamed:@"onlineSchool_nextNonth_select"] forState:UIControlStateSelected];
    nextBtn.layer.cornerRadius = 26/2;
    nextBtn.layer.masksToBounds = YES;
    [nextBtn addTarget:self action:@selector(monthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.tag = 3;
    [self.view addSubview:nextBtn];
    self.nextBtn = nextBtn;
        
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23);
        make.right.equalTo(monthBtn.mas_left).offset(-16);
        make.width.height.mas_equalTo(26);
    }];
    
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23);
        make.left.equalTo(monthBtn.mas_right).offset(16);
        make.width.height.mas_equalTo(26);
    }];
}

#pragma mark - 顶部三个按钮的点击事件
- (void)monthButtonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
        {//上个月
            [self hiddenTheMonthListTableView:YES];
            if (sender.selected) {
                return;
            }
            
            NSDate *currentMonth = self.MyCalendar.currentPage;
            NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
            [self.MyCalendar setCurrentPage:previousMonth animated:YES];

        }
            break;
        case 3:
        {//下个月
            
            [self hiddenTheMonthListTableView:YES];
            if (sender.selected) {
                return;
            }
            NSDate *currentMonth = self.MyCalendar.currentPage;
            NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
            [self.MyCalendar setCurrentPage:nextMonth animated:YES];
        }
            break;
        case 2:
        {//所有月份列表
            [self hiddenTheMonthListTableView:sender.selected];
        }
            break;
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hiddenTheMonthListTableView:YES];
}

//隐藏可切换的月份的弹出view
- (void)hiddenTheMonthListTableView:(BOOL)isHidden
{
    self.monthBtn.selected = !isHidden;
    BMWeakSelf
    if (isHidden) {
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.monthListTableView.bm_height = 0;
        }];
    }
    else
    {
      [UIView animateWithDuration:0.25 animations:^{
          weakSelf.monthListTableView.bm_height = self.chooseDateArr.count * 33 + 10;
        }];
    }
}


//UI
- (void)setupUI
{
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(10,  70, self.view.frame.size.width-20, 400)];
    calendar.dataSource = self;
    calendar.delegate = self;
    
    [self.view addSubview:calendar];
    self.MyCalendar = calendar;
    calendar.backgroundColor = UIColor.whiteColor;
    calendar.layer.cornerRadius = 16;
//    calendar.appearance.separators = FSCalendarSeparatorInterRows;
    calendar.swipeToChooseGesture.enabled = NO;
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[YSCalendarCell class] forCellReuseIdentifier:@"cell"];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    calendar.locale = locale;  // 设置周次是中文显示
    calendar.placeholderType = FSCalendarPlaceholderTypeNone; //月份模式时，只显示当前月份
    calendar.firstWeekday = 2;     //设置周一为第一天
    calendar.headerHeight = 60.0f;
    
    [self.MyCalendar selectDate:[NSDate date] scrollToDate:NO];
    self.MyCalendar.accessibilityIdentifier = @"calendar";
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(calendarViewClick)];
    tap.delegate = self;
    [self.MyCalendar.collectionView addGestureRecognizer:tap];
    
}
- (void)calendarViewClick
{
    [self hiddenTheMonthListTableView:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self.MyCalendar.collectionView)
    {
        if (self.monthListTableView.bm_height>0)
        {
            return YES;
        }
        return NO;
    }else {
        return YES;
    }
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

#pragma mark - 日历滚动的代理
- (void)calendarScrollViewWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSString stringWithFormat:@"yyyy MM%@",YSLocalizedSchool(@"Label.Title.Month")];
    NSString * dateStr = [formatter stringFromDate:date];
    [self.monthBtn setTitle:dateStr forState:UIControlStateNormal];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    formatter1.dateFormat = @"yyyy-MM";
    NSString * dateStr1 = [formatter1 stringFromDate:date];

    if ([self.chooseDateArr.firstObject containsString:dateStr1])
    {
        self.lastBtn.selected = YES;
        self.nextBtn.selected = NO;
    }
    else if ([self.chooseDateArr.lastObject containsString:dateStr1])
    {
        self.lastBtn.selected = NO;
        self.nextBtn.selected = YES;
    }
    else
    {
        self.lastBtn.selected = NO;
        self.nextBtn.selected = NO;
    }
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
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"点击的date %@",date);
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


#pragma mark - <FSCalendarDataSource>

//可选择的最小日期
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    
    NSDate * date = [NSDate bm_dateFromString:self.chooseDateArr.firstObject withFormat:@"yyyy-MM-dd"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/DD";
    NSString * string = [formatter stringFromDate:date];
    
    return [self.dateFormatter dateFromString:string];
}

//可选择的最大日期
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    
    NSDate * date = [NSDate bm_dateFromString:self.chooseDateArr.lastObject withFormat:@"yyyy-MM-dd"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/DD";
    NSString * string = [formatter stringFromDate:date];
    
    return [self.dateFormatter dateFromString:string];
}

- (NSMutableArray *)chooseDateArr
{
    if (!_chooseDateArr) {
        
        NSArray * arr = @[@"2019-11-20",@"2019-12-20",@"2020-01-20",@"2020-02-20",@"2020-03-20",@"2020-04-20",@"2020-05-20"];
        
        _chooseDateArr = [NSMutableArray arrayWithArray:arr];
    }
    return _chooseDateArr;
}


//可切换的月份的弹出view
- (YSMonthListView *)monthListTableView
{
    if (!_monthListTableView) {
        
        self.monthListTableView = [[YSMonthListView alloc]initWithFrame:CGRectMake(self.monthBtn.bm_originX+13, CGRectGetMaxY(self.monthBtn.frame)+2, self.monthBtn.bm_width-2*13, self.chooseDateArr.count * 33 +10)];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.monthListTableView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight  cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.monthListTableView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.monthListTableView.layer.mask = maskLayer;
        self.monthListTableView.layer.masksToBounds = YES;
        self.monthListTableView.selectMonth = [self transformationDateWithdateString:self.nowDateStr];
        self.monthListTableView.dateArr = self.chooseDateArr;
        [self.view addSubview:self.monthListTableView];
        
        //默认选中当月
        
        NSInteger index = 0;
        NSString * subStr = [self.nowDateStr substringToIndex:7];
        for (int i = 0; i<self.chooseDateArr.count; i++)
        {
            NSString * ii = self.chooseDateArr[i];
            if ([ii containsString:subStr])
            {
                index = i;
                break;
            }
        }
        
        if (index>0) {
            NSIndexPath * selIndex = [NSIndexPath indexPathForRow:index inSection:0];
            [self.monthListTableView.tabView selectRowAtIndexPath:selIndex animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        
        BMWeakSelf
        
        self.monthListTableView.selectMonthCellClick = ^(NSString * _Nonnull dateStr, NSIndexPath * _Nonnull indexPath) {
            NSDate * date = [NSDate bm_dateFromString:dateStr withFormat:@"yyyy-MM-dd"];
            [weakSelf.MyCalendar setCurrentPage:date animated:YES];
            
            NSString * str = [weakSelf transformationDateWithdateString:dateStr];
            [weakSelf.monthBtn setTitle:str forState:UIControlStateNormal];
            
            if (indexPath.row == 0)
            {
                weakSelf.lastBtn.selected = YES;
                weakSelf.nextBtn.selected = NO;
            }
            else if (indexPath.row == weakSelf.chooseDateArr.count-1)
            {
                weakSelf.lastBtn.selected = NO;
                weakSelf.nextBtn.selected = YES;
            }
            else
            {
                weakSelf.lastBtn.selected = NO;
                weakSelf.nextBtn.selected = NO;
            }
        };
    }
    return _monthListTableView;
}

//yyyy-MM-dd格式日期字符串转成yyyy MM月格式
- (NSString *)transformationDateWithdateString:(NSString *)dateStr
{
    NSDate * date = [NSDate bm_dateFromString:dateStr withFormat:@"yyyy-MM-dd"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSString stringWithFormat:@"yyyy MM%@",YSLocalizedSchool(@"Label.Title.Month")];
    NSString * string = [formatter stringFromDate:date];
    
    return string;
}


- (NSMutableDictionary *)dateDict
{
    if (!_dateDict) {
        self.dateDict = [NSMutableDictionary dictionary];
    }
    return _dateDict;
}

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    return NO;
}

/// 2.返回支持的旋转方向
/// iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
