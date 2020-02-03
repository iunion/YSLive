//
//  YSVoteVC.h
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//



#import "YSSuperVC.h"
#import "YSVoteModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YSVoteVCType)
{
    /// 投票结果
    YSVoteVCType_Result,
    /// 多选投票页
    YSVoteVCType_Multiple,
    /// 单选投票页
    YSVoteVCType_Single
};


@interface YSVoteVC : YSSuperVC


@property (nonatomic, assign) YSVoteVCType voteType;
/// 投票详情
@property (nonatomic, strong) YSVoteModel *voteModel;
/// 数据源
@property (nonatomic, strong) NSArray <YSVoteResultModel *> *dataSource;

@end

NS_ASSUME_NONNULL_END
