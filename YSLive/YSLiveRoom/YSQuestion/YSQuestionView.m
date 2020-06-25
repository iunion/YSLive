//
//  YSQuestionView.m
//  YSLive
//
//  Created by 马迪 on 2019/10/21.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSQuestionView.h"
#import "YSAnswerCell.h"
#import "BMProgressHUD.h"

//输入框高度
#define ToolHeight (BMIS_IPHONEXANDP?(50+20):50)
//iphoneX的时候键盘多出的高度
#define BottomH 20
//输入框的初始位置
#define ToolOriginalY self.bm_height-ToolHeight

@interface YSQuestionView ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UITextViewDelegate
>

///聊天tableView
@property (nonatomic, strong) UITableView *questTableView;
///底部工具栏
@property (nonatomic, strong) UIView *bottomView;
///输入框背景view
@property (nonatomic, strong) UIView *backView;
///输入框
@property (nonatomic, strong) UITextView *inputView;
///发送按钮
@property (nonatomic, strong) UIButton *sendBtn;
///placehold
@property (nonatomic, strong) UILabel *placeholdLab;


@end

@implementation YSQuestionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = YSSkinDefineColor(@"liveDefaultBgColor");
        self.questionArr = [NSMutableArray array];
        
        [self setupUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)setupUI{
    
    self.questTableView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, self.bm_height-ToolHeight);
    [self addSubview:self.questTableView];
    
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, ToolOriginalY, BMUI_SCREEN_WIDTH, ToolHeight)];
    self.bottomView.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
    [self addSubview:self.bottomView];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bm_width - 70 - 20, 10, 70, 34)];
    [self.sendBtn setTitle:YSLocalized(@"Button.send") forState:UIControlStateNormal];
    [self.sendBtn setBackgroundColor:YSSkinDefineColor(@"defaultSelectedBgColor")];
    [self.sendBtn setTitleColor:YSSkinDefineColor(@"defaultTitleColor") forState:UIControlStateNormal];
    self.sendBtn.titleLabel.font = UI_FONT_14;
    self.sendBtn.layer.cornerRadius = 4;
    [self.sendBtn addTarget:self action:@selector(sendButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.bottomView addSubview:self.sendBtn];
    
    
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(20, 10, self.sendBtn.bm_originX - 20 - 15, 34)];
    self.backView.layer.cornerRadius = 4;
    self.backView.backgroundColor = YSSkinDefineColor(@"liveChatBgColor");
    [self.bottomView addSubview:self.backView];
        
    self.inputView = [[UITextView alloc]initWithFrame:CGRectMake(5, 0, self.backView.bm_width-10, 30)];
    self.inputView.backgroundColor = UIColor.clearColor;
    self.inputView.textColor = [UIColor bm_colorWithHex:0x828282];
    self.inputView.delegate = self;
    [self.backView addSubview:self.inputView];
    
    self.placeholdLab = [[UILabel alloc]initWithFrame:CGRectMake(8, 5, 150, 20)];
    self.placeholdLab.text = YSLocalized(@"Alert.WriteQuest");
    self.placeholdLab.textColor = [UIColor bm_colorWithHex:0x828282];
    self.placeholdLab.font = UI_FONT_14;
    [self.inputView addSubview:self.placeholdLab];
    
    self.maskView = [[UIView alloc]initWithFrame:self.bottomView.bounds];
    self.maskView.backgroundColor = [YSSkinDefineColor(@"blackColor") changeAlpha:0.1];
    [self.bottomView addSubview:self.maskView];
    
    if (![YSLiveManager sharedInstance].isClassBegin)
    {
        self.maskView.hidden = NO;
    }
    else
    {
        self.maskView.hidden = YES;
    }
}

#pragma mark -
#pragma mark 发送

- (void)sendButtonClick
{
    if (![YSLiveManager sharedInstance].isClassBegin)
    {
        BMProgressHUD * hub =[BMProgressHUD bm_showHUDAddedTo:self animated:YES withDetailText:YSLocalized(@"Alert.CanNotQuestion")];
        hub.yOffset = -130;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [BMProgressHUD bm_hideHUDForView:self animated:YES];
        });
        return ;
    }
    
    NSString *questionId = [[YSLiveManager sharedInstance] sendQuestionWithText:self.inputView.text];
    if ([questionId bm_isNotEmpty])
    {
        YSQuestionModel * model = [[YSQuestionModel alloc]init];
        model.nickName = YSCurrentUser.nickName;
        model.timeInterval = [YSLiveManager sharedInstance].tCurrentTime;
        model.questDetails = self.inputView.text;
        model.state = YSQuestionState_Question;
        model.questionId = questionId;
        [self.questionArr addObject:model];
    }
    [self frashView:nil];
    
    self.inputView.text = nil;
    [self.inputView resignFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView
{
    self.placeholdLab.hidden = [textView.text bm_isNotEmpty];
}

#pragma mark - 刷新
- (void)frashView:(id)message
{
    if ([message bm_isNotEmpty] && [message isKindOfClass:[YSQuestionModel class]])
    {//添加的时候传model
        YSQuestionModel * questionModel = (YSQuestionModel*)message;
        
        if (questionModel.state == YSQuestionState_Responed) {
            for (YSQuestionModel * model in self.questionArr)
            {
                if ([model.questionId isEqualToString:questionModel.questionId])
                {
                    if (questionModel.state == YSQuestionState_Answer)
                    {
                        questionModel.questDetails = model.questDetails;
                    }
                    [self.questionArr removeObject:model];
                    break;
                }
            }
        }
        
        [self.questionArr addObject:questionModel];
    }
    else if ([message bm_isNotEmpty] && [message isKindOfClass:[NSString class]])
    {//删除的时候传id
        NSString * questionId = (NSString *)message;

        for (int i = (int)(self.questionArr.count)-1; i>=0; i--) {
            
            YSQuestionModel * model = self.questionArr[i];
            if ([model.questionId isEqualToString:questionId]) {
                [self.questionArr removeObject:model];
            }
        }
    }
    
    [self.questTableView reloadData];
    if (self.questionArr.count)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.questionArr.count-1 inSection:0];
        [self.questTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.questionArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSQuestionModel * model = _questionArr[indexPath.row];
    
    YSAnswerCell * cell =[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(YSAnswerCell.class) forIndexPath:indexPath];
    cell.model = model;
    BMWeakSelf
    cell.translationBtnClick = ^{
        [weakSelf getBaiduTranslateWithIndexPath:indexPath];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    YSQuestionModel * model = _questionArr[indexPath.row];
    
    
    CGSize tagSize = [YSLocalized(@"Label.Reply") bm_sizeToFitWidth:100 withFont:UI_FONT_12];
    
    CGFloat cellTopHeight = 10 + tagSize.height + 5;
    
    if ([model.detailTrans bm_isNotEmpty])
    {//有翻译
        if (!model.transCellHeight)
        {
            if (model.state == YSQuestionState_Answer)
            {//回复
                NSString * questStr = [NSString stringWithFormat:@"%@：%@",YSLocalized(@"Label.Question"),model.questDetails];
                CGSize questStrSize = [questStr bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_14];
                
                model.cellHeight = cellTopHeight +  model.answerDetailsSize.height + 5 + model.translatSize.height + 5 + questStrSize.height + 2*10 + 10;
            }
            else
            {
                model.cellHeight = cellTopHeight + model.questDetailsSize.height + 4 + 1 + 4 + model.translatSize.height + 2*10 + 10;
            }
        }
        return model.cellHeight;
    }
    else
    {//无翻译
        if (!model.cellHeight)
        {
            if (model.state == YSQuestionState_Answer)
            {//回复
                NSString * questStr = [NSString stringWithFormat:@"%@：%@",YSLocalized(@"Label.Question"),model.questDetails];
                CGSize questStrSize = [questStr bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_14];
                model.cellHeight = cellTopHeight +  model.answerDetailsSize.height + 5 + questStrSize.height + 2*10 + 10;
            }
            else
            {
                model.cellHeight = cellTopHeight + model.questDetailsSize.height + 2*10+10;
            }
        }
        return model.cellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toHiddenKeyBoard];
}

#pragma mark 键盘通知

- (void)keyboardWillShow:(NSNotification*)notification
{
    // 1.键盘弹出需要的时间
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 取出键盘高度
    CGRect keyboardF = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 2.动画
    [UIView animateWithDuration:duration animations:^{
        self.bottomView.bm_originY = ToolOriginalY-keyboardF.size.height;
        self.questTableView.bm_originY = -keyboardF.size.height+BottomH;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    double duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.bottomView.bm_originY= ToolOriginalY;
        self.questTableView.bm_originY = 0;
    }];
}

#pragma mark - 滚动或点击空白时，键盘回归原位
- (void)toHiddenKeyBoard
{
    if (self.questTableView.bm_originY<0)
    {
        [self.inputView resignFirstResponder];
        [UIView animateWithDuration:BMDEFAULT_DELAY_TIME animations:^{
            self.bottomView.bm_originY = ToolOriginalY;
            self.questTableView.bm_originY = 0;
        }];
    }
}

#pragma mark 聊天的tableView

- (UITableView *)questTableView
{
    if (!_questTableView)
    {
        self.questTableView = [[UITableView alloc]initWithFrame:CGRectZero style: UITableViewStylePlain];
        
        self.questTableView.delegate   = self;
        self.questTableView.dataSource = self;
        self.questTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.questTableView.backgroundColor = YSSkinDefineColor(@"liveDefaultBgColor");
        self.questTableView.separatorColor  = [UIColor clearColor];
        self.questTableView.showsHorizontalScrollIndicator = NO;
        self.questTableView.showsVerticalScrollIndicator = NO;
        
        [self.questTableView registerClass:[YSAnswerCell class] forCellReuseIdentifier:NSStringFromClass(YSAnswerCell.class)];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toHiddenKeyBoard)];
        [self.questTableView addGestureRecognizer:tap];
    }
    return _questTableView;
}

#pragma mark -
#pragma mark 翻译
- (void)getBaiduTranslateWithIndexPath:(NSIndexPath *) indexPath
{
    YSQuestionModel * model = self.questionArr[indexPath.row];
    
    BMAFHTTPSessionManager * manger = [BMAFHTTPSessionManager manager];
    [manger.requestSerializer setTimeoutInterval:30];
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
        @"text/xml", @"image/jpeg", @"image/*"
    ]];
    //=====增加表情的识别，表情不进行翻译 ===  +  === 对链接地址不进行翻译======
    NSString * aTranslationString = @"";
    
    if (model.state == YSQuestionState_Answer)
    {
        aTranslationString = model.answerDetails;
    }
    else
    {
        aTranslationString = model.questDetails;
    }
    
    aTranslationString = [aTranslationString stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    
    if (![aTranslationString bm_isNotEmpty])
    {
        return;
    }
    
    unichar ch = [aTranslationString characterAtIndex:0];
    NSString *tTo;
    NSString *tFrom;
    
    //中日互译。默认为日译中，探测到输入为中文则改成中译日
    //    if ([TKEduClassRoom shareInstance].roomJson.configuration.isChineseJapaneseTranslation == YES) {
    //        /*
    //         /u4e00-/u9fa5 (中文)
    //         /u0800-/u4e00 (日文)
    //         */
    //        tTo   = @"zh";
    //        tFrom = @"jp";
    //
    //        float chNum = 0;
    //        for (int i = 0; i < aTranslationString.length; i++) {
    //            unichar ch = [aTranslationString characterAtIndex:i];
    //            if (ch >= 0x4e00 && ch <= 0x9fa5) { chNum++; }
    //        }
    //        if (chNum > 0) {
    //            //纯中文，则中译日
    //            tTo   = @"jp";
    //            tFrom = @"zh";
    //        }
    //    } else {
    //中英互译。默认英译中，探测到输入为中文则改成中译英
    tTo   = @"zh";
    tFrom = @"en";
    
    if ((int)(ch)>127) {
        tFrom = @"auto";
        tTo   = @"en";
    }
    //    }
    
    NSNumber *tSaltNumber = @(arc4random());
    // APP_ID + query + salt + SECURITY_KEY;
    NSString *tSign = [[NSString stringWithFormat:@"%@%@%@%@", YSAPP_ID_BaiDu, aTranslationString,
                                     tSaltNumber, YSSECURITY_KEY] bm_md5String];
    NSDictionary *tParamDic = @{
        @"appid" : YSAPP_ID_BaiDu,
        @"q" : aTranslationString,
        @"from" : tFrom,
        @"to" : tTo,
        @"salt" : tSaltNumber,
        @"sign" : tSign
        
    };
    BMWeakSelf
    
    
    [manger GET:YSTRANS_API_HOST parameters:tParamDic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BMLog(@"%@",responseObject);
        if (responseObject == nil)
        {
            return;
        }
        
        NSArray *tRanslationArray    = [responseObject objectForKey:@"trans_result"];
        NSDictionary *tRanslationDic = [tRanslationArray firstObject];
        NSString * transString = [tRanslationDic objectForKey:@"dst"];
        model.detailTrans = transString;
        //        model.isOpen = YES;
        
//        [weakSelf.questTableView reloadData];
//        weakSelf.questTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone
        [weakSelf.questTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BMLog(@"%@",error);
    }];
}

@end
