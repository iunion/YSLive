//
//  TMNewMessageCell.h
//  EduClass
//
//  Created by talk on 2018/11/21.
//  Copyright © 2018年 talkcloud. All rights reserved.
//


#import "YSChatMessageModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface YSNewTipMessageCell : UITableViewCell

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) YSChatMessageModel *model;

@end

NS_ASSUME_NONNULL_END
