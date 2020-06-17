//
//  YSChatToolView.m
//  YSLive
//
//  Created by 马迪 on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSChatToolView.h"
#import "BMAlertView+YSDefaultAlert.h"
#import "YSLiveApiRequest.h"

@interface YSChatToolView ()
<
UITextViewDelegate
>

///小红花（彩色）
@property (nonatomic, strong) UIButton *flowerColourBtn;
///输入框背景View
@property (nonatomic, strong) UIView *backView;


@property(nonatomic, strong) NSURLSessionDataTask *liveCallRollSigninTask;

@end

@implementation YSChatToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
        [self setupUIView];
    }
    return self;
}

- (void)setupUIView
{
    self.flowerColourBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 10, 25, 25)];
    [self.flowerColourBtn addTarget:self action:@selector(flowerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.flowerColourBtn setImage:YSSkinElementImage(@"live_chat_flowerBtn", @"iconSel") forState:UIControlStateSelected];
    [self.flowerColourBtn setImage:YSSkinElementImage(@"live_chat_flowerBtn", @"iconNor") forState:UIControlStateNormal];
    [self addSubview:self.flowerColourBtn];
    
    //显示消息类型选择按钮
    _msgTypeBtn = ({
        UIButton * msgTypeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bm_width - 15 - 24 , 15, 24, 24)];
        [msgTypeBtn addTarget:self action:@selector(msgTypeBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessagePersional", @"iconNor") forState:UIControlStateNormal];
        [msgTypeBtn setImage:YSSkinElementImage(@"live_chatMessagePersional", @"iconSel") forState:UIControlStateHighlighted];
        msgTypeBtn;
    });
    [self addSubview:_msgTypeBtn];
    
    _emotionButton = ({
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(_msgTypeBtn.bm_originX - 20 - 24, 15, 24, 24)];
        [button setImage:YSSkinElementImage(@"live_chatEmotionBtn", @"iconNor") forState:UIControlStateNormal];
        [button setImage:YSSkinElementImage(@"live_chatEmotionBtn", @"iconSel") forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(emotionButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
        //        [button setBackgroundColor:[UIColor greenColor]];
        button;
    });
    [self addSubview:_emotionButton];
 
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(self.flowerColourBtn.bm_right + 10, 10, _emotionButton.bm_originX - 10 - self.flowerColourBtn.bm_right - 10, 34)];
    self.backView.backgroundColor = YSSkinDefineColor(@"liveChatBgColor");
    self.backView.layer.cornerRadius = 4;
    self.backView.layer.masksToBounds = YES;
    self.backView.layer.borderColor = UIColor.clearColor.CGColor;
    [self addSubview:self.backView];

    
    NSString * str = [NSString stringWithFormat:@"%@%@",YSLocalized(@"Label.To"),YSLocalized(@"Label.All")];
    self.placeholder = [[UIButton alloc]init];
    [self.placeholder setBackgroundColor:[UIColor clearColor]];
    self.placeholder.titleLabel.font = UI_FONT_13;
    [self.placeholder setTitle:str forState:UIControlStateNormal];
    NSMutableAttributedString * mutAttrStr = [[NSMutableAttributedString alloc]initWithString:str];
    [mutAttrStr addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]} range:NSMakeRange(0, 2)];
    [mutAttrStr addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#5A8CDC"]} range:NSMakeRange(2, str.length-2)];
    [self.placeholder setAttributedTitle:mutAttrStr forState:UIControlStateNormal];
    [self.placeholder addTarget:self action:@selector(placeholderButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.backView addSubview:self.placeholder];
    
    [self.placeholder bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(self.backView).bmmas_offset(14);
        make.height.bmmas_equalTo(25);
        make.bottom.bmmas_equalTo(self.backView).bmmas_offset(-5);
    }];
    
    //输入框
    self.inputView = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_placeholder.frame), 5, 236-CGRectGetMaxX(_placeholder.frame) - 9, 25)];
    self.inputView.backgroundColor = YSSkinDefineColor(@"liveChatBgColor");
    self.inputView.returnKeyType = UIReturnKeySend;
    self.inputView.font = UI_FONT_15;
    self.inputView.textColor = [UIColor bm_colorWithHexString:@"#2F2F2F"];
    self.inputView.delegate = self;
    //当textview的字符串为0时发送（rerurn）键无效
    self.inputView.enablesReturnKeyAutomatically = YES;
    [self.backView addSubview:self.inputView];
    
    [self.inputView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(self.placeholder.bmmas_right);
        make.top.bmmas_equalTo(self.backView).bmmas_offset(8);
        make.bottom.bmmas_equalTo(self.backView).bmmas_offset(-5);
        make.right.bmmas_equalTo(self.backView).bmmas_offset(-5);
    }];
    
    
    //群体禁言
    self.allDisabledChat = [[UILabel alloc] init];
    self.allDisabledChat.backgroundColor = UIColor.whiteColor;
    self.allDisabledChat.textAlignment = NSTextAlignmentCenter;
    [self.allDisabledChat setFont:UI_FONT_13];
    self.allDisabledChat.text = YSLocalized(@"Prompt.BanChatInView");
    self.allDisabledChat.textColor = [UIColor bm_colorWithHexString:@"#738395"];
    [self addSubview:self.allDisabledChat];
    
    self.allDisabledChat.userInteractionEnabled = NO;
    self.allDisabledChat.layer.cornerRadius = (self.bm_height-2*kBMScale_H(9))/2;
    self.allDisabledChat.layer.masksToBounds = YES;
    
    [self.allDisabledChat bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(10);
        make.top.bmmas_equalTo(9);
        make.right.bmmas_equalTo(-10);
        make.bottom.bmmas_equalTo(-9);
    }];
    BOOL everyoneBanChat = [YSLiveManager shareInstance].isEveryoneBanChat;
    self.everyoneBanChat = everyoneBanChat;
    if (everyoneBanChat)
    {
        self.allDisabledChat.text = YSLocalized(@"Prompt.BanChatInView");
    }
    
    self.maskView = [[UIView alloc]initWithFrame:self.bounds];
    self.maskView.backgroundColor = [YSSkinDefineColor(@"blackColor") changeAlpha:0.1];
    [self addSubview:self.maskView];
  
    if (![YSLiveManager shareInstance].isBeginClass)
    {
       if (![YSLiveManager shareInstance].roomConfig.isChatBeforeClass)
       {
           self.maskView.hidden = NO;
        }
        else
        {
            self.maskView.hidden = YES;
        }
    }
    else
    {
        self.maskView.hidden = YES;
    }
        
    self.flowerColourBtn.bm_centerY = self.emotionButton.bm_centerY = self.msgTypeBtn.bm_centerY = self.backView.bm_centerY;
}

#pragma mark - 发送消息（键盘的return按钮点击事件）
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        BOOL disablechat = [YSCurrentUser.properties bm_boolForKey:sUserDisablechat];
        BOOL everyoneBanChat = [YSLiveManager shareInstance].isEveryoneBanChat;
        if (disablechat || everyoneBanChat)
        {
            [BMAlertView ys_showAlertWithTitle:YSLocalized(@"Prompt.BanChat") message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:nil];
            return NO;
        }
        
        BOOL isSucceed = [[YSLiveManager shareInstance] sendMessageWithText:textView.text  withMessageType:YSChatMessageTypeText withMemberModel:self.memberModel];
        
        if (!isSucceed) {
            BMLog(@"d发送失败");
        }
        
        self.inputView.text = nil;
        
        if (_sendMessageToHidKayBoard)
        {
            _sendMessageToHidKayBoard();
        }
        return NO;
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    if (!selectedRange) {//拼音全部输入完成
        NSRange textRange = [textView selectedRange];
        NSString * sss = [self disable_emoji:[textView text]];
        [textView setText:sss];
        [textView setSelectedRange:textRange];
    }
}
//去除键盘联想表情
- (NSString *)disable_emoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@""];
    
    return modifiedString;
}

#pragma mark - 点击小红花
- (void)flowerBtnClick:(UIButton*)sender
{
    
    if (![[YSLiveManager shareInstance].teacher.peerID bm_isNotEmpty]) {
        return;
    }
    
    [[YSLiveManager shareInstance] sendSignalingLiveNoticesSendFlowerWithSenderName:YSCurrentUser.nickName completion:nil];
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"application/octet-stream"
    ]];
    NSMutableURLRequest * request = [YSLiveApiRequest liveGivigGiftsSigninWithGiftsCount:1];
    if (request)
    {
        [self.liveCallRollSigninTask cancel];
        self.liveCallRollSigninTask = nil;
        
        self.liveCallRollSigninTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
            }
            else
            {
#ifdef DEBUG
                NSString *responseStr = [[NSString stringWithFormat:@"%@", responseObject] bm_convertUnicode];
                BMLog(@"%@ %@", response, responseStr);
#endif
            }
        }];
        [self.liveCallRollSigninTask resume];
    }
    sender.selected = YES;
    sender.userInteractionEnabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.selected = NO;
        sender.userInteractionEnabled = YES;
    });
}


#pragma mark - 点击跳转成员列表
- (void)placeholderButtonClick:(UIButton *)sender
{
    BOOL dd = [YSLiveManager shareInstance].roomConfig.isDisablePrivateChat;
    if (![YSLiveManager shareInstance].roomConfig.isDisablePrivateChat)
    {
        if ([self.memberDelegate respondsToSelector:@selector(clickPlaceholderdBtn)])
        {
            [self.memberDelegate clickPlaceholderdBtn];
        }
     }
}

- (void)setMemberModel:(YSRoomUser *)memberModel
{
    _memberModel = memberModel;
    NSString * str = [NSString stringWithFormat:@"%@%@",YSLocalized(@"Label.To"),memberModel.nickName];
    if (![memberModel bm_isNotEmpty]) {
        str = [NSString stringWithFormat:@"%@%@",YSLocalized(@"Label.To"),YSLocalized(@"Label.All")];
    }
    
    NSMutableAttributedString * mutAttrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    //    if (!memberModel.peerID.length || [memberModel.peerID isEqualToString:@"__all"])
    //    {
    //        [mutAttrStr addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]} range:NSMakeRange(2, str.length-2)];
    //    }else
    //    {
    [mutAttrStr addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]}  range:NSMakeRange(0, 2)];
    [mutAttrStr addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#5A8CDC"]}  range:NSMakeRange(2, str.length-2)];
    //    }
    [self.placeholder setAttributedTitle:mutAttrStr forState:UIControlStateNormal];
    CGSize size = [str bm_sizeToFitWidth:200 withFont:UI_FONT_13];
    self.placeholder.bm_width = size.width;
    self.inputView.frame = CGRectMake(CGRectGetMaxX(_placeholder.frame), kBMScale_H(10), kBMScale_W(236)-CGRectGetMaxX(_placeholder.frame)-kBMScale_W(9), kBMScale_H(20));
}


#pragma mark - 点击显示消息类型选择按钮
- (void)msgTypeBtnBtnClick
{
    if (_pushPopooverView)
    {
        _pushPopooverView(_msgTypeBtn);
    }
}


#pragma mark - 表情按钮点击
- (void)emotionButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_inputView resignFirstResponder];
    if (_clickEmotionBtn)
    {
        _clickEmotionBtn(sender);
    }
    sender.selected = !sender.selected;
}

//禁言时控件的响应 (全体禁言和个人禁言)
- (void)setEveryoneBanChat:(BOOL)everyoneBanChat
{
    _everyoneBanChat = everyoneBanChat;
    self.allDisabledChat.hidden = !everyoneBanChat;
    self.userInteractionEnabled = !everyoneBanChat;
    self.inputView.text = nil;
}

@end
