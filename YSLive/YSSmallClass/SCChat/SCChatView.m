//
//  SCChatView.m
//  ddddd
//
//  Created by 马迪 on 2019/11/6.
//  Copyright © 2019 马迪. All rights reserved.
//

#import "SCChatView.h"
#import "SCTipsMessageCell.h"
#import "SCTextMessageCell.h"
#import "SCPictureMessageCell.h"

//底部View的高
#define BottomH ([UIDevice bm_isiPad] ? 70 : 50)

@interface SCChatView()
<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate
>

///有投影的底部View
@property(nonatomic,strong)UIImageView *bubbleView;

///全体禁言的按钮
@property(nonatomic,strong)UIButton * allDisableBtn;

///弹起输入框的按钮
@property(nonatomic,strong)UIButton * textBtn;

@end

@implementation SCChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
//        self.alpha = 0.95;
        
        UIBezierPath *maskBottomPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft  cornerRadii:CGSizeMake(30, 30)];
        CAShapeLayer *maskBottomLayer = [[CAShapeLayer alloc] init];
        maskBottomLayer.frame = self.bounds;
        maskBottomLayer.path = maskBottomPath.CGPath;
        self.layer.mask = maskBottomLayer;
        
        [self setupUIView];
        
        self.SCMessageList = [NSMutableArray array];
        
//        if (YSCurrentUser.role == YSUserType_Teacher)
//        {
//            self.allDisableBtn.userInteractionEnabled = NO;
//        }
//        else
//        {
            if ([YSLiveManager shareInstance].isBeginClass)
            {
                self.allDisabled = [YSLiveManager shareInstance].isEveryoneBanChat;
            }
            else
            {
                self.allDisabled = [YSLiveManager shareInstance].roomConfig.isBeforeClassBanChat;
            }
//        }
    }
    return self;
}

#pragma mark -
#pragma mark 添加聊天tabView、输入框

- (void)setupUIView
{
    //有投影的b底部View
    self.bubbleView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.bubbleView.alpha = 0.9;
    self.bubbleView.image = [UIImage imageNamed:@"SCChatBubble"];
    self.bubbleView.userInteractionEnabled = YES;
    
    self.bubbleView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    //剪切边界 如果视图上的子视图layer超出视图layer部分就截取掉 如果添加阴影这个属性必须是NO 不然会把阴影切掉
    self.bubbleView.layer.masksToBounds = NO;
    //阴影半径，默认3
    self.bubbleView.layer.shadowRadius = 3;
    //shadowOffset阴影偏移，有偏移量的情况,默认向右向下有阴影,设置偏移量为0,四周都有阴影
    self.bubbleView.layer.shadowOffset = CGSizeZero;
    // 阴影透明度，默认0
    self.bubbleView.layer.shadowOpacity = 0.9f;
    
    CGFloat titleLabH = 29;
    
    UIFont * titleLabFont = UI_FONT_12;
    
    if ([UIDevice bm_isiPad])
    {
        titleLabH = 44;
        titleLabFont = UI_FONT_16;
    }
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.bm_width - 2 * 20, titleLabH)];
    titleLab.text = @"消息";
    titleLab.textColor = YSSkinDefineColor(@"defaultTitleColor");
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = titleLabFont;
    [self addSubview:titleLab];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleLab.bm_bottom, self.bm_width, 1.0)];
    lineView.backgroundColor = YSSkinDefineColor(@"lineColor");
    [self addSubview:lineView];
    
    
    //添加聊天tabView
    self.SCChatTableView.frame = CGRectMake(0, lineView.bm_bottom, self.bm_width, self.bm_height - lineView.bm_bottom - BottomH);
    [self addSubview:self.SCChatTableView];
    
    if (YSCurrentUser.role == YSUserType_Patrol)
    {
        self.SCChatTableView.bm_height = self.bm_height - lineView.bm_bottom;
        return;
    }
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bm_height - BottomH, self.bm_width, BottomH)];
    bottomView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    [self addSubview:bottomView];
    
    UIBezierPath *maskBottomPath = [UIBezierPath bezierPathWithRoundedRect:bottomView.bounds byRoundingCorners:UIRectCornerBottomLeft  cornerRadii:CGSizeMake(30, 30)];
    CAShapeLayer *maskBottomLayer = [[CAShapeLayer alloc] init];
    maskBottomLayer.frame = bottomView.bounds;
    maskBottomLayer.path = maskBottomPath.CGPath;
    bottomView.layer.mask = maskBottomLayer;
    
    
    CGFloat allDisableBtnX = 16;
    CGFloat allDisableBtnWH = 26;
    
    if ([UIDevice bm_isiPad])
    {
        allDisableBtnX = 26;
        allDisableBtnWH = 40;
    }
    
    //全体禁言的按钮
    UIButton * allDisableBtn = [[UIButton alloc]initWithFrame:CGRectMake(allDisableBtnX, 10, allDisableBtnWH-5, allDisableBtnWH-5)];
    [allDisableBtn setImage:YSSkinElementImage(@"chatView_allDisableBtn", @"iconNor") forState:UIControlStateNormal];
    [allDisableBtn setImage:YSSkinElementImage(@"chatView_allDisableBtn", @"iconSel") forState:UIControlStateSelected];
    [allDisableBtn addTarget:self action:@selector(allDisableButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [allDisableBtn setBackgroundColor:UIColor.whiteColor];
    [bottomView addSubview:allDisableBtn];
    self.allDisableBtn = allDisableBtn;
    
    
    //弹起输入框的按钮
    UIButton * textBtn = [[UIButton alloc]initWithFrame:CGRectMake(allDisableBtn.bm_right + 15, 10, self.bm_width - allDisableBtn.bm_right - 15 - 15, allDisableBtnWH)];
    textBtn.titleLabel.font = UI_FONT_14;
    [textBtn setTitleColor:YSSkinDefineColor(@"placeholderColor") forState:UIControlStateNormal];
    [textBtn setTitle:[NSString stringWithFormat:@"   %@",YSLocalized(@"Alert.NumberOfWords.140")] forState:UIControlStateNormal];
    textBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [textBtn addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventTouchUpInside];
    [textBtn setBackgroundColor:UIColor.clearColor];
    [bottomView addSubview:textBtn];
    self.textBtn = textBtn;
    
    textBtn.layer.cornerRadius = allDisableBtnWH/2;
    textBtn.layer.borderWidth = 1;  // 给图层添加一个有色边框
    textBtn.layer.borderColor = YSSkinDefineColor(@"placeholderColor").CGColor;
    textBtn.layer.shadowColor = YSSkinDefineColor(@"placeholderColor").CGColor;
    textBtn.layer.shadowOffset = CGSizeMake(0,2);
    textBtn.layer.shadowOpacity = 1;
    textBtn.layer.shadowRadius = 4;
}

- (void)allDisableButtonClick:(UIButton *)sender
{
    if (!sender.selected)
    {
        // 全体禁言
        [[YSLiveManager shareInstance] sendSignalingTeacherToLiveAllNoChatSpeakingCompletion:nil];
    }
    else
    {
        // 解除禁言
        [[YSLiveManager shareInstance] deleteSignalingTeacherToLiveAllNoChatSpeakingCompletion:nil];
    }
}

- (void)setAllDisabled:(BOOL)allDisabled
{
    _allDisabled = allDisabled;
   
    self.allDisableBtn.selected = allDisabled;
    self.textBtn.userInteractionEnabled = !allDisabled;
}

- (void)textFieldDidChange
{
    if (_textBtnClick)
    {
        _textBtnClick();
    }
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.SCMessageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSChatMessageModel *model = _SCMessageList[indexPath.row];
    
    if (model.chatMessageType == YSChatMessageTypeTips)
    {
        SCTipsMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCTipsMessageCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
    else if (model.chatMessageType == YSChatMessageTypeText)
    {
        SCTextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCTextMessageCell class]) forIndexPath:indexPath];
        cell.model = model;
        BMWeakSelf
        cell.translationBtnClick = ^{
            [weakSelf getBaiduTranslateWithIndexPath:indexPath];
        };
        return cell;
    }
    else if (model.chatMessageType == YSChatMessageTypeOnlyImage)
    {
        SCPictureMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCPictureMessageCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSChatMessageModel * model = _SCMessageList[indexPath.row];
    
    if (model.chatMessageType == YSChatMessageTypeTips)
    {
        if (!model.cellHeight)
        {
            model.cellHeight = 5 + 25 + 5;
        }
        return model.cellHeight;
    }
    else if (model.chatMessageType == YSChatMessageTypeText)
    {
        if ([model.detailTrans bm_isNotEmpty])
        {//有翻译
            if (!model.transCellHeight)
            {
                if (!model.messageSize.width)
                {
                    NSMutableAttributedString *attMessage = [model emojiViewWithMessage:model.message font:15];
                    model.messageSize = [attMessage bm_sizeToFitWidth:200];
                }
                
                if (!model.translatSize.width)
                {
                    NSMutableAttributedString * attTranslation = [model emojiViewWithMessage:model.detailTrans font:15];
                    model.translatSize = [attTranslation bm_sizeToFitWidth:200];
                }
                model.transCellHeight = 10 + 20 + 5 +  5 + model.messageSize.height + 5 + 1 + 5 + model.translatSize.height + 5 + 5;
            }
            return model.transCellHeight;
        }
        else
        {//无翻译
            if (!model.cellHeight)
            {
                if (!model.messageSize.width)
                {
                    NSMutableAttributedString * attMessage = [model emojiViewWithMessage:model.message font:15];
                    model.messageSize = [attMessage bm_sizeToFitWidth:200];
                }
                model.cellHeight = 10 + 20 + 5 + 5 + model.messageSize.height + 5 + 5;
            }
            return model.cellHeight;
        }
    }
    else if (model.chatMessageType == YSChatMessageTypeOnlyImage)
    {
        if (!model.cellHeight)
        {
            model.cellHeight = 10 + 20 + 10 + 88 + 10;
        }
        return model.cellHeight;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hiddenTheKeyBoard];
}

- (void)hiddenTheKeyBoard
{
    if (_clickViewToHiddenTheKeyBoard)
    {
        _clickViewToHiddenTheKeyBoard();
    }
}


#pragma mark -
#pragma mark 聊天的tableView

- (UITableView *)SCChatTableView
{
    if (!_SCChatTableView)
    {
        self.SCChatTableView = [[UITableView alloc]initWithFrame:CGRectZero style: UITableViewStyleGrouped];
        
        self.SCChatTableView.delegate   = self;
        self.SCChatTableView.dataSource = self;
        self.SCChatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        self.SCChatTableView.backgroundColor = [UIColor clearColor];
        self.SCChatTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        self.SCChatTableView.showsHorizontalScrollIndicator = NO;
        self.SCChatTableView.estimatedRowHeight = 0;
        self.SCChatTableView.estimatedSectionHeaderHeight = 0;
        self.SCChatTableView.estimatedSectionFooterHeight = 0;
        
        [self.SCChatTableView registerClass:[SCTipsMessageCell class] forCellReuseIdentifier:NSStringFromClass([SCTipsMessageCell class])];
        [self.SCChatTableView registerClass:[SCTextMessageCell class] forCellReuseIdentifier:NSStringFromClass([SCTextMessageCell class])];
        [self.SCChatTableView registerClass:[SCPictureMessageCell class] forCellReuseIdentifier:NSStringFromClass([SCPictureMessageCell class])];
                    
//        if (@available(iOS 11.0, *))
        if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
        {
            self.SCChatTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.SCChatTableView.insetsContentViewsToSafeArea = NO;
        }
    }
    return _SCChatTableView;
}

#pragma mark -
#pragma mark 翻译
- (void)getBaiduTranslateWithIndexPath:(NSIndexPath *) indexPath
{
    YSChatMessageModel * model = self.SCMessageList[indexPath.row];
    
    BMAFHTTPSessionManager * manger = [BMAFHTTPSessionManager manager];
    [manger.requestSerializer setTimeoutInterval:30];
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
        @"text/xml", @"image/jpeg", @"image/*"
    ]];
    //=====增加表情的识别，表情不进行翻译 ===  +  === 对链接地址不进行翻译======
    NSString * aTranslationString = [model.message stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    
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
        
        [weakSelf.SCChatTableView reloadData];
        [weakSelf.SCChatTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BMLog(@"%@",error);
    }];
}

@end
