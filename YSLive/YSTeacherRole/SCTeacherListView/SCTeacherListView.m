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

@end

@implementation SCTeacherListView

- (instancetype)initWithFrame:(CGRect)frame
{
 
    if (self = [super initWithFrame:frame])
    {
        [self setup];
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
//    tableView.bm_centerY = self.tableBacView.bm_centerY;
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
    UILabel * label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC alpha:0.96];
    label.textColor = [UIColor bm_colorWithHex:0xFFE895];
    label.font = [UIFont systemFontOfSize:14];
    if (self.type == SCTeacherTopBarTypePersonList)
    {
        NSString * str = [NSString stringWithFormat:@"   %@(%@)",YSLocalized(@"Title.UserList"),@(self.dataSource.count)];
        label.text = str;
    }
    else if (self.type == SCTeacherTopBarTypeCourseware)
    {
        NSString * str = [NSString stringWithFormat:@"   %@(%@)",YSLocalized(@"Title.DocumentList"),@(self.dataSource.count)];
        label.text = str;
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
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
