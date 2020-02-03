//
//  SCChatView.m
//  ddddd
//
//  Created by 马迪 on 2019/11/6.
//  Copyright © 2019 马迪. All rights reserved.
//

#import "AFNetworking.h"
#import "SCChatView.h"
#import "SCTipsMessageCell.h"
#import "SCTextMessageCell.h"
#import "SCPictureMessageCell.h"

//底部View的高
#define BottomH 82

@interface SCChatView()
<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate
>

///有投影的底部View
@property(nonatomic,strong)UIImageView *bubbleView;

@end

@implementation SCChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColor.whiteColor;
        self.alpha = 0.95;
        
        UIBezierPath *maskBottomPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft  cornerRadii:CGSizeMake(30, 30)];
        CAShapeLayer *maskBottomLayer = [[CAShapeLayer alloc] init];
        maskBottomLayer.frame = self.bounds;
        maskBottomLayer.path = maskBottomPath.CGPath;
        self.layer.mask = maskBottomLayer;
        
        [self setupUIView];
        
        self.SCMessageList = [NSMutableArray array];
        
        self.allDisabledChat.hidden = ![YSLiveManager shareInstance].isEveryoneBanChat;
        self.textBtn.hidden = [YSLiveManager shareInstance].isEveryoneBanChat;
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
//    [self addSubview:self.bubbleView];
    
    self.bubbleView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    //剪切边界 如果视图上的子视图layer超出视图layer部分就截取掉 如果添加阴影这个属性必须是NO 不然会把阴影切掉
    self.bubbleView.layer.masksToBounds = NO;
    //阴影半径，默认3
    self.bubbleView.layer.shadowRadius = 3;
    //shadowOffset阴影偏移，有偏移量的情况,默认向右向下有阴影,设置偏移量为0,四周都有阴影
    self.bubbleView.layer.shadowOffset = CGSizeZero;
    // 阴影透明度，默认0
    self.bubbleView.layer.shadowOpacity = 0.9f;
    
    //添加聊天tabView
    self.SCChatTableView.frame = CGRectMake(0, 0, self.bm_width, self.bm_height-BottomH);
    [self addSubview:self.SCChatTableView];
    
    
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bm_height-BottomH, self.bm_width, BottomH)];
    bottomView.backgroundColor = [UIColor bm_colorWithHexString:@"#DEEAFF" alpha:0.95];
    [self addSubview:bottomView];
    
    UIBezierPath *maskBottomPath = [UIBezierPath bezierPathWithRoundedRect:bottomView.bounds byRoundingCorners:UIRectCornerBottomLeft  cornerRadii:CGSizeMake(30, 30)];
    CAShapeLayer *maskBottomLayer = [[CAShapeLayer alloc] init];
    maskBottomLayer.frame = bottomView.bounds;
    maskBottomLayer.path = maskBottomPath.CGPath;
    bottomView.layer.mask = maskBottomLayer;
    
    //弹起输入框的按钮
    self.textBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, 20, 270, 34)];
    self.textBtn.titleLabel.font = UI_FONT_14;
    [self.textBtn setTitleColor:[UIColor bm_colorWithHexString:@"#828282"] forState:UIControlStateNormal];
    [self.textBtn setTitle:[NSString stringWithFormat:@"   %@",YSLocalized(@"Alert.NumberOfWords.140")] forState:UIControlStateNormal];
    self.textBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.textBtn addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventTouchUpInside];
    [self.textBtn setBackgroundColor:UIColor.whiteColor];
    [bottomView addSubview:self.textBtn];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.textBtn.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(17, 17)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.textBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    self.textBtn.layer.mask = maskLayer;
    
    //群体禁言
    self.allDisabledChat = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.bm_width-20, 35)];
    self.allDisabledChat.backgroundColor = UIColor.whiteColor;
    self.allDisabledChat.textAlignment = NSTextAlignmentCenter;
    [self.allDisabledChat setFont:UI_FONT_13];
    self.allDisabledChat.text = YSLocalized(@"Prompt.BanChatInView");
    self.allDisabledChat.textColor = [UIColor bm_colorWithHexString:@"#738395"];
    self.allDisabledChat.layer.cornerRadius = self.allDisabledChat.bm_height/2;
    self.allDisabledChat.layer.masksToBounds = YES;
    [bottomView addSubview:self.allDisabledChat];
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
//        cell.contentView.bm_width = self.bm_width;
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
//        cell.contentView.bm_width = self.bm_width;
        return cell;
    }
    else if (model.chatMessageType == YSChatMessageTypeOnlyImage)
    {
        SCPictureMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCPictureMessageCell class]) forIndexPath:indexPath];
        cell.model = model;
//        cell.contentView.bm_width = self.bm_width;
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
    
    AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
    [manger.requestSerializer setTimeoutInterval:30];
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
        @"text/xml", @"image/jpeg", @"image/*"
    ]];
    //=====增加表情的识别，表情不进行翻译 ===  +  === 对链接地址不进行翻译======
    NSString * aTranslationString = [model.message stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    
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
    [manger GET:YSTRANS_API_HOST parameters:tParamDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
