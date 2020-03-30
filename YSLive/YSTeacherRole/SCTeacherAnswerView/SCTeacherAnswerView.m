//
//  SCTeacherAnswerView.m
//  YSLive
//
//  Created by fzxm on 2019/12/31.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTeacherAnswerView.h"
#import "SCOptionCollectionCell.h"
#import "SCStatisticsTableViewCell.h"
#import "SCAnswerDetailTableViewCell.h"
#import "SCAnswerStatisticsModel.h"
#import "SCAnswerPageView.h"
#import "SCAnswerDetailModel.h"
#import "SCAnswerTBHeaderView.h"

#define ViewHeight      (370)
#define ViewWidth       (679)

@interface SCTeacherAnswerView ()

<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UITableViewDelegate,
    UITableViewDataSource
>


@property (nonatomic, assign) SCTeacherAnswerViewType answerViewType;
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
/// 发布答题
@property (nonatomic, strong) UIButton *putBtn;
/// 添加选项
@property (nonatomic, strong) UIButton *addBtn;
/// 删除选项
@property (nonatomic, strong) UIButton *delBtn;
/// 选项数组
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
/// 公开答案
@property (nonatomic, strong) UIButton *openResultBtn;
/// 结束答题以及重新开始
@property (nonatomic, strong) UIButton *endAgainBtn;
///// 翻页view
//@property (nonatomic, strong) SCAnswerPageView *pageView;
/// 统计
@property (nonatomic, strong) NSMutableArray *statisticsArr;
/// 详情数据
@property (nonatomic, strong) NSMutableArray *detailArr;
///正确答案
@property (nonatomic, strong) NSString *rightResultStr;
@end

@implementation SCTeacherAnswerView

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


- (void)showTeacherAnswerViewType:(SCTeacherAnswerViewType)answerViewType inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance
{
    
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    self.answerViewType = answerViewType;

    self.rightResultStr = @"";
    

    if ([UIDevice bm_isiPad])
    {
        self.bacView.bm_width = ViewWidth;
        self.bacView.bm_height = ViewHeight;
    }
    else
    {
        self.bacView.bm_width = BMUI_SCREEN_WIDTH - 100;
        self.bacView.bm_height = BMUI_SCREEN_HEIGHT - 80;
    }
    [self.bacView bm_roundedRect:10.0f];
    
    [self.bacView addSubview:self.topView];
    self.topView.frame = CGRectMake(0, 0, self.bacView.bm_width, 50);
    
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 18, 18);
    self.closeBtn.bm_right = self.topView.bm_right - 15;
    self.closeBtn.bm_centerY = self.topView.bm_centerY;
    
    if (answerViewType == SCTeacherAnswerViewType_AnswerPub)
    {
        
        [self.bacView addSubview:self.optionCollectionView];
        self.optionCollectionView.frame = CGRectMake(0, 50, self.bacView.bm_width, 158);

        [self.bacView addSubview:self.addBtn];
        self.addBtn.frame = CGRectMake(0, 0, 110, 40);
        self.addBtn.bm_left = self.bacView.bm_left + 70;
        self.addBtn.bm_top = self.optionCollectionView.bm_bottom + 5;
        self.addBtn.layer.cornerRadius = 20;
        
        [self.bacView addSubview:self.delBtn];
        self.delBtn.frame = CGRectMake(0, 0, 110, 40);
        self.delBtn.bm_left = self.addBtn.bm_right + 50;
        self.delBtn.bm_top = self.optionCollectionView.bm_bottom + 5;
        self.delBtn.layer.cornerRadius = 20;
        
        [self.bacView addSubview:self.promptL];
        self.promptL.frame = CGRectMake(70, CGRectGetMaxY(self.delBtn.frame) + 15, self.bacView.bm_width - 140, 25);

        [self.bacView addSubview:self.putBtn];
        self.putBtn.frame = CGRectMake(0, 0, 147, 40);
        self.putBtn.bm_right = self.bacView.bm_right - 36;
        self.putBtn.bm_bottom = self.bacView.bm_bottom - 34;
        [self.putBtn bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
        [self creatDataSource];
    }
    else
    {
        [self.bacView addSubview:self.personNumL];
        self.personNumL.frame = CGRectMake(30, CGRectGetMaxY(self.topView.frame) + 22, 130, 25);
        
        [self.bacView addSubview:self.timeL];
        self.timeL.frame = CGRectMake(0, 0, 100, 25);
        self.timeL.bm_centerY = self.personNumL.bm_centerY;
        self.timeL.bm_centerX = self.bacView.bm_centerX;

        [self.bacView addSubview:self.topBtn];
        self.topBtn.frame = CGRectMake(0, 0, 94, 32);
        self.topBtn.bm_top = self.topView.bm_bottom + 19;
        self.topBtn.bm_right = self.bacView.bm_right - 30;
        self.topBtn.layer.cornerRadius = 16;
        self.topBtn.layer.masksToBounds = YES;

        

        [self.topBtn setTitle:YSLocalized(@"tool.detail") forState:UIControlStateNormal];
        
        [self.bacView addSubview:self.openResultBtn];
        self.openResultBtn.frame = CGRectMake(0, 0, 100, 25);
        self.openResultBtn.bm_bottom = self.bacView.bm_bottom - 36;
        self.openResultBtn.bm_centerX = self.bacView.bm_centerX;
        
        [self.bacView addSubview:self.resultLable];
        self.resultLable.frame = CGRectMake(30, 0, 200 , 26);
        self.resultLable.bm_bottom = self.bacView.bm_bottom - 34;
        
        [self.bacView addSubview:self.endAgainBtn];
        self.endAgainBtn.frame = CGRectMake(0, 0, 147, 40);
        self.endAgainBtn.bm_right = self.bacView.bm_right - 36;
        self.endAgainBtn.bm_bottom = self.bacView.bm_bottom - 34;
        [self.endAgainBtn bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
        [self.bacView addSubview:self.resultTableView];
        self.resultTableView.frame = CGRectMake(0, CGRectGetMaxY(self.timeL.frame) + 10 ,self.bacView.bm_width , self.bacView.bm_height - self.timeL.bm_bottom - 10 -  self.bacView.bm_bottom - 100);
        self.resultTableView.bm_top = self.topBtn.bm_bottom + 10;
        [self.resultTableView bm_setTop:self.topBtn.bm_bottom + 10 bottom:self.openResultBtn.bm_top - 20];
        
        

        
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
    if (self.answerViewType == SCTeacherAnswerViewType_AnswerPub)
    {
        NSDictionary * dic = self.answerIngArr[indexPath.row];

        NSInteger isSelected = [dic[@"isselect"] integerValue];
        [dic setValue:isSelected == 0 ? @"1" : @"0" forKey:@"isselect"];
        BOOL isRight = [dic[@"isRight"] boolValue];
        [dic setValue:isRight ? @(NO) : @(YES) forKey:@"isRight"];
        [collectionView reloadData];
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(40 , 70, 20, 70);
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (self.answerViewType)
    {
        case SCTeacherAnswerViewType_Statistics:
        {
            return self.statisticsArr.count;
        }
            break;
        case SCTeacherAnswerViewType_Details:
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
        case SCTeacherAnswerViewType_Statistics:
        {
            SCStatisticsTableViewCell * statisticsCell = [tableView dequeueReusableCellWithIdentifier:@"SCStatisticsTableViewCell" forIndexPath:indexPath];
            statisticsCell.resultModel = self.statisticsArr[indexPath.row];
            return statisticsCell;
        }
            break;
        case SCTeacherAnswerViewType_Details:
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
    if (self.answerViewType == SCTeacherAnswerViewType_Details) {
    
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
        case SCTeacherAnswerViewType_Statistics:
        {
            return 18;
        }
            break;
        case SCTeacherAnswerViewType_Details:
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
    if (self.answerViewType == SCTeacherAnswerViewType_Statistics)
    {
        return CGFLOAT_MIN;
    }
    return 25;
}

#pragma mark - Setter
- (void)creatDataSource
{

        NSArray *dataSource = @[@{@"content":@"A",@"isRight":@(NO)},
                                @{@"content":@"B",@"isRight":@(NO)},
                                @{@"content":@"C",@"isRight":@(NO)},
                                @{@"content":@"D",@"isRight":@(NO)}
                                ];
        NSArray * answerNormalImgs = @[@"sc_answer_a_normal",@"sc_answer_b_normal",@"sc_answer_c_normal",@"sc_answer_d_normal"];
        NSArray * answerSelectedImgs = @[@"sc_answer_a_selected",@"sc_answer_b_selected",@"sc_answer_c_selected",@"sc_answer_d_selected"];

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

- (void)setTimeStr:(NSString *)timeStr
{
    _timeStr = timeStr;
    self.timeL.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.time"),timeStr];
}

- (void)setIsAnswerIng:(BOOL)isAnswerIng
{
    _isAnswerIng = isAnswerIng;
    if (isAnswerIng)
    {
        [self hideOpenResult:NO];
        [self.endAgainBtn setTitle:YSLocalized(@"tool.end") forState:UIControlStateNormal];
    }
    else
    {
        [self hideOpenResult:YES];
        [self.endAgainBtn setTitle:YSLocalized(@"tool.restart") forState:UIControlStateNormal];
    }
    
}

- (void)setAnswerResultWithStaticsDic:(NSDictionary *)staticsDic detailArr:(NSArray *)detailArr duration:(NSString *)duration rightOption:(NSString *)rightOption totalUsers:(NSUInteger)totalUsers
{
    
    if (![staticsDic bm_isNotEmpty])
    {
        return;
    }
    NSUInteger totalNumber = totalUsers > 0 ? totalUsers : 0;
    [self.statisticsArr removeAllObjects];
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
    
    self.rightResultStr = rightOption;
    
    self.personNumL.text = [NSString stringWithFormat:@"%@: %@%@",YSLocalized(@"tool.datirenshu"),@(totalNumber),YSLocalized(@"tool.ren")];
    self.timeL.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.time"),duration];
    self.resultLable.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.zhengquedaan"),rightOption];
    
    [self.detailArr removeAllObjects];
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

- (void)setAnswerStatistics:(NSDictionary *)statisticsDic totalUsers:(NSInteger)totalUsers rightResult:(nonnull NSString *)rightResult
{
    self.rightResultStr = rightResult;
    self.personNumL.text = [NSString stringWithFormat:@"%@: %@%@",YSLocalized(@"tool.datirenshu"),@(totalUsers),YSLocalized(@"tool.ren")];
    self.resultLable.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.zhengquedaan"),rightResult];
    
    [self.statisticsArr removeAllObjects];
    for (int i = 0; i <statisticsDic.allKeys.count ; i++)
    {
        SCAnswerStatisticsModel *model = [SCAnswerStatisticsModel new];
        NSString *key = statisticsDic.allKeys[i];
        model.number = statisticsDic[key];
        model.total = [NSString stringWithFormat:@"%@",@(totalUsers)];
        model.title = key;
        [self.statisticsArr addObject:model];
    }
    [self.statisticsArr sortUsingComparator:^NSComparisonResult(SCAnswerStatisticsModel * _Nonnull obj1, SCAnswerStatisticsModel * _Nonnull obj2) {
        
        return [obj1.title compare:obj2.title];
    }];
    [self.resultTableView reloadData];
}

- (void)setAnswerDetailArr:(NSArray *)answerDetailArr
{
    _answerDetailArr = answerDetailArr;
    [self.detailArr removeAllObjects];
    for (int i = 0; i < answerDetailArr.count; i++)
    {
        NSString *name = answerDetailArr[i][@"studentname"];
        NSString *time = answerDetailArr[i][@"timestr"];
        NSString *resultStr = answerDetailArr[i][@"selectOpts"];

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
    
    if (self.answerViewType == SCTeacherAnswerViewType_AnswerPub)
    {
        if (self.closeBlock)
        {
            self.closeBlock(NO);
        }
        
    }
    else
    {
        if (self.closeBlock)
        {
            self.closeBlock(self.isAnswerIng);
        }
    }
    
    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)addBtnClicked:(UIButton *)btn
{
    if (self.answerIngArr.count >= 8)
    {
        return;
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
   
    NSString *normalImgs  = [NSString stringWithFormat:@"sc_answer_%c_normal",(int)self.answerIngArr.count + 97];
    [dic setValue:normalImgs forKey:@"normalImgs"];
    
    NSString *selectedImgs  = [NSString stringWithFormat:@"sc_answer_%c_selected",(int)self.answerIngArr.count + 97];
    [dic setValue:selectedImgs forKey:@"selectedImgs"];
    [dic setValue:@"0" forKey:@"isselect"];

    NSString *option = [NSString stringWithFormat:@"%c",(int)self.answerIngArr.count + 65];
    [dic setValue:option forKey:@"option"];
    [dic setValue:@(NO) forKey:@"isRight"];
    [self.answerIngArr addObject:dic];
    
    [self freshAnswerIngView];
}

- (void)delBtnClicked:(UIButton *)btn
{
    if (self.answerIngArr.count <= 0)
    {
        return;
    }
    [self.answerIngArr removeLastObject];
    [self freshAnswerIngView];
}

- (void)freshAnswerIngView
{
    if ([UIDevice bm_isiPad])
    {
        if (self.answerIngArr.count > 4)
        {
            
            self.bacView.bm_height = ViewHeight + 70 + 40;
            self.optionCollectionView.bm_height = 232;
            self.addBtn.bm_top = self.optionCollectionView.bm_bottom + 5;
            self.delBtn.bm_top = self.optionCollectionView.bm_bottom + 5;
            self.promptL.bm_top = self.delBtn.bm_bottom + 15;
            self.putBtn.bm_bottom = self.bacView.bm_bottom - 34;
            
        }
        else
        {
            self.bacView.bm_height = ViewHeight;
            self.optionCollectionView.bm_height = 158;
            self.addBtn.bm_top = self.optionCollectionView.bm_bottom + 5;
            self.delBtn.bm_top = self.optionCollectionView.bm_bottom + 5;
            self.promptL.bm_top = self.delBtn.bm_bottom + 15;
            self.putBtn.bm_bottom = self.bacView.bm_bottom - 34;
        }

    }
    
    
    [self.optionCollectionView reloadData];
    [self showWithView:self.bacView inView:self.superview];
}
- (void)putBtnClicked:(UIButton *)btn
{

    NSMutableArray * resaultS = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.answerIngArr.count; i++)
    {
        
        NSDictionary * dic = self.answerIngArr[i];
        NSString *content = [dic bm_stringForKey:@"option"];
        BOOL isRight = [dic bm_boolForKey:@"isRight"];
        [resaultS addObject:@{@"content":content,@"isRight":@(isRight)}];
        
    }
    if (self.submitBlock)
    {
        self.submitBlock(resaultS);
    }

}

- (void)topBtnClicked:(UIButton *)btn
{
    if (self.answerViewType == SCTeacherAnswerViewType_Statistics)
    {
        [self sc_setAnswerViewType:SCTeacherAnswerViewType_Details];
    }
    else if (self.answerViewType == SCTeacherAnswerViewType_Details)
    {
        [self sc_setAnswerViewType:SCTeacherAnswerViewType_Statistics];
    }

}
- (void)sc_setAnswerViewType:(SCTeacherAnswerViewType)answerViewType
{
    self.answerViewType = answerViewType;
    if (self.isAnswerIng)
    {
        if (self.detailBlock)
        {
            self.detailBlock(answerViewType);
        }
    }

    switch (self.answerViewType)
    {
        case SCTeacherAnswerViewType_Statistics:
        {
            [self.topBtn setTitle:YSLocalized(@"tool.detail") forState:UIControlStateNormal];
            

            if (!self.closeBtn.hidden)
            {
                /// 关闭按钮隐藏 意味着不是老师操作
                [self hideEndAgainBtn:NO];
                if (self.isAnswerIng)
                {
                    [self hideOpenResult:NO];
                }
                else
                {
                    [self hideOpenResult:YES];
                }

            }
//            self.resultLable.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.zhengquedaan"),self.rightResultStr];
        }
            break;
        case SCTeacherAnswerViewType_Details:
        {
            if (!self.closeBtn.hidden)
            {
       
                [self hideEndAgainBtn:self.isAnswerIng];
                [self hideOpenResult:YES];

            }

            [self.topBtn setTitle:YSLocalized(@"tool.tongji") forState:UIControlStateNormal];
//            self.resultLable.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"tool.zhengquedaan"),self.rightResultStr];
        }
            break;
        default:
            break;
    }
    [self.resultTableView reloadData];
}

- (void)openResultBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;

}

- (void)endAgainBtnClicked:(UIButton *)btn
{
    if (self.isAnswerIng)
    {
        if (self.endBlock)
        {
            self.endBlock(self.openResultBtn.selected);
        }
    }
    else
    {
        if (self.againBlock)
        {
            self.againBlock();
        }
    }
}

- (void)hideOpenResult:(BOOL)hide
{
    self.openResultBtn.hidden = hide;
}
- (void)hideEndAgainBtn:(BOOL)hide
{
    self.endAgainBtn.hidden = hide;
}
- (void)hideCloseBtn:(BOOL)hide
{
    self.closeBtn.hidden = hide;
}
#pragma mark - Lazy

- (UIView *)bacView
{
    if (!_bacView)
    {
        _bacView = [[UIView alloc] init];
        _bacView.backgroundColor = [UIColor whiteColor];
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
        _topView.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
        _topView.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
        _topView.font = [UIFont systemFontOfSize:16];
        _topView.text = YSLocalized(@"tool.datiqiqi");
    }
    
    return _topView;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn)
    {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hidden = NO;
    }
    
    return _closeBtn;
}

- (UICollectionView *)optionCollectionView
{
    if (!_optionCollectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 30;
        layout.minimumInteritemSpacing = 80;
        layout.itemSize = CGSizeMake(74, 74);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _optionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _optionCollectionView.delegate = self; //设置代理
        _optionCollectionView.dataSource = self;   //设置数据来源
        _optionCollectionView.backgroundColor = [UIColor whiteColor];
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
        _promptL.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _promptL.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF];
        _promptL.font = [UIFont systemFontOfSize:12];
        _promptL.text = YSLocalized(@"tool.leastanswer");
    }
    
    return _promptL;
}

- (UIButton *)addBtn
{
    if (!_addBtn)
    {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn setBackgroundColor:[UIColor bm_colorWithHex:0x82ABEC]];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _addBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_addBtn setTitle:YSLocalized(@"tool.tianjia") forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _addBtn;
}

- (UIButton *)delBtn
{
    if (!_delBtn)
    {
        _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_delBtn setBackgroundColor:[UIColor bm_colorWithHex:0x82ABEC]];
        _delBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _delBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_delBtn setTitle:YSLocalized(@"tool.shanchu") forState:UIControlStateNormal];
        [_delBtn addTarget:self action:@selector(delBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _delBtn;
}

- (UIButton *)putBtn
{
    if (!_putBtn)
    {
        _putBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_putBtn setBackgroundColor:[UIColor bm_colorWithHex:0x5A8CDC]];
        [_putBtn setTitle:YSLocalized(@"tool.fabudati") forState:UIControlStateNormal];
        [_putBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
        _putBtn.titleLabel.font = [UIFont systemFontOfSize:18];
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
        _personNumL.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _personNumL.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF];
        _personNumL.font = [UIFont systemFontOfSize:12];
    }

    return _personNumL;
}

- (UILabel *)timeL
{
    if (!_timeL)
    {
        _timeL = [[UILabel alloc] init];
        _timeL.textAlignment = NSTextAlignmentCenter;
        _timeL.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _timeL.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF];
        _timeL.font = [UIFont systemFontOfSize:12];
    }
    return _timeL;
}

- (UIButton *)topBtn
{
    if (!_topBtn)
    {
        _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_topBtn setBackgroundColor:[UIColor bm_colorWithHex:0x5A8CDC]];
        _topBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _topBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_topBtn addTarget:self action:@selector(topBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBtn;
}
- (UIButton *)openResultBtn
{
    if (!_openResultBtn)
    {
        _openResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openResultBtn setTitleColor:[UIColor bm_colorWithHex:0x5A8CDC] forState:UIControlStateNormal];
        [_openResultBtn setImage:[UIImage imageNamed:@"sc_answer_openresult_normal"] forState:UIControlStateNormal];
        [_openResultBtn setImage:[UIImage imageNamed:@"sc_answer_openresult_selected"] forState:UIControlStateSelected];
        [_openResultBtn setTitle:YSLocalized(@"tool.publish") forState:UIControlStateNormal];
        _openResultBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _openResultBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_openResultBtn addTarget:self action:@selector(openResultBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_openResultBtn bm_layoutButtonWithEdgeInsetsStyle:BMButtonEdgeInsetsStyleImageLeft imageTitleGap:5];
    }
    return _openResultBtn;
}

- (UIButton *)endAgainBtn
{
    if (!_endAgainBtn)
    {
        _endAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_endAgainBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
        [_endAgainBtn setBackgroundColor:[UIColor bm_colorWithHex:0x5A8CDC]];
        _endAgainBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _endAgainBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_endAgainBtn addTarget:self action:@selector(endAgainBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endAgainBtn;
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
    
         _resultTableView.backgroundColor = [UIColor whiteColor];
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
        _resultLable.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
        _resultLable.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF];
        _resultLable.font = [UIFont systemFontOfSize:14];
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


@end
