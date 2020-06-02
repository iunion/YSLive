//
//  SCChatToolView.m
//  YSLive
//
//  Created by 马迪 on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCChatToolView.h"

#define KIPhoneX  ((BMUI_SCREEN_HEIGHT >= (375.0) && BMUI_SCREEN_WIDTH >= (812.0)) || (BMUI_SCREEN_HEIGHT >= (414.0) && BMUI_SCREEN_WIDTH >= (896)) ?YES:NO)

//textView 的X坐标
#define InputViewX (KIPhoneX?(BMUI_STATUS_BAR_HEIGHT +20):20)


@interface SCChatToolView ()


///图片按钮
@property (nonatomic, strong) UIButton *imageBtn;
///发送按钮
@property (nonatomic, strong) UIButton *sendBtn;

@end


@implementation SCChatToolView

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
    //发送按钮
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-20-92, 13, 92, 34)];

    [self.sendBtn setTitle:YSLocalized(@"Button.send") forState:UIControlStateNormal];
    [self.sendBtn setBackgroundColor:[UIColor bm_colorWithHex:0x5A8CDC]];
    [self.sendBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    [self.sendBtn bm_roundedRect:17.0f borderWidth:3.0f borderColor:[UIColor bm_colorWithHex:0x97B7EB]];
    [self.sendBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn.tag = 1;
    [self addSubview:self.sendBtn];
    
    //图片按钮
    self.imageBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-31-142, 15, 31, 30)];
    [self.imageBtn setImage:[UIImage imageNamed:@"SCChatImage"] forState:UIControlStateNormal];
    [self.imageBtn setImage:[UIImage imageNamed:@"SCChatImage_push"] forState:UIControlStateHighlighted];
    [self.imageBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    self.imageBtn.layer.cornerRadius = 15;
    self.imageBtn.tag = 2;
    [self addSubview:self.imageBtn];
    
    //表情按钮
    self.emojBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-31-204, 15, 31, 30)];
    [self.emojBtn setImage:[UIImage imageNamed:@"SCChatEmotion"] forState:UIControlStateNormal];
    [self.emojBtn setImage:[UIImage imageNamed:@"SCChatEmotion_push"] forState:UIControlStateHighlighted];
    [self.emojBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    self.emojBtn.layer.cornerRadius = 15;
    self.emojBtn.tag = 3;
    [self addSubview:self.emojBtn];
    
    //输入框
    self.inputView = [[UITextView alloc]initWithFrame:CGRectMake(InputViewX, 13, self.emojBtn.bm_originX-InputViewX-10, 34)];
    self.inputView.backgroundColor = UIColor.whiteColor;
    self.inputView.layer.cornerRadius = 7;
    self.inputView.returnKeyType = UIReturnKeyDefault;
    self.inputView.textColor = [UIColor bm_colorWithHexString:@"#828282"];
    self.inputView.font = UI_FONT_15;
    //当textview的字符串为0时发送（rerurn）键无效
    self.inputView.enablesReturnKeyAutomatically = YES;
    [self addSubview:self.inputView];
    self.inputView.tag = SCMessageInputViewTag;
}

- (void)buttonsClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
        {//发送
            BOOL isSucceed = [[YSLiveManager shareInstance] sendMessageWithText:self.inputView.text  withMessageType:YSChatMessageTypeText withMemberModel:nil];
            if (isSucceed)
            {
                self.inputView.text = nil;
            }
        }
            break;
        case 2:
        {//选择图片
            if (_SCChatToolViewButtonsClick)
            {
                _SCChatToolViewButtonsClick(sender);
            }
        }
            break;
        case 3:
        {//选择表情
            if (_SCChatToolViewButtonsClick)
            {
                _SCChatToolViewButtonsClick(sender);
            }
        }
            break;
        default:
            break;
    }
}


@end
