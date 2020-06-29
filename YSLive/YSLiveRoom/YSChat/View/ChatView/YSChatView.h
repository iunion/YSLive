//
//  YSChatView.h
//  YSLive
//
//  Created by 马迪 on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TKChatToolView.h"
#import "YSChatToolView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSMessageShowType) {
    
    YSMessageShowTypeAll,        /** 显示全部信息 */
    YSMessageShowTypeMain,       /** 显示自己的信息 */
    YSMessageShowTypeAnchor,     /** 显示主播的信息 */
};

@interface YSChatView : UIView

/// 聊天tableView
@property (nonatomic, strong) UITableView *chatTableView;
///实际 聊天输入工具条
@property (nonatomic, strong) YSChatToolView *chatToolView;
///当前显示消息的类型
@property(nonatomic,assign)YSMessageShowType showType;
///聊天列表数组(全部的)
@property (nonatomic, strong) NSMutableArray<YSChatMessageModel *>  *messageList;
///聊天列表数组(主播的)
@property (nonatomic, strong) NSMutableArray<YSChatMessageModel *>  *anchorMessageList;
///聊天列表数组(我的)
@property (nonatomic, strong) NSMutableArray<YSChatMessageModel *>  *mainMessageList;

///添加私聊名单时的block
@property(nonatomic,copy)void(^addChatMember)(YSRoomUser * memberModel);


//滚动或点击空白时，键盘回归原位
-(void)toHiddenKeyBoard;
//刷新tableView
- (void)reloadTableView;
///接收到送花消息
- (void)receiveFlowrsWithSenderId:(NSString *)senderId senderName:(NSString *)senderName;

@end

NS_ASSUME_NONNULL_END
