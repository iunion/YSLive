//
//  TKNewPictureCell.h
//  EduClass
//
//  Created by talkcloud on 2019/7/11.
//  Copyright © 2019 talkcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSChatMessageModel.h"
#import "YSChatBasicTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSNewPictureCell : YSChatBasicTableViewCell

@property (nonatomic, strong) YSChatMessageModel *model;
//@property (nonatomic, strong) NSDictionary *chatDict;

@end

NS_ASSUME_NONNULL_END
