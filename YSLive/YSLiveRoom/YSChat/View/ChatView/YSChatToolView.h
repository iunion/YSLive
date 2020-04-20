//
//  YSChatToolView.h
//  YSLive
//
//  Created by 马迪 on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSChatToolViewMemberDelegate <NSObject>

///ToolView上placeholderd的点击事件-->跳转成员列表
-(void)clickPlaceholderdBtn;

@end

@interface YSChatToolView : UIView

@property(nonatomic,weak)id<YSChatToolViewMemberDelegate> memberDelegate;
/**
 是否是 自定义视图
 */
@property (nonatomic, assign) BOOL isCustomInputView;
///输入框
@property (nonatomic, strong) UITextView *inputView;//
@property(nonatomic,strong)UIButton * placeholder;
///显示消息类型选择按钮
@property (nonatomic, strong) UIButton *msgTypeBtn;
///表情按钮
@property (nonatomic, strong) UIButton *emotionButton;

///将要发消息的对象
@property (nonatomic, strong) YSRoomUser *memberModel;
///群体禁言
@property (nonatomic, assign) BOOL everyoneBanChat;

///不允许课前互动的蒙版
@property (nonatomic, strong) UIView *maskView;

//全体禁言
@property (nonatomic, strong) UILabel *allDisabledChat;

///ToolView上PopooverView按钮的点击事件
@property(nonatomic,copy)void(^pushPopooverView)(UIButton*popoBtn);
///ToolView上表情按钮的点击事件
@property(nonatomic,copy)void(^clickEmotionBtn)(UIButton*emotionBtn);
///发送消息后键盘回收
@property(nonatomic,copy)void(^sendMessageToHidKayBoard)(void);

@end

NS_ASSUME_NONNULL_END
