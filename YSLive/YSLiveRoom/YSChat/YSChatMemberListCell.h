//
//  YSChatMemberListCell.h
//  YSLive
//
//  Created by 马迪 on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSChatMemberListCell : UITableViewCell

///是否选中这一行
@property(nonatomic,assign)BOOL isSelected;
///数据模型
@property(nonatomic,strong)YSRoomUser * model;


@end

NS_ASSUME_NONNULL_END
