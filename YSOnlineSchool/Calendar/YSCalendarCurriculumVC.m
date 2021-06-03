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
#import "YSCoreStatus.h"

#define calendH (self.view.bm_height < 667) ? 370 : 400

#define monthBtnY (self.view.bm_height < 667) ? 15 : 23

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

///可展示的所有月份的数组
@property(nonatomic,strong)NSMutableArray *showAllDateArr;

@property (nonatomic, strong) UIButton *lastBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *monthBtn;

///可切换的月份数组yyyy-MM-dd
@property(nonatomic,strong)NSMutableArray *chooseDateArr;
///可切换的月份数组yyyy-MM
@property(nonatomic,strong)NSMutableArray *chooseMonthDateArr;


///可切换的月份的弹出view
@property (nonatomic, strong) YSMonthListView * monthListTableView;

@property (copy, nonatomic) NSString *currentShowDateStr;

//可切换的月份的弹出view中当前选中的cell的NSIndexPath
@property (nonatomic, strong)NSIndexPath *indexPath;

//设备型号是否是iPhone6以下
@property (assign, nonatomic) BOOL lessIphone6;

@end

@implementation YSCalendarCurriculumVC

- (void)dealloc
{
    [_calendarDataTask cancel];
    _calendarDataTask = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = YSSkinOnlineDefineColor(@"liveDefaultBgColor");
    
    self.bm_NavigationTitleTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    self.bm_NavigationItemTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.Calendar") barTintColor:YSSkinOnlineDefineColor(@"timer_timeBgColor") leftItemTitle:nil leftItemImage:nil leftToucheEvent:nil rightItemTitle:nil rightItemImage:YSSkinOnlineElementImage(@"mine_refreshBtn", @"iconNor") rightToucheEvent:@selector(refrshMonthClassDate)];
    self.title = nil;
    
    [self selectMonthUI];
    
    [self setupUI];
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    [self bringSomeViewToFront];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    self.nowDateStr = [currentDate bm_stringWithFormat:@"yyyy-MM-dd"];

    self.currentShowDateStr = self.nowDateStr;
    [self getCalendarDatas:self.nowDateStr];
    
}

- (void)refrshMonthClassDate
{
    [self getCalendarDatas:self.currentShowDateStr];
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
    NSString * month = [NSString stringWithFormat:@"%@%@", [currentDate bm_stringWithFormat:@"yyyy MM"], YSLocalizedSchool(@"Label.Title.Month")] ;

    UIButton *monthBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bm_width - 120)/2, monthBtnY, 120, 26)];
    [monthBtn setBackgroundColor:UIColor.whiteColor];
    [monthBtn setImage:[UIImage imageNamed:@"onlineSchool_allMonth"] forState:UIControlStateNormal];
    [monthBtn setTitle:month forState:UIControlStateNormal];
    [monthBtn setTitleColor:[UIColor bm_colorWithHex:0x828282] forState:UIControlStateNormal];
    monthBtn.titleLabel.font = UI_FONT_16;
    monthBtn.layer.cornerRadius = 4;
    monthBtn.layer.masksToBounds = YES;
    [monthBtn addTarget:self action:@selector(monthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    monthBtn.tag = 2;
    [self.view addSubview:monthBtn];
    self.monthBtn = monthBtn;
    
    monthBtn.imageEdgeInsets = UIEdgeInsetsMake(0, monthBtn.frame.size.width - monthBtn.imageView.frame.origin.x - monthBtn.imageView.frame.size.width, 0, 0);
    monthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - monthBtn.imageView.frame.size.width-10, 0, 10);
    
    UIButton *lastBtn = [[UIButton alloc]init];
    [lastBtn setBackgroundColor:UIColor.clearColor];
    [lastBtn setImage:YSSkinOnlineElementImage(@"calendar_lastMonthBtn", @"iconNor") forState:UIControlStateNormal];
    [lastBtn setImage:YSSkinOnlineElementImage(@"calendar_lastMonthBtn", @"iconSel") forState:UIControlStateHighlighted];
//    lastBtn.layer.cornerRadius = 4;
//    lastBtn.layer.masksToBounds = YES;
    [lastBtn addTarget:self action:@selector(monthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    lastBtn.tag = 1;
    [self.view addSubview:lastBtn];
    self.lastBtn = lastBtn;
    
    UIButton *nextBtn = [[UIButton alloc]init];
    [nextBtn setBackgroundColor:UIColor.clearColor];
    [nextBtn setImage:YSSkinOnlineElementImage(@"calendar_nextMonthBtn", @"iconNor") forState:UIControlStateNormal];
    [nextBtn setImage:YSSkinOnlineElementImage(@"calendar_nextMonthBtn", @"iconSel") forState:UIControlStateHighlighted];
//    nextBtn.layer.cornerRadius = 4;
//    nextBtn.layer.masksToBounds = YES;
    [nextBtn addTarget:self action:@selector(monthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.tag = 3;
    [self.view addSubview:nextBtn];
    self.nextBtn = nextBtn;
        
    [lastBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(monthBtnY);
        make.right.bmmas_equalTo(monthBtn.bmmas_left).bmmas_offset(-16);
        make.width.height.bmmas_equalTo(26);
    }];
    
    [nextBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(monthBtnY);
        make.left.bmmas_equalTo(monthBtn.bmmas_right).bmmas_offset(16);
        make.width.height.bmmas_equalTo(26);
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
        self.monthListTableView.hidden = NO;
      [UIView animateWithDuration:0.25 animations:^{
          weakSelf.monthListTableView.bm_height = self.chooseDateArr.count * 33 + 5;
        }];
    }
}


//UI
- (void)setupUI
{
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(20,  70, self.view.bm_width-40, 350)];
    calendar.dataSource = self;
    calendar.delegate = self;
    
    [self.view addSubview:calendar];
    self.MyCalendar = calendar;
    calendar.backgroundColor = UIColor.whiteColor;
    calendar.layer.cornerRadius = 16;
    calendar.swipeToChooseGesture.enabled = NO;
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[YSCalendarCell class] forCellReuseIdentifier:@"cell"];
    
    // iOS 获取设备当前语言和地区的代码
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    
    NSString *currentLanguageRegion = [[NSLocale preferredLanguages] firstObject];

    if(![currentLanguageRegion bm_containString:@"zh-Hant"] && ![currentLanguageRegion bm_containString:@"zh-Hans"])
    {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];//设置为英文
    }
        
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
- (void)getCalendarDatas:(NSString *)dateStr
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
    
    [self.calendarDataTask cancel];
    self.calendarDataTask = nil;
    
    BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    
    CHUserRoleType schoolUserType = [YSSchoolUser shareInstance].userRoleType;
    NSString * userId = [YSSchoolUser shareInstance].userId;
    NSString * organId = [YSSchoolUser shareInstance].organId;
    
    NSMutableURLRequest *request = [YSLiveApiRequest getClassListWithUserId:userId WithOrganId:organId WithUserType:schoolUserType Withdate:dateStr];

    if (request)
    {
        BMWeakSelf
        self.calendarDataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (error)
            {
                NSString *errorMessage;
                if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
                {
                    errorMessage = YSLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
                }
                else
                {
                    errorMessage = YSLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
                }

#if YSShowErrorCode
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"%@: %@", @(error.code), error.localizedDescription] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
            }
            else
            {
                [weakSelf.progressHUD bm_hideAnimated:NO];
                
                NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
                if ([responseDic bm_isNotEmptyDictionary])
                {
                    
                    NSInteger statusCode = [responseDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (statusCode == YSSuperVC_StatusCode_Succeed)
                    {
                        NSArray * allDate = [responseDic bm_arrayForKey:@"data"];
                        
                        NSString * month = [dateStr substringToIndex:7];
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
#if YSShowErrorCode
                        message = [NSString stringWithFormat:@"%@: %@", @(statusCode), message];
#endif
                        if ([weakSelf checkRequestStatus:statusCode message:message responseDic:responseDic])
                        {
                            [weakSelf.progressHUD bm_hideAnimated:NO];
                        }
                        else
                        {
                            [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                        }
                        return;
                    }
                }
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
        }];
        [self.calendarDataTask resume];
    }
    else
    {
         [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

#pragma mark - 日历滚动的代理
- (void)calendarScrollViewWithDate:(NSDate *)date
{
//    [self hiddenTheMonthListTableView:YES];
    
    self.currentShowDateStr = [date bm_stringWithFormat:@"yyyy-MM-dd"];
    [self getCalendarDatas:self.currentShowDateStr];
        
    NSString * dateStr1 = [date bm_stringWithFormat:@"yyyy-MM"];
    if ([self.showAllDateArr.firstObject containsString:dateStr1])
    {
        self.lastBtn.selected = YES;
        self.nextBtn.selected = NO;
    }
    else if ([self.showAllDateArr.lastObject containsString:dateStr1])
    {
        self.lastBtn.selected = NO;
        self.nextBtn.selected = YES;
    }
    else
    {
        self.lastBtn.selected = NO;
        self.nextBtn.selected = NO;
    }
    NSString * dateStr = [NSString stringWithFormat:@"%@%@", [date bm_stringWithFormat:@"yyyy MM"], YSLocalizedSchool(@"Label.Title.Month")] ;
    [self.monthBtn setTitle:dateStr forState:UIControlStateNormal];
    
    if ([self.chooseMonthDateArr containsObject:dateStr1])
    {
        NSInteger indexNum = [self.chooseMonthDateArr indexOfObject:dateStr1];
                
        NSIndexPath * index = [NSIndexPath indexPathForRow:indexNum inSection:0];
        
        [self.monthListTableView.tabView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        self.monthListTableView.selectMonth = dateStr;
        [self.monthListTableView.tabView reloadData];
        
        self.indexPath = index;
    }
    else
    {
        self.monthListTableView.selectMonth = nil;
        [self.monthListTableView.tabView reloadData];
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

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date
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
    return [NSDate bm_dateFromString:self.showAllDateArr.firstObject withFormat:@"yyyy-MM-dd"];
}

//可选择的最大日期
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [NSDate bm_dateFromString:self.showAllDateArr.lastObject withFormat:@"yyyy-MM-dd"];
}

- (NSMutableArray *)chooseDateArr
{
    if (!_chooseDateArr) {
        
        self.nowDateStr = [[NSDate date] bm_stringWithFormat:@"yyyy-MM-dd"];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *nextMonthComps = [[NSDateComponents alloc] init];
        //    [lastMonthComps setYear:1]; // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
        
        [nextMonthComps setMonth:1];
        NSDate *date1 = [calendar dateByAddingComponents:nextMonthComps toDate:[NSDate date] options:0];
        NSString *afterDateStr1 = [date1 bm_stringWithFormat:@"yyyy-MM-dd"];
        
        [nextMonthComps setMonth:2];
        NSDate *date2 = [calendar dateByAddingComponents:nextMonthComps toDate:[NSDate date] options:0];
        NSString *afterDateStr2 = [date2 bm_stringWithFormat:@"yyyy-MM-dd"];
        
        [nextMonthComps setMonth:3];
        NSDate *date3 = [calendar dateByAddingComponents:nextMonthComps toDate:[NSDate date] options:0];
        NSString *afterDateStr3 = [date3 bm_stringWithFormat:@"yyyy-MM-dd"];
        
        _chooseDateArr = [NSMutableArray array];
        
        [_chooseDateArr addObject:self.nowDateStr];
        [_chooseDateArr addObject:afterDateStr1];
        [_chooseDateArr addObject:afterDateStr2];
        [_chooseDateArr addObject:afterDateStr3];
        
        self.chooseMonthDateArr = [NSMutableArray array];
        [self.chooseMonthDateArr addObject:[self.nowDateStr substringToIndex:7]];
        [self.chooseMonthDateArr addObject:[afterDateStr1 substringToIndex:7]];
        [self.chooseMonthDateArr addObject:[afterDateStr2 substringToIndex:7]];
        [self.chooseMonthDateArr addObject:[afterDateStr3 substringToIndex:7]];
    }
    return _chooseDateArr;
}

- (NSMutableArray *)showAllDateArr
{
    if (!_showAllDateArr) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *nextMonthComps = [[NSDateComponents alloc] init];
        //    [lastMonthComps setYear:1]; // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
        [nextMonthComps setMonth:-3];
        NSDate *date1 = [calendar dateByAddingComponents:nextMonthComps toDate:[NSDate date] options:0];
        NSString *afterDateStr1 = [date1 bm_stringWithFormat:@"yyyy-MM-dd"];
        
        [nextMonthComps setMonth:-2];
        NSDate *date2 = [calendar dateByAddingComponents:nextMonthComps toDate:[NSDate date] options:0];
        NSString *afterDateStr2 = [date2 bm_stringWithFormat:@"yyyy-MM-dd"];
        
        [nextMonthComps setMonth:-1];
        NSDate *date3 = [calendar dateByAddingComponents:nextMonthComps toDate:[NSDate date] options:0];
        NSString *afterDateStr3 = [date3 bm_stringWithFormat:@"yyyy-MM-dd"];
        
        _showAllDateArr = [NSMutableArray array];
        [_showAllDateArr addObject:afterDateStr1];
        [_showAllDateArr addObject:afterDateStr2];
        [_showAllDateArr addObject:afterDateStr3];
        
        if ([self.chooseDateArr bm_isNotEmpty]) {
            for (NSString * dateStr in self.chooseDateArr) {
                [_showAllDateArr addObject:dateStr];
            }
        }
    }
    return _showAllDateArr;
}


//可切换的月份的弹出view
- (YSMonthListView *)monthListTableView
{
    if (!_monthListTableView) {

        self.monthListTableView = [[YSMonthListView alloc]initWithFrame:CGRectMake(self.monthBtn.bm_originX+13, CGRectGetMaxY(self.monthBtn.frame)+2, self.monthBtn.bm_width-2*13, self.chooseDateArr.count * 33 +5)];
        
        self.monthListTableView.backgroundColor = UIColor.clearColor;
        self.monthListTableView.selectMonth = [self transformationDateWithdateString:self.nowDateStr];
        self.monthListTableView.dateArr = self.chooseDateArr;
        [self.view addSubview:self.monthListTableView];

        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.monthListTableView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight  cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.monthListTableView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.monthListTableView.layer.mask = maskLayer;
        self.monthListTableView.layer.masksToBounds = YES;
        
        self.monthListTableView.hidden = YES;
        
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

        if (index>= 0)
        {
            self.indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.monthListTableView.tabView selectRowAtIndexPath:self.indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }

        BMWeakSelf

        self.monthListTableView.selectMonthCellClick = ^(NSString * _Nonnull dateStr, NSIndexPath * _Nonnull indexPath) {
            NSDate * date = [NSDate bm_dateFromString:dateStr withFormat:@"yyyy-MM-dd"];
            [weakSelf.MyCalendar setCurrentPage:date animated:YES];

            NSString * str = [weakSelf transformationDateWithdateString:dateStr];
            [weakSelf.monthBtn setTitle:str forState:UIControlStateNormal];
            
            weakSelf.indexPath = indexPath;
        };
    }
    return _monthListTableView;
}

//yyyy-MM-dd格式日期字符串转成yyyy MM月格式
- (NSString *)transformationDateWithdateString:(NSString *)dateStr
{
    NSDate * date = [NSDate bm_dateFromString:dateStr withFormat:@"yyyy-MM-dd"];

    NSString *string = [NSString stringWithFormat:@"%@%@", [date bm_stringWithFormat:@"yyyy MM"], YSLocalizedSchool(@"Label.Title.Month")] ;

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
    if (GetAppDelegate.useAllowRotation)
    {
        return NO;
    }
    
    return YES;
}

/// 2.返回支持的旋转方向
/// iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
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
