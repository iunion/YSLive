//
//  YSChatMemberListVC.m
//  YSLive
//
//  Created by 马迪 on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSChatMemberListVC.h"
#import "YSChatMemberListCell.h"


@interface YSChatMemberListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;

///是不是第一次进来
@property (nonatomic,assign) BOOL isFirst;

@end

@implementation YSChatMemberListVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    self.bm_NavigationTitleTintColor = UIColor.whiteColor;
    self.bm_NavigationItemTintColor = UIColor.whiteColor;
    
    [self bm_setNavigationWithTitle:YSLocalized(@"Label.ChatList") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:@"navigationBackImage" leftToucheEvent:@selector(backLeft) rightItemTitle:nil rightItemImage:nil rightToucheEvent:nil];
}

//返回
- (void)backLeft
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isFirst = 1;
    self.view.backgroundColor = [UIColor bm_colorWithHexString:@"#F5F5FD"];
    
    [self setupUI];
}

- (void)setupUI
{
    CGFloat decideBtnY = 0.f;
    if (IS_IPHONEXANDP)
    {
        decideBtnY = UI_SCREEN_HEIGHT-kScale_H(50)-UI_NAVIGATION_BAR_HEIGHT-UI_STATUS_BAR_HEIGHT-12-15;
    }
    else
    {
        decideBtnY = UI_SCREEN_HEIGHT-kScale_H(50)-UI_NAVIGATION_BAR_HEIGHT-UI_STATUS_BAR_HEIGHT-12;
    }
    
    UIButton * decideBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScale_W(30), decideBtnY, kScale_W(316), kScale_H(50))];
    [decideBtn setTintColor:[UIColor whiteColor]];
    [decideBtn setTitle:YSLocalized(@"Prompt.OK") forState:UIControlStateNormal];
    [decideBtn setBackgroundColor:[UIColor bm_colorWithHexString:@"#306FFF"]];
    decideBtn.layer.cornerRadius = kScale_H(50)/2;
    [decideBtn addTarget:self action:@selector(decideBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:decideBtn];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, decideBtnY) style:UITableViewStyleGrouped];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    //    self.tableView.backgroundColor = [UIColor bm_colorWithHexString:@"#F5F5FD"];
    self.tableView.backgroundColor = UIColor.whiteColor;
    [self.tableView registerClass:[YSChatMemberListCell class] forCellReuseIdentifier:NSStringFromClass([YSChatMemberListCell class])];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
}

#pragma mark - 确定按钮点击
- (void)decideBtnClick
{
    if (_passTheMemberOfChat)
    {
        _passTheMemberOfChat(self.selectModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setMemberList:(NSMutableArray<YSRoomUser *> *)memberList
{
    _memberList = memberList;
    YSRoomUser * model = [[YSRoomUser alloc]init];
    model.nickName = YSLocalized(@"Label.All");
    model.peerID = @"";
    [self.memberList insertObject:model atIndex:0];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSChatMemberListCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YSChatMemberListCell class])];
    YSRoomUser * model = self.memberList[indexPath.row];
    
    cell.model = model;
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    if ([model.peerID isEqualToString:self.selectModel.peerID])
    {
        cell.isSelected = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isFirst)
    {
        NSInteger ss = 0;
        for (int i = 0; i<self.memberList.count; i++)
        {
            if ([self.memberList[i].peerID isEqualToString:self.selectModel.peerID])
            {
                ss = i;
                break;
            }
        }
        NSIndexPath * index = [NSIndexPath indexPathForRow:ss inSection:0];
        YSChatMemberListCell * cell = [tableView cellForRowAtIndexPath:index];
        cell.isSelected = NO;
        self.isFirst = 0;
    }
    
    self.selectModel = _memberList[indexPath.row];
    YSChatMemberListCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.isSelected = YES;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSChatMemberListCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.isSelected = NO;
}

@end
