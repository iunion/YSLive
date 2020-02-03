//
//  YSVoteResultTableCell.h
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//  投票结果的CELL

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YSVoteResultModel;
@interface YSVoteResultTableCell : UITableViewCell
@property (nonatomic, strong) YSVoteResultModel * resultModel;
@end

NS_ASSUME_NONNULL_END
