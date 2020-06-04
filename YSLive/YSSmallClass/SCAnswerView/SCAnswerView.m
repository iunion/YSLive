//
//  SCAnswerView.m
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCAnswerView.h"
#import "SCOptionCollectionCell.h"
#import "SCStatisticsTableViewCell.h"
#import "SCAnswerDetailTableViewCell.h"
#import "SCAnswerStatisticsModel.h"
#import "SCAnswerPageView.h"
#import "SCAnswerDetailModel.h"
#import "SCAnswerTBHeaderView.h"

static const CGFloat kAnswerViewWidth_iPhone = 300.0f;
static const CGFloat kAnswerViewWidth_iPad = 308.0f;
#define AnswerViewWidth        ([UIDevice bm_isiPad] ? kAnswerViewWidth_iPad : kAnswerViewWidth_iPhone)

static const CGFloat kAnswerViewHeight_iPhone = 180.0f;
static const CGFloat kAnswerViewHeight_iPad = 226.0f;
#define AnswerViewHeight       ([UIDevice bm_isiPad] ? kAnswerViewHeight_iPad : kAnswerViewHeight_iPhone)

static const CGFloat kCollectionViewHeight_iPhone = 80.0f;
static const CGFloat kCollectionViewHeight_iPad = 120.0f;
#define AnswerCollectionViewHeight       ([UIDevice bm_isiPad] ? kCollectionViewHeight_iPad : kCollectionViewHeight_iPhone)

#define AnswerCollectionCellHeight       (50.0f)

#define ViewHeight      AnswerViewHeight
#define ViewWidth       AnswerViewWidth

#define answerTitleHeight     (30.0f)
@interface SCAnswerView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UITableViewDelegate,
    UITableViewDataSource
>

@property (nonatomic, assign) SCAnswerViewType answerViewType;
/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 顶部蓝色条形view
@property (nonatomic, strong) UILabel *topView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;

//* 答题中 */
/// 答题中 选项视图
@property (nonatomic, strong) UICollectionView *optionCollectionView;
/// 提示文字
@property (nonatomic, strong) UILabel *promptL;
/// 提交答案
@property (nonatomic, strong) UIButton *putBtn;
/// 选项图片数组默认
@property (nonatomic, strong) NSMutableArray *answerIngArr;


//* 统计  详情 */
/// 答题人数
@property (nonatomic, strong) UILabel *personNumL;
/// 用时
@property (nonatomic, strong) UILabel *timeL;
/// 查看详情 统计按钮
@property (nonatomic, strong) UIButton *topBtn;
/// 表格主体
@property (nonatomic, strong) UITableView *resultTableView;
/// 我的答案 以及正确答案
@property (nonatomic, strong) UILabel *resultLable;
///// 翻页view
//@property (nonatomic, strong) SCAnswerPageView *pageView;
/// 统计
@property (nonatomic, strong) NSMutableArray *statisticsArr;
/// 详情数据
@property (nonatomic, strong) NSMutableArray *detailArr;
//
//@property (nonatomic, assign) NSUInteger currentPage;

/// 提交答案次数 （
@property (nonatomic, assign) BOOL isFirstSubmit;//第一次 = YES  之后每次都走修改答案为NO
@property (nonatomic, strong) NSMutableArray *lastResultArr;

///
@property (nonatomic, strong) NSString *rightResultStr;
@property (nonatomic, strong) NSString *myResultStr;
@end

@implementation SCAnswerView

- (instancetype)init
{
    NSUInteger noticeViewCount = [[BMNoticeViewStack sharedInstance] getNoticeViewCount];
    if (noticeViewCount >= BMNOTICEVIEW_MAXSHOWCOUNT)
    {
        return nil;
    }
    self = [super init];
    if (self)
    {
        self.showAnimationType = BMNoticeViewShowAnimationNone;
        self.noticeMaskBgEffect = nil;
        self.shouldDismissOnTapOutside = NO;

    }
    return self;
}

- (void)showWithAnswerViewType:(SCAnswerViewType)answerViewType inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance
{
    
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    self.answerViewType = answerViewType;

    self.isFirstSubmit = YES;
    self.rightResultStr = @"";
    self.myResultStr = @"";
    
    self.bacView.bm_width = ViewWidth;
    self.bacView.bm_height = ViewHeight;
    [self.bacView bm_roundedRect:10.0f];
    
    [self.bacView addSubview:self.topView];
    self.topView.frame = CGRectMake(0, 0, self.bacView.bm_width, answerTitleHeight);
    
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 10, 10);
    self.closeBtn.bm_right = self.topView.bm_right - 10;
    self.closeBtn.bm_centerY = self.topView.bm_centerY;
    
    if (answerViewType == SCAnswerViewType_AnswerIng)
    {
        
        [self.bacView addSubview:self.optionCollectionView];
        self.optionCollectionView.frame = CGRectMake(0, answerTitleHeight, self.bacView.bm_width, AnswerCollectionViewHeight);

        [self.bacView addSubview:self.promptL];
        self.promptL.frame = CGRectMake(10, CGRectGetMaxY(self.optionCollectionView.frame) + 5, self.bacView.bm_width - 120, 15);

        [self.bacView addSubview:self.putBtn];
        self.putBtn.frame = CGRectMake(0, 0, 85, 28);
        self.putBtn.bm_right = self.bacView.bm_right - 15;
        self.putBtn.bm_bottom = self.bacView.bm_bottom - 7;
        self.putBtn.layer.cornerRadius = 14;
    }
    else
    {
        [self.bacView addSubview:self.personNumL];
        self.personNumL.frame = CGRectMake(10, CGRectGetMaxY(self.topView.frame) + 10, 80, 15);
        
        [self.bacView addSubview:self.timeL];
//        self.timeL.frame = CGRectMake(CGRectGetMaxX(self.personNumL.frame) + 5, CGRectGetMaxY(self.topView.frame) + 24, 100, 25);
        self.timeL.frame = CGRectMake(0, 0, 80, 15);
        self.timeL.bm_centerY = self.personNumL.bm_centerY;
        self.timeL.bm_centerX = self.bacView.bm_centerX;
        
        [self.bacView addSubview:self.topBtn];
        self.topBtn.frame = CGRectMake(0, 0, 60, 24);
        self.topBtn.bm_top = self.topView.bm_bottom + 7;
        self.topBtn.bm_right = self.bacView.bm_right - 10;
        self.topBtn.layer.cornerRadius = 12;
        self.topBtn.layer.masksToBounds = YES;

        [self.bacView addSubview:self.resultLable];
        self.resultLable.frame = CGRectMake(10, 0, self.bacView.bm_width - 30 , 15);
        self.resultLable.bm_bottom = self.bacView.bm_bottom - 10;
        
        [self.bacView addSubview:self.resultTableView];
        self.resultTableView.frame = CGRectMake(0, CGRectGetMaxY(self.timeL.frame) + 10 ,self.bacView.bm_width , 90);
        self.resultTableView.frame = CGRectMake(0, 0 ,self.bacView.bm_width , 0);
        [self.resultTableView bm_setTop:self.timeL.bm_bottom + 5 bottom:self.resultLable.bm_top - 5];
        
        
        if (answerViewType == SCAnswerViewType_Statistics)
        {
            [self.topBtn setTitle:YSLocalized(@"tool.detail") forState:UIControlStateNormal];
        }
        else
        {
            [self.topBtn setTitle:YSLocalized(@"tool.tongji") forState:UIControlStateNormal];
        }
        
    }
    [self showWithView:self.bacView inView:inView];
}


#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.answerIngArr.count;
}
 
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SCOptionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SCOptionCollectionCell" forIndexPath:indexPath];
    [cell setDataDic:self.answerIngArr[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.answerViewType == SCAnswerViewType_AnswerIng)
    {
        NSDictionary * dic = self.answerIngArr[indexPath.row];
        if (self.isSingle)
        {
            for (int i = 0; i < self.answerIngArr.count; i++)
            {
                if (i == indexPath.row)
                {
                    NSInteger isSelected = [dic[@"isselect"] integerValue];
                    [dic setValue:isSelected == 0 ? @"1" : @"0" forKey:@"isselect"];
                    continue;
                }
                NSDictionary * tempDic = self.answerIngArr[i];
                [tempDic setValue:@"0" forKey:@"isselect"];
            }
        }
        else
        {
            NSInteger isSelected = [dic[@"isselect"] integerValue];
            [dic setValue:isSelected == 0 ? @"1" : @"0" forKey:@"isselect"];
        }
        
        [collectionView reloadData];
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (self.answerViewType)
    {
        case SCAnswerViewType_Statistics:
        {
            return self.statisticsArr.count;
        }
            break;
        case SCAnswerViewType_Details:
        {
            if (self.detailArr.count == 0)
            {
                return 0;
            }
            return self.detailArr.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.answerViewType)
    {
        case SCAnswerViewType_Statistics:
        {
            SCStatisticsTableViewCell * statisticsCell = [tableView dequeueReusableCellWithIdentifier:@"SCStatisticsTableViewCell" forIndexPath:indexPath];
            statisticsCell.resultModel = self.statisticsArr[indexPath.row];
            return statisticsCell;
        }
            break;
        case SCAnswerViewType_Details:
        {
        
            SCAnswerDetailTableViewCell * detailsCell = [tableView dequeueReusableCellWithIdentifier:@"SCAnswerDetailTableViewCell" forIndexPath:indexPath];
            detailsCell.detailModel = self.detailArr[indexPath.row];
            return detailsCell;
            
        }
            break;
        default:
            break;
    }
    UITableViewCell * cell = [UITableViewCell new];
    return cell;
   
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.answerViewType == SCAnswerViewType_Details) {
    
        SCAnswerDetailModel * titleModel = [SCAnswerDetailModel new];
        titleModel.name = YSLocalized(@"Label.UserNickname");
        titleModel.time = YSLocalized(@"tool.time");
        titleModel.result = YSLocalized(@"tool.choose");
        SCAnswerTBHeaderView *answerTBHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SCAnswerTBHeaderView"];
   
        answerTBHeaderView.detailModel = titleModel;
    
        return answerTBHeaderView;
    
    }
    return [UIView new];
}
#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.answerViewType)
    {
        case SCAnswerViewType_Statistics:
        {
            return 18;
        }
            break;
        case SCAnswerViewType_Details:
        {
            return 25;
        }
            break;
        default:
            break;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.answerViewType == SCAnswerViewType_Statistics) {
        return CGFLOAT_MIN;
    }
    return 25;
}

#pragma mark - Setter
- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    
    if (self.answerViewType == SCAnswerViewType_AnswerIng)
    {
//        self.closeBtn.hidden = YES;
        NSArray * answerNormalImgs = @[@"sc_answer_a_normal",@"sc_answer_b_normal",@"sc_answer_c_normal",@"sc_answer_d_normal",@"sc_answer_e_normal",@"sc_answer_f_normal",@"sc_answer_g_normal",@"sc_answer_h_normal"];
        NSArray * answerSelectedImgs = @[@"sc_answer_a_selected",@"sc_answer_b_selected",@"sc_answer_c_selected",@"sc_answer_d_selected",@"sc_answer_e_selected",@"sc_answer_f_selected",@"sc_answer_g_selected",@"sc_answer_h_selected"];
        
        for (int i = 0; i < dataSource.count; i++)
        {
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setValue:answerNormalImgs[i] forKey:@"normalImgs"];
            [dic setValue:answerSelectedImgs[i] forKey:@"selectedImgs"];
            [dic setValue:@"0" forKey:@"isselect"];
            NSString *option = dataSource[i][@"content"];
            NSString *isRight = dataSource[i][@"isRight"];
            [dic setValue:option forKey:@"option"];
            [dic setValue:isRight forKey:@"isRight"];
            [self.answerIngArr addObject:dic];
        }
        [self.optionCollectionView reloadData];
    }
}

- (void)setAnswerResultWithStaticsDic:(NSDictionary *)staticsDic detailArr:(NSArray *)detailArr duration:(NSString *)duration myResult:(NSArray *)myResult rightOption:(NSString *)rightOption totalUsers:(NSUInteger)totalUsers
{
    
    if (![staticsDic bm_isNotEmpty])
    {
        return;
    }
//    self.closeBtn.hidden = NO;
    NSUInteger totalNumber = totalUsers > 0 ? totalUsers : 0;

    for (int i = 0; i <staticsDic.allKeys.count ; i++)
    {
        SCAnswerStatisticsModel *model = [SCAnswerStatisticsModel new];
        NSString *key = staticsDic.allKeys[i];
        model.number = staticsDic[key];
        model.total = [NSString stringWithFormat:@"%@",@(totalNumber)];
        model.title = key;
        [self.statisticsArr addObject:model];
    }
    [self.statisticsArr sortUsingComparator:^NSComparisonResult(SCAnswerStatisticsModel * _Nonnull obj1, SCAnswerStatisticsModel * _Nonnull obj2) {
        
        return [obj1.title compare:obj2.title];
    }];
    
    NSString *myResultStr = @"";
    for (NSString * tempStr in myResult)
    {
        myResultStr = [myResultStr stringByAppendingFormat:@"%@,",tempStr];
    }
    if ([myResultStr bm_isNotEmpty])
    {
        myResultStr = [myResultStr substringWithRange:NSMakeRange(0, myResultStr.length - 1)];//我的答案
    }
    self.myResultStr = myResultStr;
    self.rightResultStr = rightOption;
    
    self.personNumL.text = [NSString stringWithFormat:@"%@: %@%@",YSLocalized(@"tool.datirenshu"),@(totalNumber),YSLocalized(@"tool.ren")];
    self.timeL.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.time"),duration];
    self.resultLable.text = [NSString stringWithFormat:@"%@: %@      %@: %@",YSLocalized(@"tool.zhengquedaan"),rightOption,YSLocalized(@"tool.wodedaan"),myResultStr];
    

    for (int i = 0; i < detailArr.count; i++)
    {
        NSString *name = detailArr[i][@"studentname"];
        NSString *time = detailArr[i][@"timestr"];
        NSString *resultStr = detailArr[i][@"selectOpts"];

        SCAnswerDetailModel * model = [SCAnswerDetailModel new];
        model.name = name;
        model.time = time;
        model.result = resultStr;
        [self.detailArr addObject:model];
    }
    [self.resultTableView reloadData];

}



#pragma mark - SEL
- (void)closeBtnClicked:(UIButton *)btn
{
    [self dismiss:btn];
}

- (void)putBtnClicked:(UIButton *)btn
{

    btn.selected  = !btn.selected;
    self.optionCollectionView.allowsSelection = !btn.selected;
    NSMutableArray * resaultS = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.answerIngArr.count; i++)
    {
        NSDictionary * dic = self.answerIngArr[i];
        if ([dic[@"isselect"] integerValue] == 1)
        {
            NSString *option = dic[@"option"];
            [resaultS addObject:option];
        }
    }
    
    if (resaultS.count == 0)
    {
        btn.selected = NO;
        self.optionCollectionView.allowsSelection = YES;
        return;
    }
    
    
    if (!btn.selected)
    {
        /// 未选中状态下 将 选项全部变为 未选中
        for (NSDictionary * dic in self.answerIngArr)
        {
            [dic setValue:@"0" forKey:@"isselect"];
        }
        [self.optionCollectionView reloadData];
    }
    else
    {
        if (self.isFirstSubmit)
        {
            self.lastResultArr = resaultS;
            if (self.firstSubmitBlock)
            {
                self.isFirstSubmit = NO;
                self.firstSubmitBlock(self.lastResultArr);
            }
        }
        else
        {
            if (self.nextSubmitBlock)
            {
                NSArray *unionArr = [resaultS bm_unionWithArray:self.lastResultArr];

                NSArray *addAnwserResault = [unionArr bm_differenceToArray:self.lastResultArr];
                NSArray *delAnwserResault = [unionArr bm_differenceToArray:resaultS];
                NSArray *notChangeAnwserResault = [resaultS bm_intersectionWithArray:self.lastResultArr];
                self.nextSubmitBlock(addAnwserResault, delAnwserResault, notChangeAnwserResault);
                self.lastResultArr = resaultS;
            }
        }
    }
    
    
}

- (void)topBtnClicked:(UIButton *)btn
{
    if (self.answerViewType == SCAnswerViewType_Statistics)
    {
        [self sc_setAnswerViewType:SCAnswerViewType_Details];
    }
    else if (self.answerViewType == SCAnswerViewType_Details)
    {
        [self sc_setAnswerViewType:SCAnswerViewType_Statistics];
    }

}
- (void)sc_setAnswerViewType:(SCAnswerViewType)answerViewType
{
    self.answerViewType = answerViewType;
    switch (self.answerViewType)
    {
        case SCAnswerViewType_Statistics:
        {
            [self.topBtn setTitle:YSLocalized(@"tool.detail") forState:UIControlStateNormal];
            self.resultLable.text = [NSString stringWithFormat:@"%@: %@      %@: %@",YSLocalized(@"tool.zhengquedaan"),self.rightResultStr,YSLocalized(@"tool.wodedaan"),self.myResultStr];
        }
            break;
        case SCAnswerViewType_Details:
        {
            [self.topBtn setTitle:YSLocalized(@"tool.tongji") forState:UIControlStateNormal];
            self.resultLable.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.wodedaan"),self.myResultStr];
        }
            break;
        default:
            break;
    }
    [self.resultTableView reloadData];
}

#pragma mark - Lazy

- (UIView *)bacView
{
    if (!_bacView)
    {
        _bacView = [[UIView alloc] init];
        _bacView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    }
    return _bacView;
}

- (UILabel *)topView
{
    if (!_topView)
    {
        _topView = [[UILabel alloc] init];
        _topView.textAlignment = NSTextAlignmentCenter;
//        _topView.lineBreakMode = NSLineBreakByCharWrapping;
        _topView.textColor = YSSkinDefineColor(@"defaultTitleColor");
        _topView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        _topView.font = UI_FONT_12;
        _topView.text = YSLocalized(@"tool.datiqiqi");
    }
    
    return _topView;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn)
    {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:YSSkinDefineImage(@"close_btn_icon") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hidden = YES;
    }
    
    return _closeBtn;
}
- (UICollectionView *)optionCollectionView
{
    if (!_optionCollectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake(AnswerCollectionCellHeight, AnswerCollectionCellHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _optionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _optionCollectionView.delegate = self; //设置代理
        _optionCollectionView.dataSource = self;   //设置数据来源
        _optionCollectionView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
//        _optionCollectionView.bounces = YES;
        _optionCollectionView.alwaysBounceVertical = YES;
        _optionCollectionView.showsVerticalScrollIndicator = NO;
        [_optionCollectionView registerClass:[SCOptionCollectionCell class] forCellWithReuseIdentifier:@"SCOptionCollectionCell"];
    }
    
    return _optionCollectionView;
}

- (UILabel *)promptL
{
    if (!_promptL)
    {
        _promptL = [[UILabel alloc] init];
        _promptL.textAlignment = NSTextAlignmentLeft;
        _promptL.textColor = YSSkinDefineColor(@"defaultTitleColor");
        _promptL.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        _promptL.font = UI_FONT_8;
        _promptL.text = YSLocalized(@"tool.leastanswer");
    }
    
    return _promptL;
}

- (UIButton *)putBtn
{
    if (!_putBtn)
    {
        _putBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_putBtn setBackgroundColor:YSSkinDefineColor(@"defaultSelectedBgColor")];
        [_putBtn setTitle:YSLocalized(@"tool.submit") forState:UIControlStateNormal];
        [_putBtn setTitle:YSLocalized(@"tool.modify") forState:UIControlStateSelected];
        [_putBtn setTitleColor:YSSkinDefineColor(@"defaultTitleColor") forState:UIControlStateNormal];
        [_putBtn setTitleColor:YSSkinDefineColor(@"defaultTitleColor") forState:UIControlStateHighlighted];
        _putBtn.titleLabel.font = UI_FONT_12;
        [_putBtn addTarget:self action:@selector(putBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _putBtn;
}

- (UILabel *)personNumL
{
    if (!_personNumL)
    {
        _personNumL = [[UILabel alloc] init];
        _personNumL.textAlignment = NSTextAlignmentLeft;
        _personNumL.textColor = YSSkinDefineColor(@"defaultTitleColor");
        _personNumL.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        _personNumL.font = UI_FONT_10;
    }

    return _personNumL;
}

- (UILabel *)timeL
{
    if (!_timeL)
    {
        _timeL = [[UILabel alloc] init];
        _timeL.textAlignment = NSTextAlignmentCenter;
        _timeL.textColor = YSSkinDefineColor(@"defaultTitleColor");
        _timeL.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        _timeL.font = UI_FONT_10;
    }
    return _timeL;
}

- (UIButton *)topBtn
{
    if (!_topBtn)
    {
        _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topBtn setTitleColor:YSSkinDefineColor(@"defaultTitleColor") forState:UIControlStateNormal];
        [_topBtn setBackgroundColor:YSSkinDefineColor(@"defaultSelectedBgColor")];
        _topBtn.titleLabel.font = UI_FONT_10;
        _topBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_topBtn addTarget:self action:@selector(topBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBtn;
}

- (UITableView *)resultTableView
{
    if (!_resultTableView)
     {
         _resultTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
         _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
         _resultTableView.delegate = self;
         _resultTableView.dataSource = self;
         _resultTableView.showsVerticalScrollIndicator = YES;
         _resultTableView.alwaysBounceVertical = NO;
    
         _resultTableView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
         [_resultTableView registerClass:[SCAnswerDetailTableViewCell class] forCellReuseIdentifier:@"SCAnswerDetailTableViewCell"];
         [_resultTableView registerClass:[SCStatisticsTableViewCell class] forCellReuseIdentifier:@"SCStatisticsTableViewCell"];
         [_resultTableView registerClass:[SCAnswerTBHeaderView class] forHeaderFooterViewReuseIdentifier:@"SCAnswerTBHeaderView"];
     }
    
     return _resultTableView;
}

- (UILabel *)resultLable
{
    if (!_resultLable)
    {
        _resultLable = [[UILabel alloc] init];
        _resultLable.textAlignment = NSTextAlignmentLeft;
        _resultLable.textColor = YSSkinDefineColor(@"defaultTitleColor");
        _resultLable.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
        _resultLable.font = UI_FONT_8;
    }
    return _resultLable;
}


- (NSMutableArray *)answerIngArr
{
    if (!_answerIngArr)
    {
        _answerIngArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _answerIngArr;
}

- (NSMutableArray *)statisticsArr
{
    if (!_statisticsArr)
    {
        
        _statisticsArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _statisticsArr;
}

- (NSMutableArray *)detailArr
{
    if (!_detailArr)
    {
        
        _detailArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _detailArr;
}
- (NSMutableArray *)lastResultArr
{
    if (!_lastResultArr)
    {
        
        _lastResultArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _lastResultArr   ;
}
@end



