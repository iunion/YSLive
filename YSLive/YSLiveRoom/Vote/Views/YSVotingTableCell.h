//
//  YSRotingTableViewCell.h
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//  投票中CELL

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YSVoteResultModel;

@interface YSVotingTableCell : UITableViewCell
@property (nonatomic, strong) YSVoteResultModel * votingModel;
@property (nonatomic, assign) BOOL isSingle;

@end

NS_ASSUME_NONNULL_END
