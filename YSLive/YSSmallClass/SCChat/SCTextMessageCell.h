//
//  SCChatTableViewCell.h
//  YSLive
//
//  Created by 马迪 on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSChatMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCTextMessageCell : UITableViewCell

@property (nonatomic, strong) YSChatMessageModel *model;

@property (nonatomic, copy) void(^translationBtnClick)(void);

@end

NS_ASSUME_NONNULL_END
