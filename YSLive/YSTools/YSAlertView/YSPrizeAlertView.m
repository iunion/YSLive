//
//  YSPrizeAlertView.m
//  YSLive
//
//  Created by fzxm on 2019/10/21.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSPrizeAlertView.h"

#define ViewHeight      (356)
#define ViewWidth       (270)
#define ViewBottomGap   (30)


@interface YSPrizeAlertView ()
<
    UITableViewDelegate,
    UITableViewDataSource
>

@property (nonatomic, strong) UIImageView *bacImageView;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation YSPrizeAlertView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.showAnimationType = BMNoticeViewShowAnimationSlideInFromBottom;
        self.noticeMaskBgEffectView.alpha = 1.0;
        self.noticeMaskBgEffect = nil;//[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
//        self.noticeMaskBgColor = [UIColor blackColor];
        self.noticeMaskBgColor = [UIColor bm_colorWithHex:0x000000 alpha:0.6];
        self.shouldDismissOnTapOutside = NO;
//        self.notDismissOnCancel = YES;
    }
    return self;
}


#pragma mark -
#pragma mark Data

- (void)setDataSource:(NSMutableArray<NSString *> *)dataSource
{
    _dataSource = dataSource;
//    [self.rollCollectionView reloadData];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark UICollectionViewDataSource

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.dataSource.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    RollCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RollCollectionCell" forIndexPath:indexPath];
//    cell.nameLabel.text = self.dataSource[indexPath.row];
//    return cell;
//}
//
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(20 , 10, 20, 10);
//}


#pragma mark -
#pragma mark SEL

+ (YSPrizeAlertView *)showPrizeWithStatus:(BOOL)isResult inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance
{
    YSPrizeAlertView * alert = [[YSPrizeAlertView alloc] init];
    alert.topDistance = topDistance;
    alert.backgroundEdgeInsets = backgroundEdgeInsets;
    if (isResult)
    {//YES 中奖名单
        [alert.bacImageView setImage:[UIImage imageNamed:@"prizeAlert_result"]];
//        alert.topDistance = topDistance;//UI_SCREEN_HEIGHT - ViewBottomGap - ViewHeight;
        alert.bacImageView.bm_height = ViewHeight;
        alert.bacImageView.bm_width = ViewWidth;
        
        [alert.bacImageView addSubview:alert.cancelBtn];
        alert.cancelBtn.bm_right = alert.bacImageView.bm_right - 30;
        alert.cancelBtn.bm_top = alert.bacImageView.bm_top + 20;
        alert.cancelBtn.bm_size = CGSizeMake(12, 12);
        
        [alert.bacImageView addSubview:alert.tableView];
        [alert.tableView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
            make.bottom.bmmas_equalTo(alert.bacImageView.bmmas_bottom).bmmas_offset(-15);
            make.left.bmmas_equalTo(alert.bacImageView.bmmas_left).bmmas_offset(19);
            make.right.bmmas_equalTo(alert.bacImageView.bmmas_right).bmmas_offset(-19);
            make.height.bmmas_equalTo(200);
        }];
        
    }
    else
    {
        [alert.bacImageView setImage:[UIImage imageNamed:@"prizeAlert_waiting"]];
//        alert.topDistance = topDistance;
        alert.bacImageView.bm_height = 196;
        alert.bacImageView.bm_width = 224;
        UILabel * ingLabel = [[UILabel alloc] init];
        ingLabel.text = YSLocalized(@"Label.Lucky");
        ingLabel.font = [UIFont boldSystemFontOfSize:23];
        ingLabel.textColor = [UIColor bm_colorWithHex:0xFFE895];
        ingLabel.textAlignment = NSTextAlignmentCenter;
        [alert.bacImageView addSubview:ingLabel];
        ingLabel.frame = CGRectMake(0, 35, 92, 32);
        ingLabel.bm_centerX = alert.bacImageView.bm_centerX + 15;
        
        
    }
    
    [alert showWithView:alert.bacImageView inView:inView];
    return alert;
}

- (void)cancelBtn:(UIButton *)btn
{
    [self dismiss:btn];
}


#pragma mark -
#pragma mark Lazy

- (UIImageView *)bacImageView
{
    if (!_bacImageView)
    {
        _bacImageView = [[UIImageView alloc] init];
        _bacImageView.userInteractionEnabled = YES;
    }
    
    return _bacImageView;
}

#pragma mark - tableViewDelegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    static NSString * cellKey = @"YSPrizeAlertViewTableViewCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellKey];
        cell.backgroundColor = UIColor.clearColor;
    }
    
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 14);
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    cell.detailTextLabel.textColor = UIColor.whiteColor;
    cell.detailTextLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12);
    cell.detailTextLabel.text = self.endTime;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (UITableView *)tableView
{
    if (!_tableView)
    {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style: UITableViewStylePlain];
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.separatorColor = UIColor.whiteColor;
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}


- (UIButton *)cancelBtn
{
    if (!_cancelBtn)
    {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:[UIImage imageNamed:@"yslive_cancelbtn_close"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

@end
