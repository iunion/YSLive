//
//  SCTipsMessageCell.h
//  YSLive
//
//  Created by 马迪 on 2019/11/16.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCTipsMessageCell : UITableViewCell

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) CHChatMessageModel *model;

@end

NS_ASSUME_NONNULL_END
