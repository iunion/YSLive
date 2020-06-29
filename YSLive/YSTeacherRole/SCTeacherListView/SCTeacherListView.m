//
//  SCTeacherListView.m
//  YSAll
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTeacherListView.h"
#import "SCTeacherPersonListCell.h"
#import "SCTeacherCoursewareListCell.h"

/// 花名册 课件库
#define ListView_Width        426.0f
#define ListView_Height        598.0f
static  NSString * const   SCTeacherPersonListCellID         = @"SCTeacherPersonListCell";
static  NSString * const   SCTeacherCoursewareListCellID     = @"SCTeacherCoursewareListCell";

@interface SCTeacherListView ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    SCTeacherPersonListCellDelegate,
    SCTeacherCoursewareListCellDelegate,
    UIGestureRecognizerDelegate,
    UITextFieldDelegate

>
{
    CGFloat tableWidth;
    CGFloat tableHeight;
    NSInteger _currentPage;
    NSInteger _totalPage;
    NSInteger _userNum;
    YSUserRoleType _userRoleType;
    NSString *_searchString;
}
@property (nonatomic, strong) UIView *tableBacView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) SCBottomToolBarType type;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *selectArr;

@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIView *cyclePlayView;

@property (nonatomic, strong) UILabel *studentNumLabel;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) UIButton *leftPageBtn;
@property (nonatomic, strong) UIButton *rightPageBtn;
@property (nonatomic, strong) UILabel *pageNumLabel;
/// 当前展示课件数组
@property (nonatomic, strong) NSArray *currentFileList;
@property (nonatomic, strong) NSString *mediaFileID;
@property (nonatomic, assign) YSMediaState mediaState;
@end

@implementation SCTeacherListView

- (instancetype)initWithFrame:(CGRect)frame
{
 
    if (self = [super initWithFrame:frame])
    {
        [self setup];
        
//        [self cyclePlaySetup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    tableWidth = ListView_Width;
    tableHeight = self.bm_height - self.topGap - self.bottomGap;
    
    if (![UIDevice bm_isiPad])
    {
        tableWidth = 280;
        
    }
    self.tableBacView.frame = CGRectMake(self.bm_width - tableWidth, self.topGap, tableWidth, tableHeight);
    [self.tableBacView bm_connerWithRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
    self.tableView.frame = CGRectMake(0, 0, tableWidth, tableHeight);
    self.tableFooterView.frame = CGRectMake(0, tableHeight - 40, tableWidth, 40);
    
    self.pageNumLabel.frame = CGRectMake(0, 4, 80, 32);
    self.pageNumLabel.bm_centerX = self.tableFooterView.bm_centerX;
    self.pageNumLabel.layer.cornerRadius = 6;
    self.pageNumLabel.layer.masksToBounds = YES;
    
    self.leftPageBtn.frame = CGRectMake(0, 0, 32, 32);
    self.leftPageBtn.bm_right = self.pageNumLabel.bm_left - 6;
    self.leftPageBtn.bm_centerY = self.pageNumLabel.bm_centerY;
    
    self.rightPageBtn.frame = CGRectMake(0, 0, 32, 32);
    self.rightPageBtn.bm_left = self.pageNumLabel.bm_right + 6;
    self.rightPageBtn.bm_centerY = self.pageNumLabel.bm_centerY;
}

- (void)setup
{
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    self.selectArr = [NSMutableArray arrayWithCapacity:0];
    self.backgroundColor = [UIColor clearColor];
    _currentPage = 1;
    _totalPage = 1;
    _userNum = 0;
    _searchString = @"";

    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked:)];
    tapGesture.delegate =self;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    UIView *tableBacView = [[UIView alloc] init];
    self.tableBacView = tableBacView;
    [self addSubview:tableBacView];
    tableBacView.backgroundColor = [UIColor clearColor];

    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    tableView.bounces = NO;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
    {
        tableView.insetsContentViewsToSafeArea = NO;
    }
    tableView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = YES;
    [tableView registerClass:[SCTeacherPersonListCell class] forCellReuseIdentifier:SCTeacherPersonListCellID];
    [tableView registerClass:[SCTeacherCoursewareListCell class] forCellReuseIdentifier:SCTeacherCoursewareListCellID];
    self.tableView = tableView;
    [tableBacView addSubview:tableView];
    
    self.tableFooterView = [[UIView alloc] init];
    [tableBacView addSubview:self.tableFooterView];
    self.tableFooterView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    self.tableFooterView.hidden = NO;
    
    UILabel * pageNumLabel = [[UILabel alloc] init];
    pageNumLabel.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    pageNumLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
    pageNumLabel.font = [UIFont systemFontOfSize:16];
    pageNumLabel.text = @"";
    pageNumLabel.textAlignment = NSTextAlignmentCenter;
    [self.tableFooterView addSubview:pageNumLabel];
    self.pageNumLabel = pageNumLabel;
    
    UIButton *leftPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftPageBtn addTarget:self action:@selector(leftPageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftPageBtn setImage:YSSkinElementImage(@"leftPage_nameList", @"iconNor") forState:UIControlStateNormal];
    UIImage * leftIconDisImage = [YSSkinElementImage(@"leftPage_nameList", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [leftPageBtn setImage:leftIconDisImage forState:UIControlStateDisabled];
    [self.tableFooterView addSubview:leftPageBtn];
    self.leftPageBtn = leftPageBtn;
    
    
    UIButton *rightPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightPageBtn addTarget:self action:@selector(rightPageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightPageBtn setImage:YSSkinElementImage(@"rightPage_nameList", @"iconNor") forState:UIControlStateNormal];
    UIImage * rightIconDisImage = [YSSkinElementImage(@"rightPage_nameList", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [rightPageBtn setImage:rightIconDisImage forState:UIControlStateDisabled];
    [self.tableFooterView addSubview:rightPageBtn];
    self.rightPageBtn = rightPageBtn;

}


- (void)setTopGap:(CGFloat)topGap
{
    _topGap = topGap;
}

- (void)setBottomGap:(CGFloat)bottomGap
{
    _bottomGap = bottomGap;
}

- (void)cyclePlaySetup
{
    
    UIView * cyclePlayView = [[UIView alloc]initWithFrame:CGRectMake((ListView_Width - 333)/2, 145, 333, 226)];
    cyclePlayView.backgroundColor = UIColor.yellowColor;
    cyclePlayView.layer.cornerRadius = 26;
    self.cyclePlayView = cyclePlayView;
    [self.tableView addSubview:cyclePlayView];
    
    UIButton * cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(287, 10, 25, 25)];
    [cancleBtn setImage:[UIImage imageNamed:@"cancel_gray"] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [cyclePlayView addSubview:cancleBtn];
    
    UILabel * cycleNumLab = [[UILabel alloc]initWithFrame:CGRectMake(60, 58, 100, 25)];
    cycleNumLab.text = @"轮循人数";
    cycleNumLab.layer.borderColor = UIColor.redColor.CGColor;
    cycleNumLab.layer.borderWidth = 1.0;
    [cyclePlayView addSubview:cycleNumLab];
    
    UIView * numView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cycleNumLab.frame), cycleNumLab.bm_originY, 116, 40)];
    [numView bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
    numView.bm_centerY = cycleNumLab.bm_centerY;
    [cyclePlayView addSubview:numView];
    
    UILabel * numLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 40)];
    numLab.text = @"3";
    numLab.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
    numLab.font = UI_FONT_16;
    [numView addSubview:numLab];
//    numLab.backgroundColor = UIColor.redColor;
        
    UIButton * numBtn = [[UIButton alloc]initWithFrame:CGRectMake(numView.bm_width-40, 0, 30, 40)];
    [numBtn setImage:[UIImage imageNamed:@"SCTextArrow"] forState:UIControlStateNormal];
    [numBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    numBtn.tag = 1;
    [numView addSubview:numBtn];
    
    
    UILabel * cycleTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(60, CGRectGetMaxY(cycleNumLab.frame)+37, 100, 25)];
    cycleTimeLab.text = @"轮循时间";
    cycleTimeLab.layer.borderColor = UIColor.redColor.CGColor;
    cycleTimeLab.layer.borderWidth = 1.0;
    [cyclePlayView addSubview:cycleTimeLab];
    
    UIView * timeView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cycleTimeLab.frame), cycleTimeLab.bm_originY, 116, 40)];
    [timeView bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
    timeView.bm_centerY = cycleTimeLab.bm_centerY;
    [cyclePlayView addSubview:timeView];
    
    UILabel * timeLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 40)];
    timeLab.text = @"30秒";
    timeLab.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
    timeLab.font = UI_FONT_16;
    [timeView addSubview:timeLab];
        
    UIButton * timeBtn = [[UIButton alloc]initWithFrame:CGRectMake(numView.bm_width-40, 0, 30, 40)];
    [timeBtn setImage:[UIImage imageNamed:@"SCTextArrow"] forState:UIControlStateNormal];
    [timeBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    timeBtn.tag = 2;
    [timeView addSubview:timeBtn];
    
    UIButton * soureBtn = [[UIButton alloc]initWithFrame:CGRectMake((cyclePlayView.bm_width-150)/2, 175, 150, 40)];
    [soureBtn setTitle:YSLocalized(@"Prompt.OK") forState:UIControlStateNormal];
    [soureBtn bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
    [soureBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    soureBtn.tag = 3;
    [soureBtn setBackgroundColor:[UIColor bm_colorWithHex:0x5A8CDC]];
    [cyclePlayView addSubview:soureBtn];
}

- (void)btnsClick:(UIButton *)sender
{
    
}

- (void)cancleBtnClick
{
    self.cyclePlayView.hidden = YES;
}

- (void)tapGestureClicked:(UITapGestureRecognizer *)tap
{
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(tapGestureBackListView)])
    {
        [self.delegate tapGestureBackListView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView] || [touch.view isDescendantOfView:self.tableFooterView])
    {
        [self endEditing:YES];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)setDataSource:(NSArray *)dataSource withType:(SCBottomToolBarType)type userNum:(NSInteger)userNum currentFileList:(nonnull NSArray *)currentFileList mediaFileID:(nonnull NSString *)mediaFileID mediaState:(YSMediaState)state
{
    self.currentFileList = currentFileList;
    self.mediaFileID = mediaFileID;
    self.mediaState = state;
    [self setDataSource:dataSource withType:type userNum:userNum];
}

- (void)setDataSource:(NSArray *)dataSource withType:(SCBottomToolBarType)type userNum:(NSInteger)userNum
{
    self.type = type;
    _userNum = userNum;
    [self.dataSource removeAllObjects];
    if (self.type == SCBottomToolBarTypePersonList)
    {
        self.tableView.bm_height = tableHeight - 40;
        self.tableFooterView.hidden = NO;
        if ([dataSource bm_isNotEmpty])
        {
            [self.dataSource addObjectsFromArray:dataSource];
        }
        for (YSRoomUser * user in dataSource)
        {
            if (!(user.role == YSUserType_Student || user.role == YSUserType_Assistant))
            {
                [self.dataSource removeObject:user];
            }
        }
    }
    if (self.type == SCBottomToolBarTypeCourseware)
    {
        self.tableView.bm_height = tableHeight;
        self.tableFooterView.hidden = YES;
        if ([dataSource bm_isNotEmpty])
        {
            [self.dataSource addObjectsFromArray:dataSource];
        }
        [self.dataSource sortUsingComparator:^NSComparisonResult(YSFileModel * _Nonnull obj1, YSFileModel * _Nonnull obj2) {
            return [obj2.fileid compare:obj1.fileid];
        }];
        
        YSFileModel *whiteBoardFile = nil;
        for (YSFileModel *model in self.dataSource)
        {
            if (model.fileid.intValue == 0)
            {
                whiteBoardFile = model;
                break;
            }
        }
        
        if (whiteBoardFile)
        {
            
            if ([YSLiveManager sharedInstance].roomConfig.isMultiCourseware)
            {
                [self.dataSource removeObject:whiteBoardFile];
            }
            else
            {
                [self.dataSource removeObject:whiteBoardFile];
                [self.dataSource insertObject:whiteBoardFile atIndex:0];
            }
            
        }
    }
    [self.tableView reloadData];
}

- (void)setUserRole:(YSUserRoleType)userRoleType
{
    _userRoleType = userRoleType;
}

- (void)setPersonListCurrentPage:(NSInteger)currentPage totalPage:(NSInteger)totalPage
{
    _totalPage = totalPage;
    if (_totalPage < 1)
    {
        _totalPage = 1;
    }
    
    _currentPage = currentPage + 1;
    if (_currentPage < 1)
    {
        _currentPage = 1;
    }
    self.pageNumLabel.text = [NSString stringWithFormat:@"%@/%@",@(_currentPage),@(_totalPage)];
    self.leftPageBtn.enabled = (_currentPage > 1);
    self.rightPageBtn.enabled = _currentPage < _totalPage;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    self.studentNumLabel.text = [NSString stringWithFormat:@"学生人数：%ld",self.dataSource.count];
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == SCBottomToolBarTypePersonList)
    {
        SCTeacherPersonListCell * personCell = [tableView dequeueReusableCellWithIdentifier:SCTeacherPersonListCellID forIndexPath:indexPath];
        if (indexPath.row < [self.dataSource count])
        {
            YSRoomUser *user = self.dataSource[indexPath.row];
            
            personCell.userModel = user;
            if (_userRoleType == YSUserType_Patrol)
            {
                [personCell setUserRole:_userRoleType];
            }
            
        }
        
        personCell.delegate = self;
        return personCell;
    }
    else if (self.type == SCBottomToolBarTypeCourseware)
    {
        SCTeacherCoursewareListCell * coursewareCell = [tableView dequeueReusableCellWithIdentifier:SCTeacherCoursewareListCellID forIndexPath:indexPath];
        YSFileModel * model = self.dataSource[indexPath.row];
        BOOL isCurrent = [self.currentFileList containsObject:model.fileid];
        
        [coursewareCell setFileModel:model isCurrent:isCurrent mediaFileID:self.mediaFileID mediaState:self.mediaState];
        
        if (_userRoleType == YSUserType_Patrol)
        {
            [coursewareCell setUserRole:_userRoleType];
        }
        coursewareCell.delegate = self;
        return coursewareCell;
    }
    
    UITableViewCell * cell = [UITableViewCell new];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]init];
    view.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    view.userInteractionEnabled = YES;
    if (self.type == SCBottomToolBarTypePersonList)
    {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
        titleLabel.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        titleLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIDevice bm_isiPad] ? UI_FONT_16 : UI_FONT_12;
        NSString * title = YSLocalized(@"Title.UserList");
        titleLabel.text = title;
        [view addSubview:titleLabel];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = YSSkinDefineColor(@"lineColor");
        lineView.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), tableWidth, 1);
        [view addSubview:lineView];
        
        
        CGFloat userNumGap = [UIDevice bm_isiPad] ? 17.0f : 8.0f;
        CGFloat userNumHeight = [UIDevice bm_isiPad] ? 40.0f : 26.0f;
        UILabel * userNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableWidth - 10 - 80, CGRectGetMaxY(lineView.frame) + userNumGap, 80, userNumHeight)];
        userNumLabel.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        userNumLabel.textColor = YSSkinDefineColor(@"defaultTitleColor");
        userNumLabel.font = [UIDevice bm_isiPad] ? UI_FONT_14 : UI_FONT_10;
        NSString * userNum = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"Title.StudentNum"),@(_userNum)];
        userNumLabel.text = userNum;
        userNumLabel.textAlignment = NSTextAlignmentRight;
        [view addSubview:userNumLabel];
        
        UITextField *inputTextField = [[UITextField alloc] init];
//        [inputTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        self.inputTextField = inputTextField;
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:YSLocalized(@"Label.searchPlaceholder") attributes:@{
                       NSForegroundColorAttributeName:YSSkinDefineColor(@"placeholderColor"),
                       NSFontAttributeName:[UIDevice bm_isiPad] ? UI_FONT_14 : UI_FONT_10
                   }];
        inputTextField.attributedPlaceholder = attrString;
        inputTextField.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        inputTextField.textColor = YSSkinDefineColor(@"defaultTitleColor");
        inputTextField.font = [UIDevice bm_isiPad] ? UI_FONT_14 : UI_FONT_10;
        inputTextField.delegate = self;
        inputTextField.tintColor = YSColor_LoginTextField;
        inputTextField.enabled = YES;

        [inputTextField bm_addShadow:1 Radius:userNumHeight/2.0f BorderColor:YSSkinDefineColor(@"placeholderColor") ShadowColor:[UIColor clearColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
        
        inputTextField.returnKeyType = UIReturnKeySearch;
        if ([_searchString bm_isNotEmpty])
        {
            inputTextField.text = _searchString;
        }
        inputTextField.frame = CGRectMake(2, CGRectGetMaxY(lineView.frame) + userNumGap, 0, userNumHeight);
        [inputTextField bm_setLeft:15 right:userNumLabel.bm_left - 5];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, userNumHeight, userNumHeight)];
        UIImageView *searchView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, userNumHeight - 10, userNumHeight - 10)];
        searchView.contentMode = UIViewContentModeCenter;
        [searchView setImage:YSSkinElementImage(@"searchbar_search_nameList", @"iconNor")];
        [leftView addSubview:searchView];
        inputTextField.leftView = leftView;
        inputTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, userNumHeight, userNumHeight)];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightView addSubview:cancelBtn];
        cancelBtn.frame = CGRectMake(8, 8, userNumHeight - 16, userNumHeight - 16);
        [cancelBtn setImage:YSSkinElementImage(@"searchbar_cancel_nameList", @"iconNor") forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        inputTextField.rightView = rightView;
        inputTextField.rightViewMode = UITextFieldViewModeAlways;
        
        
        
        [view addSubview:inputTextField];
    }
    else if (self.type == SCBottomToolBarTypeCourseware)
    {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 39)];
        label.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        label.textColor = YSSkinDefineColor(@"defaultTitleColor");
        label.font = [UIDevice bm_isiPad] ? UI_FONT_16 : UI_FONT_12;
        NSString * str = [NSString stringWithFormat:@"   %@(%@)",YSLocalized(@"Title.DocumentList"),@(_userNum)];
        label.text = str;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = YSSkinDefineColor(@"lineColor");
        lineView.frame = CGRectMake(0, CGRectGetMaxY(label.frame), tableWidth, 1);
        [view addSubview:lineView];
        
    }
    
//
//    UIButton * cycleTitleBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 20, 5, 125, 30)];
//    [cycleTitleBtn setTitle:@"启动视频轮播" forState:UIControlStateNormal];
//    [cycleTitleBtn setBackgroundImage:[UIImage imageNamed:@"permissions_BtnSelect"] forState:UIControlStateNormal];
//    [cycleTitleBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
//    [cycleTitleBtn addTarget:self action:@selector(cycleTitleBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [cycleTitleBtn.titleLabel setFont:UI_FONT_14];
//    [view addSubview:cycleTitleBtn];
//
//    label.backgroundColor = UIColor.greenColor;
//    [cycleTitleBtn setBackgroundColor:UIColor.greenColor];
//
//    UILabel * studentNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(ListView_Width-100, 0, 100, 40)];
//    studentNumLabel.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC alpha:0.96];
//    studentNumLabel.textColor = [UIColor bm_colorWithHex:0xFFE895];
//    studentNumLabel.font = UI_FONT_14;
//
//    [view addSubview:studentNumLabel];
//    self.studentNumLabel = studentNumLabel;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.type == SCBottomToolBarTypePersonList)
    {
        CGFloat headerHeight = [UIDevice bm_isiPad] ? 110.0f : 80.0f;
        return headerHeight;
    }
    return 40;
}

- (void)leftPageBtnClicked:(UIButton *)btn
{
    
    if ([self.delegate respondsToSelector:@selector(leftPageProxyWithPage:)])
    {
        [self.delegate leftPageProxyWithPage:_currentPage-1];
    }
    self.leftPageBtn.enabled = (_currentPage > 1);
    self.rightPageBtn.enabled = _currentPage < _totalPage;

}

- (void)rightPageBtnClicked:(UIButton *)btn
{
//    self.leftPageBtn.enabled = (_currentPage > 1);
//    self.rightPageBtn.enabled = _currentPage < _totalPage;
    if ([self.delegate respondsToSelector:@selector(rightPageProxyWithPage:)])
    {
        [self.delegate rightPageProxyWithPage:_currentPage-1];
    }
    self.leftPageBtn.enabled = (_currentPage > 1);
    self.rightPageBtn.enabled = _currentPage < _totalPage;

}
- (void)cancelBtnClicked:(UIButton *)btn
{
    _searchString = @"";
    self.inputTextField.text = _searchString;
    if ([self.delegate respondsToSelector:@selector(cancelProxy)])
    {
        [self.delegate cancelProxy];
    }
}

- (void)cycleTitleBtnClick
{
    self.cyclePlayView.hidden = NO;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIDevice bm_isiPad])
    {
        return 70;
    }
    else
    {
        return 40;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == SCBottomToolBarTypeCourseware)
    {
        
        if (_userRoleType == YSUserType_Patrol)
        {
            return;
        }
        YSFileModel * model = self.dataSource[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(selectCoursewareProxyWithFileModel:)])
        {
            [self.delegate selectCoursewareProxyWithFileModel:model];
        }
    }
}

#pragma mark -
#pragma mark SCTeacherPersonListCellDelegate
- (void)upPlatformBtnProxyClickWithRoomUser:(YSRoomUser *)roomUser
{
    if ([self.delegate respondsToSelector:@selector(upPlatformProxyWithRoomUser:)])
    {
        [self.delegate upPlatformProxyWithRoomUser:roomUser];
    }
}

- (void)speakBtnProxyClickWithRoomUser:(YSRoomUser *)roomUser
{
    if ([self.delegate respondsToSelector:@selector(speakProxyWithRoomUser:)])
    {
        [self.delegate speakProxyWithRoomUser:roomUser];
    }
}

- (void)outBtnProxyClickWithRoomUser:(YSRoomUser *)roomUser
{
    if ([self.delegate respondsToSelector:@selector(outProxyWithRoomUser:)])
    {
        [self.delegate outProxyWithRoomUser:roomUser];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    _searchString = textField.text;
    if ([textField.text bm_isNotEmpty])
    {
        if ([self.delegate respondsToSelector:@selector(searchProxyWithSearchContent:)])
        {
            [self.delegate searchProxyWithSearchContent:textField.text];
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark SCTeacherCoursewareListCellDelegate

- (void)deleteBtnProxyClickWithFileModel:(YSFileModel *)fileModel
{
    if ([self.delegate respondsToSelector:@selector(deleteCoursewareProxyWithFileModel:)])
    {
        [self.delegate deleteCoursewareProxyWithFileModel:fileModel];
    }
}
@end
