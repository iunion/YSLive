//
//  YSVoteTopView.h
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YSVoteModel;
NS_ASSUME_NONNULL_BEGIN


@interface YSVoteTopView : UIView

@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, strong) YSVoteModel * voteModel;
/// 初始化
/// @param frame frame
/// @param isEnd YES-投票结束  NO-投票中
- (instancetype)initWithFrame:(CGRect)frame withVoteStatus:(BOOL)isEnd;
@end

NS_ASSUME_NONNULL_END
