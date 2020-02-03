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
//全体禁言
@property (nonatomic, strong) UILabel *allDisabledChat;

@property(nonatomic, strong) NSURLSessionDataTask *liveCallRollSigninTask;

@end

@implementation YSChatToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor bm_colorWithHexString:@"#DEEAFF"];
        [self setupUIView];
    }
    return self;
}

- (void)setupUIView
{
    self.flowerColourBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScale_W(13), kScale_H(14), kScale_W(28), kScale_W(28))];
    [self.flowerColourBtn addTarget:self action:@selector(flowerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.flowerColourBtn setImage:[UIImage imageNamed:@"flowerGray"] forState:UIControlStateSelected];
    [self.flowerColourBtn setImage:[UIImage imageNamed:@"flower"] forState:UIControlStateNormal];
    [self addSubview:self.flowerColourBtn];
    
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.cornerRadius = kScale_H(39)/2;
    self.backView.layer.masksToBounds = YES;
    self.backView.layer.borderColor = UIColor.clearColor.CGColor;
    [self addSubview:self.backView];
    
    CGFloat bottomM = 0.f;
    if (self.bm_height > kScale_H(56))
    {
        bottomM = kScale_H(10)+10;
    }
    else
    {
        bottomM = kScale_H(10);
    }
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kScale_W(50));
        make.top.mas_equalTo(kScale_H(10));
        make.right.mas_equalTo(kScale_W(-90));
        make.bottom.mas_equalTo(-bottomM);
    }];
    
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
    
    [self.placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(kScale_W(14));
        make.height.mas_equalTo(kScale_H(25));
        make.bottom.equalTo(self.backView).offset(kScale_H(-5));
    }];
    
    //输入框
    self.inputView = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_placeholder.frame), kScale_H(5), kScale_W(236)-CGRectGetMaxX(_placeholder.frame)-kScale_W(9), kScale_H(25))];
    self.inputView.backgroundColor = [UIColor whiteColor];
    self.inputView.returnKeyType = UIReturnKeySend;
    self.inputView.font = UI_FONT_15;
    self.inputView.textColor = [UIColor bm_colorWithHexString:@"#2F2F2F"];
    self.inputView.delegate = self;
    //当textview的字符串为0时发送（rerurn）键无效
    self.inputView.enablesReturnKeyAutomatically = YES;
    [self.backView addSubview:self.inputView];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.placeholder.mas_right);
        make.top.equalTo(self.backView).offset(kScale_H(8));
        make.bottom.equalTo(self.backView).offset(kScale_H(-5));
        make.right.equalTo(self.backView).offset(kScale_H(-5));
    }];
    
    _emotionButton = ({
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(kScale_W(298), kScale_H(14), kScale_W(27), kScale_W(27))];
        [button setImage:[UIImage imageNamed:@"emotionYS"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"emotionYS_push"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(emotionButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
        //        [button setBackgroundColor:[UIColor greenColor]];
        button;
    });
    [self addSubview:_emotionButton];
    
    //显示消息类型选择按钮
    _msgTypeBtn = ({
        UIButton * msgTypeBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScale_W(336), kScale_H(14), kScale_W(27), kScale_W(27))];
        [msgTypeBtn addTarget:self action:@selector(msgTypeBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [msgTypeBtn setImage:[UIImage imageNamed:@"messagePersonal"] forState:UIControlStateNormal];
        [msgTypeBtn setImage:[UIImage imageNamed:@"messagePersonal_push"] forState:UIControlStateHighlighted];
        msgTypeBtn;
    });
    [self addSubview:_msgTypeBtn];
    
    //群体禁言
    self.allDisabledChat = [[UILabel alloc] init];
    self.allDisabledChat.backgroundColor = UIColor.whiteColor;
    self.allDisabledChat.textAlignment = NSTextAlignmentCenter;
    [self.allDisabledChat setFont:UI_FONT_13];
    self.allDisabledChat.text = YSLocalized(@"Prompt.BanChatInView");
    self.allDisabledChat.textColor = [UIColor bm_colorWithHexString:@"#738395"];
    [self addSubview:self.allDisabledChat];
    
    self.allDisabledChat.userInteractionEnabled = NO;
    self.allDisabledChat.layer.cornerRadius = (self.bm_height-2*kScale_H(9))/2;
    self.allDisabledChat.layer.masksToBounds = YES;
    
    [self.allDisabledChat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(kScale_H(9));
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(kScale_H(-9));
    }];
    BOOL everyoneBanChat = [YSLiveManager shareInstance].isEveryoneBanChat;
    self.allDisabledChat.hidden = !everyoneBanChat;
    self.userInteractionEnabled = !everyoneBanChat;
    
    self.maskView = [[UIView alloc]initWithFrame:self.bounds];
    self.maskView.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC  alpha:0.6];
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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
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
    self.inputView.frame = CGRectMake(CGRectGetMaxX(_placeholder.frame), kScale_H(10), kScale_W(236)-CGRectGetMaxX(_placeholder.frame)-kScale_W(9), kScale_H(20));
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

//全体禁言
- (void)setEveryoneBanChat:(BOOL)everyoneBanChat
{
    _everyoneBanChat = everyoneBanChat;
    self.allDisabledChat.hidden = !everyoneBanChat;
    self.userInteractionEnabled = !everyoneBanChat;
    self.inputView.text = nil;
}

@end
