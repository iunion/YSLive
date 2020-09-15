//
//  YSChatMemberListVC.h
//  YSLive
//
//  Created by 马迪 on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSSuperVC.h"


NS_ASSUME_NONNULL_BEGIN

@interface YSChatMemberListVC : YSSuperVC

///私聊成员列表
@property (nonatomic,strong) NSMutableArray<CHRoomUser*> * memberList;
///选中的人的model
@property (nonatomic,strong) CHRoomUser * selectModel;


@property(nonatomic,copy)void(^passTheMemberOfChat)(CHRoomUser*memberModel);

@end

NS_ASSUME_NONNULL_END
