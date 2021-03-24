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
        self.backgroundColor = YSSkinDefineColor(@"Color2");
        [self setupUIView];
    }
    return self;
}

- (void)setupUIView
{
    //发送按钮
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-20-92, 13, 92, 34)];

    [self.sendBtn setTitle:YSLocalized(@"Button.send") forState:UIControlStateNormal];
    [self.sendBtn setBackgroundColor:YSSkinDefineColor(@"Color4")];
    [self.sendBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn.tag = 1;
    [self addSubview:self.sendBtn];
    self.sendBtn.layer.cornerRadius = 34/2;
    
    //图片按钮
    self.imageBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-31-142, 15, 31, 30)];
    [self.imageBtn setImage:YSSkinElementImage(@"chatTool_imageBtn", @"iconNor") forState:UIControlStateNormal];
    [self.imageBtn setImage:YSSkinElementImage(@"chatTool_imageBtn", @"iconSel") forState:UIControlStateHighlighted];
    [self.imageBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    self.imageBtn.tag = 2;
    [self addSubview:self.imageBtn];
    
    //表情按钮
    UIButton * emojBtn = [[UIButton alloc]initWithFrame:CGRectMake(BMUI_SCREEN_WIDTH-31-204, 15, 31, 30)];
    [emojBtn setImage:YSSkinElementImage(@"chatTool_emijeBtn", @"iconNor") forState:UIControlStateNormal];
    [emojBtn setImage:YSSkinElementImage(@"chatTool_emijeBtn", @"iconSel") forState:UIControlStateHighlighted];
    [emojBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    emojBtn.tag = 3;
    [self addSubview:emojBtn];
    self.emojBtn = emojBtn;
    
    UIView * inputBackView = [[UIView alloc]initWithFrame:CGRectMake(InputViewX, 13, self.emojBtn.bm_originX-InputViewX-10, 34)];
    inputBackView.backgroundColor = YSSkinDefineColor(@"Color2");
    inputBackView.layer.cornerRadius = 34/2;
    inputBackView.layer.borderWidth = 1.0;  // 给图层添加一个有色边框
    inputBackView.layer.borderColor = YSSkinDefineColor(@"Color7").CGColor;
    [self addSubview:inputBackView];
    
    //输入框
    UITextView * inputView = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, inputBackView.bm_width-15, 34)];
    inputView.backgroundColor = UIColor.clearColor;
    inputView.returnKeyType = UIReturnKeyDefault;
    inputView.textColor = YSSkinDefineColor(@"Color3");
    inputView.font = UI_FONT_15;
    //当textview的字符串为0时发送（rerurn）键无效
    inputView.enablesReturnKeyAutomatically = YES;
    inputView.tag = SCMessageInputViewTag;
    [inputBackView addSubview:inputView];
    self.inputView = inputView;
}

- (void)buttonsClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
        {//发送
            BOOL isSucceed = [[YSLiveManager sharedInstance] sendMessageWithText:self.inputView.text  withMessageType:CHChatMessageType_Text withMemberModel:nil];
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
