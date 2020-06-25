//
//  SCChatView.h
//  ddddd
//
//  Created by 马迪 on 2019/11/6.
//  Copyright © 2019 马迪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSChatMessageModel.h"
//#import "SCChatBottomToolView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCChatView : UIView

/// 聊天tableView
@property (nonatomic, strong) UITableView *SCChatTableView;

///是否禁言
@property(nonatomic,assign)BOOL allDisabled;

///聊天列表数组(全部的)
@property (nonatomic, strong) NSMutableArray <YSChatMessageModel *> *SCMessageList;

///点击底部输入按钮，弹起键盘
@property (nonatomic, copy)void(^textBtnClick)(void);

///点击视图收起键盘
@property (nonatomic, copy)void(^clickViewToHiddenTheKeyBoard)(void);


@end

NS_ASSUME_NONNULL_END
