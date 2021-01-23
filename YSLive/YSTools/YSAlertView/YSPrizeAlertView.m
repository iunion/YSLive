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
@interface YSPrizeResultTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *bacView;
@property (nonatomic, strong) UILabel *nameL;
@property (nonatomic, strong) UILabel *timeL;

@end


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
        self.noticeMaskBgEffect = nil;
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
        [alert.bacImageView setImage:YSSkinElementImage(@"live_prizeAlert_result", @"iconNor")];
        alert.bacImageView.bm_height = ViewHeight;
        alert.bacImageView.bm_width = ViewWidth;
        
        [alert.bacImageView addSubview:alert.cancelBtn];
        alert.cancelBtn.bm_right = alert.bacImageView.bm_right - 10;
        alert.cancelBtn.bm_top = alert.bacImageView.bm_top + 10;
        alert.cancelBtn.bm_size = CGSizeMake(12, 12);
        
        UIView *tempView = [[UIView alloc] init];
        tempView.backgroundColor = [UIColor clearColor];
        tempView.frame = CGRectMake(14, ViewHeight-15-200, ViewWidth-28, 200);
        [alert.bacImageView addSubview:tempView];
        [tempView bm_connerWithRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(24.0f, 24.0f)];
        
        [tempView addSubview:alert.tableView];
        alert.tableView.frame = CGRectMake(0, 0, ViewWidth-28, 200);

        UILabel * ingLabel = [[UILabel alloc] init];
        ingLabel.text = YSLocalized(@"Label.LuckyResult");
        ingLabel.font = [UIFont boldSystemFontOfSize:16];
        ingLabel.textColor = YSSkinElementColor(@"live_prizeAlert_result", @"tittleColor");
        ingLabel.textAlignment = NSTextAlignmentCenter;
        [alert.bacImageView addSubview:ingLabel];
        ingLabel.frame = CGRectMake(19, ViewHeight-15-200-22-5, ViewWidth-38, 22);
        
    }
    else
    {
        [alert.bacImageView setImage:YSSkinElementImage(@"live_prizeAlert_waiting", @"iconNor")];
        alert.bacImageView.bm_height = 150;
        alert.bacImageView.bm_width = 150;
        UILabel * ingLabel = [[UILabel alloc] init];
        ingLabel.text = YSLocalized(@"Label.Lucky");
        ingLabel.font = [UIFont boldSystemFontOfSize:20];
        ingLabel.textColor = YSSkinElementColor(@"live_prizeAlert_waiting", @"tittleColor");
        ingLabel.textAlignment = NSTextAlignmentCenter;
        [alert.bacImageView addSubview:ingLabel];
        ingLabel.frame = CGRectMake(0, 15, 92, 32);
        ingLabel.bm_centerX = alert.bacImageView.bm_centerX;
        
        
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
    
    YSPrizeResultTableViewCell * resultCell = [tableView dequeueReusableCellWithIdentifier:@"YSPrizeResultTableViewCell" forIndexPath:indexPath];
    resultCell.nameL.text = self.dataSource[indexPath.row];
    resultCell.timeL.text = self.endTime;
    
    return resultCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style: UITableViewStylePlain];
        _tableView.separatorColor = UIColor.clearColor;
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[YSPrizeResultTableViewCell class] forCellReuseIdentifier:@"YSPrizeResultTableViewCell"];

    }
    return _tableView;
}


- (UIButton *)cancelBtn
{
    if (!_cancelBtn)
    {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:YSSkinElementImage(@"live_prizeAlert_close", @"iconNor") forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

@end


@implementation YSPrizeResultTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    UIView *bacView = [[UIView alloc] init];
    bacView.backgroundColor = [YSSkinDefineColor(@"Color3") bm_changeAlpha:0.5f];
    [self.contentView addSubview:bacView];
    CGFloat tempWidth = ViewWidth - 28;
    bacView.frame = CGRectMake(0, 0, tempWidth, 25);
    self.bacView = bacView;
    
    UILabel *nameL = [[UILabel alloc] init];
    nameL.textColor = YSSkinDefineColor(@"PlaceholderColor");
    nameL.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12);
    [self.contentView addSubview:nameL];
    nameL.frame = CGRectMake(20, 0, (tempWidth - 40)*0.5f, 25);
    self.nameL = nameL;
    
    UILabel *timeL = [[UILabel alloc] init];
    timeL.textColor = YSSkinDefineColor(@"PlaceholderColor");
    timeL.textAlignment = NSTextAlignmentRight;
    timeL.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12);
    [self.contentView addSubview:timeL];
    timeL.frame = CGRectMake(CGRectGetMaxX(nameL.frame), 0, (tempWidth - 40)*0.5f, 25);
    
    self.timeL = timeL;
    
}

@end
