//
//  YSAnswerCell.h
//  YSLive
//
//  Created by 马迪 on 2019/10/21.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSAnswerCell : UITableViewCell

@property (nonatomic, strong) YSQuestionModel *model;

@property(nonatomic,copy)void(^translationBtnClick)(void);

@end

NS_ASSUME_NONNULL_END
