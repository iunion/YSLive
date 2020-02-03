//
//  SCStatisticsTableViewCell.h
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SCAnswerStatisticsModel;

@interface SCStatisticsTableViewCell : UITableViewCell

@property (nonatomic, strong) SCAnswerStatisticsModel * resultModel;

@end

NS_ASSUME_NONNULL_END
