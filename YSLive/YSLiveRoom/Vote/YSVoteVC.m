//
//  YSVoteVC.m
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//


#import "YSVoteVC.h"
#import "YSVoteTopView.h"
#import "YSVoteResultTableCell.h"
#import "YSVotingTableCell.h"

static  NSString * const   YSVoteResultTableCellID = @"YSVoteResultTableCell";
static  NSString * const   YSVotingTableCellID     = @"YSVotingTableCell";
@interface YSVoteVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
/// 顶部文字视图
@property (nonatomic, strong) YSVoteTopView *topView;
/// 投票题目
@property (nonatomic, strong) UILabel *voteNameLabel;
/// 多选还是单选
@property (nonatomic, strong) UILabel *voteTypeLabel;
/// 详情
@property (nonatomic, strong) UILabel *voteDescLabel;
/// 表格主体
@property (nonatomic, strong) UITableView *voteTableView;
/// 底部视图
@property (nonatomic, strong) UIView *bottomView;
/// 正确答案
@property (nonatomic, strong) UILabel *rightAnswerLabel;
/// 底部按钮
@property (nonatomic, strong) UIButton *bottomBtn;

@end

@implementation YSVoteVC
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = YSLocalized(@"Button.vote");
    
    self.navigationController.navigationBar.barTintColor = YSSkinDefineColor(@"Live_timer_timeBgColor");
    
    self.view.backgroundColor = YSSkinDefineColor(@"Color3");
    
    [self setupUI];
}


#pragma mark -
#pragma mark UI

- (void)setupUI
{
    [self.view addSubview:self.topView];
    
    self.topView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, 55);
    if (self.voteType == YSVoteVCType_Result)
    {
        self.topView.isEnd = YES;
    }
    else
    {
        self.topView.isEnd = NO;
    }
    
    [self.view addSubview:self.voteNameLabel];
    
    [self.view addSubview:self.voteTypeLabel];
    
    [self.view addSubview:self.voteDescLabel];
    
    [self.view addSubview:self.voteTableView];
    [self.voteTableView registerClass:[YSVoteResultTableCell class] forCellReuseIdentifier:YSVoteResultTableCellID];
    [self.voteTableView registerClass:[YSVotingTableCell class] forCellReuseIdentifier:YSVotingTableCellID];
    
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.rightAnswerLabel];
    [self.view addSubview:self.bottomBtn];

    [self.bottomBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.voteType == YSVoteVCType_Result)
    {
        [_bottomBtn setTitle:YSLocalized(@"Button.ReturnRoom") forState:UIControlStateNormal];
    }
    else
    {
        [_bottomBtn setTitle:YSLocalized(@"Button.vote") forState:UIControlStateNormal];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.topView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.voteModel.topViewHeight + 30);
    
    self.voteNameLabel.frame = CGRectMake(30, CGRectGetMaxY(self.topView.frame) + 25, self.voteModel.subjectSize.width, self.voteModel.subjectSize.height);
    
    self.voteTypeLabel.frame = CGRectMake(CGRectGetMaxX(self.voteNameLabel.frame)+3, CGRectGetMaxY(self.topView.frame) + 29, 40, 20);
    self.voteTypeLabel.layer.cornerRadius = 10;
    self.voteTypeLabel.layer.masksToBounds = YES;
    
    self.voteDescLabel.frame = CGRectMake(30, CGRectGetMaxY(self.voteNameLabel.frame) + 6, BMUI_SCREEN_WIDTH-30 - 30 , 40);
    
    self.voteTableView.frame = CGRectMake(0, CGRectGetMaxY(self.voteDescLabel.frame), BMUI_SCREEN_WIDTH, 300);
   
    CGFloat tableH = 0.0;
    for (int i = 0; i < self.dataSource.count; i++)
    {
        YSVoteResultModel * model = self.dataSource[i];
        if (self.voteType == YSVoteVCType_Result)
        {
            tableH += model.endCellHeight + 40;
        }
        else
        {
            tableH += model.ingCellHeight + 20;
        }
    }
    
    CGFloat answerH =  self.voteType == YSVoteVCType_Result ? self.voteModel.rightAnswerHeight : 0.0;
    if (BMUI_MAINSCREEN_HEIGHT - BMUI_HOME_INDICATOR_HEIGHT - self.voteTableView.bm_top - 140 - answerH < tableH)
    {
        self.voteTableView.bm_height = BMUI_MAINSCREEN_HEIGHT- BMUI_HOME_INDICATOR_HEIGHT - self.voteTableView.bm_top - 140 - answerH;
        self.voteTableView.scrollEnabled = YES;
    }
    else
    {
        self.voteTableView.bm_height = tableH;
        self.voteTableView.scrollEnabled = NO;
    }
    
    self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.voteTableView.frame),BMUI_SCREEN_WIDTH ,140 + self.voteModel.rightAnswerHeight);
    self.rightAnswerLabel.frame = CGRectMake(10, 10, BMUI_SCREEN_WIDTH - 20, self.voteModel.rightAnswerHeight);
    self.rightAnswerLabel.bm_top = self.bottomView.bm_top + 10;
    
    self.bottomBtn.frame = CGRectMake(0, 0, 262, 44);
    self.bottomBtn.bm_centerX = self.bottomView.bm_centerX;
    self.bottomBtn.bm_top = self.rightAnswerLabel.bm_bottom + 10;
    [self.bottomBtn bm_roundedRect:4.0f];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.voteType)
    {
        case YSVoteVCType_Result:
        {
            YSVoteResultTableCell * resultCell = [tableView dequeueReusableCellWithIdentifier:YSVoteResultTableCellID forIndexPath:indexPath];
            YSVoteResultModel * model = self.dataSource[indexPath.row];
            resultCell.resultModel = model;
            return resultCell;
        }
            break;
        case YSVoteVCType_Multiple  :
        {
            YSVotingTableCell * multipleCell = [tableView dequeueReusableCellWithIdentifier:YSVotingTableCellID forIndexPath:indexPath];
            YSVoteResultModel * model = self.dataSource[indexPath.row];
            multipleCell.isSingle = NO;
            multipleCell.votingModel = model;
            return multipleCell;
        }
            break;
        case YSVoteVCType_Single:
        {
           YSVotingTableCell * singleCell = [tableView dequeueReusableCellWithIdentifier:YSVotingTableCellID forIndexPath:indexPath];
            YSVoteResultModel * model = self.dataSource[indexPath.row];
            singleCell.isSingle = YES;
            singleCell.votingModel = model;
            return singleCell;
        }
            break;
        default:
            break;
    }
    
    UITableViewCell * cell = [UITableViewCell new];
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSVoteResultModel * model = self.dataSource[indexPath.row];
    switch (self.voteType)
    {
        case YSVoteVCType_Multiple:
        case YSVoteVCType_Single:
            return model.ingCellHeight + 20;
            break;
        case YSVoteVCType_Result:
            return model.endCellHeight + 40;
            break;
        default:
            break;
    }
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSVoteResultModel * model = self.dataSource[indexPath.row];
    switch (self.voteType)
    {
        case YSVoteVCType_Multiple:
            model.isSelect = !model.isSelect;
            break;
        case YSVoteVCType_Single:
        {
            for (int i = 0; i < self.dataSource.count; i++)
            {
                if (i == indexPath.row) {
                    model.isSelect = !model.isSelect;
                    continue;
                }
                YSVoteResultModel * modelTemp = self.dataSource[i];
                modelTemp.isSelect = NO;
            }
            
        }
            break;
        case YSVoteVCType_Result:
            
            break;
        default:
            break;
    }
    [tableView reloadData];
}


#pragma mark -
#pragma mark SET
- (void)setVoteModel:(YSVoteModel *)voteModel
{
    _voteModel = voteModel;
    self.topView.voteModel = voteModel;
    self.voteNameLabel.text = voteModel.subject;
    self.voteTypeLabel.text = [NSString stringWithFormat:@"%@  ",self.voteModel.isSingle ? YSLocalized(@"Label.Single"):YSLocalized(@"Label.Multiple")];

    self.voteTypeLabel.hidden = NO;

    self.voteDescLabel.text = [NSString stringWithFormat:@"%@",voteModel.desc ];
    if (self.voteType == YSVoteVCType_Result && [voteModel.rightAnswer bm_isNotEmpty])
    {
        self.rightAnswerLabel.text = [NSString stringWithFormat:@"%@：%@",YSLocalized(@"tool.zhengquedaan"),voteModel.rightAnswer];
    }
}

- (void)setDataSource:(NSArray<YSVoteResultModel *> *)dataSource
{
    _dataSource = dataSource;
    
    if ([dataSource bm_isNotEmpty])
    {
         [self.voteTableView reloadData];
    }
}


#pragma mark -
#pragma mark SEL

- (void)bottomBtnClicked:(UIButton *)btn
{
    //返回直
    if (self.voteType == YSVoteVCType_Result)
    {
        BMLog(@"返回直播");
     
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        BMLog(@"投票");
        NSMutableArray * voteResault = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < self.dataSource.count; i++)
        {
            YSVoteResultModel * model = self.dataSource[i];
            if (model.isSelect)
            {
                [voteResault addObject:model.title];
            }
        }
        
        [[YSLiveManager sharedInstance] sendSignalingVoteCommitWithVoteId:self.voteModel.voteId voteResault:voteResault];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark Lazy
- (YSVoteTopView *)topView
{
    if (!_topView)
    {
        _topView = [[YSVoteTopView alloc] initWithFrame:CGRectZero withVoteStatus:NO];
    }
    return _topView;
}

- (UILabel *)voteNameLabel
{
    if (!_voteNameLabel)
    {
        _voteNameLabel = [[UILabel alloc] init];
        _voteNameLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 18);
        _voteNameLabel.textColor = YSSkinDefineColor(@"PlaceholderColor");
        _voteNameLabel.textAlignment = NSTextAlignmentLeft;
        _voteNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _voteNameLabel.numberOfLines = 0;
    }
    return _voteNameLabel;
}

- (UILabel *)voteTypeLabel
{
    if (!_voteTypeLabel)
    {
        _voteTypeLabel = [[UILabel alloc] init];
        _voteTypeLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
        _voteTypeLabel.textColor = YSSkinDefineColor(@"PlaceholderColor");
        _voteTypeLabel.textAlignment = NSTextAlignmentCenter;
        _voteTypeLabel.backgroundColor = YSSkinDefineColor(@"Live_timer_timeBgColor");
        _voteTypeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _voteTypeLabel;
}

- (UILabel *)voteDescLabel
{
    if (!_voteDescLabel)
    {
        _voteDescLabel = [[UILabel alloc] init];
        _voteDescLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
        _voteDescLabel.textColor = YSSkinDefineColor(@"PlaceholderColor");
        _voteDescLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _voteDescLabel;
}

- (UITableView *)voteTableView
{
    if (!_voteTableView)
    {
        _voteTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _voteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _voteTableView.delegate = self;
        _voteTableView.dataSource = self;
        _voteTableView.showsVerticalScrollIndicator = NO;
        _voteTableView.backgroundColor = YSSkinDefineColor(@"Color3");
    }
    return _voteTableView;
}
- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = YSSkinDefineColor(@"Color3");
    }
    return _bottomView;
}

- (UILabel *)rightAnswerLabel
{
    if (!_rightAnswerLabel)
    {
        _rightAnswerLabel = [[UILabel alloc] init];
        _rightAnswerLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12);
        _rightAnswerLabel.textColor = YSSkinDefineColor(@"PlaceholderColor");
        _rightAnswerLabel.textAlignment = NSTextAlignmentLeft;
        _rightAnswerLabel.backgroundColor = [UIColor clearColor];
        _rightAnswerLabel.numberOfLines = 0;
        _rightAnswerLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _rightAnswerLabel;
}

- (UIButton *)bottomBtn
{
    if (!_bottomBtn)
    {
        _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
        [_bottomBtn setBackgroundColor:YSSkinDefineColor(@"Color4")];
        _bottomBtn.titleLabel.textAlignment =  NSTextAlignmentCenter;
        _bottomBtn.titleLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 15);
    }
    return _bottomBtn;
}


@end

