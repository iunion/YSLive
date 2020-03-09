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
    UIGestureRecognizerDelegate
>
@property (nonatomic, strong) UIView *tableBacView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) SCTeacherTopBarType type;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *selectArr;


@property (nonatomic, strong) UIView *cyclePlayView;

@property (nonatomic, strong) UILabel *studentNumLabel;

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

- (void)setup
{
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    self.selectArr = [NSMutableArray arrayWithCapacity:0];
    self.backgroundColor = [UIColor clearColor];
//    self.layer.cornerRadius = 10;
//    self.layer.masksToBounds = YES;
//
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked:)];
    tapGesture.delegate =self;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    CGFloat tableWidth = ListView_Width;
    CGFloat tableHeight = ListView_Height;
    if (![UIDevice bm_isiPad])
    {
        tableWidth = 250;
        tableHeight = UI_SCREEN_HEIGHT - 80;
    }
    
    UIView *tableBacView = [[UIView alloc] initWithFrame:CGRectMake(UI_SCREEN_WIDTH - tableWidth, 0, tableWidth, tableHeight)];
    tableBacView.bm_centerY = self.bm_centerY;
    self.tableBacView = tableBacView;
    [self addSubview:tableBacView];
    tableBacView.backgroundColor = [UIColor clearColor];
    [tableBacView bm_connerWithRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, tableHeight) style:UITableViewStylePlain];
    tableView.bounces = NO;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
    {
        tableView.insetsContentViewsToSafeArea = NO;
    }
    tableView.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC alpha:0.96];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = YES;
    [tableView registerClass:[SCTeacherPersonListCell class] forCellReuseIdentifier:SCTeacherPersonListCellID];
    [tableView registerClass:[SCTeacherCoursewareListCell class] forCellReuseIdentifier:SCTeacherCoursewareListCellID];
    self.tableView = tableView;
    [tableBacView addSubview:tableView];
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
    if ([self.delegate respondsToSelector:@selector(tapGestureBackListView)])
    {
        [self.delegate tapGestureBackListView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)setDataSource:(NSArray *)dataSource withType:(SCTeacherTopBarType)type
{
    self.type = type;
    [self.dataSource removeAllObjects];
    if (self.type == SCTeacherTopBarTypePersonList)
    {
        [self.dataSource addObjectsFromArray:dataSource];
        for (YSRoomUser * user in dataSource)
        {
            if (!(user.role == YSUserType_Student || user.role == YSUserType_Assistant))
            {
                [self.dataSource removeObject:user];
            }
        }
    }
    if (self.type == SCTeacherTopBarTypeCourseware)
    {
        [self.dataSource addObjectsFromArray:dataSource];
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
            [self.dataSource removeObject:whiteBoardFile];
            [self.dataSource insertObject:whiteBoardFile atIndex:0];
        }
    }
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.studentNumLabel.text = [NSString stringWithFormat:@"学生人数：%@", @(self.dataSource.count)];
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == SCTeacherTopBarTypePersonList)
    {
        SCTeacherPersonListCell * personCell = [tableView dequeueReusableCellWithIdentifier:SCTeacherPersonListCellID forIndexPath:indexPath];
        YSRoomUser *user = self.dataSource[indexPath.row];
        personCell.userModel = user;
        personCell.delegate = self;
        return personCell;
    }
    else if (self.type == SCTeacherTopBarTypeCourseware)
    {
        SCTeacherCoursewareListCell * coursewareCell = [tableView dequeueReusableCellWithIdentifier:SCTeacherCoursewareListCellID forIndexPath:indexPath];
        YSFileModel * model = self.dataSource[indexPath.row];
        coursewareCell.fileModel = model;
        coursewareCell.delegate = self;
        return coursewareCell;
    }
    
    UITableViewCell * cell = [UITableViewCell new];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]init];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ListView_Width, 40)];
    label.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC alpha:0.96];
    label.textColor = [UIColor bm_colorWithHex:0xFFE895];
    label.font = [UIFont systemFontOfSize:14];

    if (self.type == SCTeacherTopBarTypePersonList)
    {
        NSInteger studentNumber = 0;
        for (YSRoomUser * user in self.dataSource)
        {
            if (user.role == YSUserType_Student)
            {
                studentNumber++;
            }
        }
        NSString * str = [NSString stringWithFormat:@"   %@(%@)",YSLocalized(@"Title.UserList"),@(studentNumber)];
        label.text = str;
    }
    else if (self.type == SCTeacherTopBarTypeCourseware)
    {
        NSString * str = [NSString stringWithFormat:@"   %@(%@)",YSLocalized(@"Title.DocumentList"),@(self.dataSource.count)];
        label.text = str;
    }
    [view addSubview:label];
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
    return 40;
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
    if (self.type == SCTeacherTopBarTypeCourseware)
    {
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
