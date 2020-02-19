//
//  YSUpHandPopoverVC.m
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/17.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSUpHandPopoverVC.h"
#import "YSUpHandPopCell.h"
#import "YSLiveManager.h"

@interface YSUpHandPopoverVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>



@end

@implementation YSUpHandPopoverVC

- (void)setUserArr:(NSMutableArray *)userArr
{
    _userArr = userArr;
    
    [self.tabView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView * tabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,95, 146)];
    [self.view addSubview:tabView];
    self.tabView = tabView;
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];
    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tabView flashScrollIndicators];
    tabView.bounces = NO;
        
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YSUpHandPopCell * cell = [YSUpHandPopCell cellWithTableView:tableView];

    //在这里判断，看indexPath是否已经被选中,如果选中就将其对应的那一行的字体颜色设置为选中时的颜色，否则就是默认的颜色
//    if ([_indexArray containsObject:indexPath]) {
//        cell.textLabel.textColor = kMainColor;
//    }else{
//        cell.textLabel.textColor = [UIColor blackColor];
//    }
    YSRoomUser * user = self.userArr[indexPath.row];
    
    cell.userModel = self.userArr[indexPath.row];
    
    cell.headButtonClick = ^{
        //同意上台
//        BOOL isEveryoneNoAudio = [YSLiveManager shareInstance].isEveryoneNoAudio;
//        if (isEveryoneNoAudio) {
//            [[YSLiveManager shareInstance] sendSignalingToChangePropertyWithRoomUser:user withKey:sUserPublishstate WithValue:@(YSUser_PublishState_VIDEOONLY)];
//        }
//        else
//        {
            [[YSLiveManager shareInstance] sendSignalingToChangePropertyWithRoomUser:user withKey:sUserPublishstate WithValue:@(YSUser_PublishState_BOTH)];
//        }
    };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 24;
}

@end
