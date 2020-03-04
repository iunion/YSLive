//
//  SCChatToolView.h
//  YSLive
//
//  Created by 马迪 on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define SCMessageInputViewTag   10

@interface SCChatToolView : UIView

@property(nonatomic,copy)void(^SCChatToolViewButtonsClick)(UIButton *sender);

@property(nonatomic,copy)void(^toShowTextNumberAlert)(void);

///输入框
@property (nonatomic, strong) UITextView *inputView;
///表情按钮
@property (nonatomic, strong) UIButton *emojBtn;

@end

NS_ASSUME_NONNULL_END
