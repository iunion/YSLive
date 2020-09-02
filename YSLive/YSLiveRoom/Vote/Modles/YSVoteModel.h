//
//  YSVoteModel.h
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSVoteModel : NSObject
@property (nonatomic, strong) NSString * teacherName;
@property (nonatomic, strong) NSString * timeStr;
@property (nonatomic, strong) NSString * voteId;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSString * desc;
@property (nonatomic, strong) NSString * rightAnswer;

@property (nonatomic, assign) CGSize subjectSize;
@property (nonatomic, assign) CGFloat rightAnswerHeight;
@property (nonatomic, assign) CGFloat topViewHeight;
@property (nonatomic, assign) BOOL isSingle;
@end

@interface YSVoteResultModel : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * number;
@property (nonatomic, strong) NSString * total;

@property (nonatomic, assign) BOOL isSelect;
/// cell height
@property (nonatomic, assign) CGFloat endCellHeight;
@property (nonatomic, assign) CGFloat ingCellHeight;
@end
NS_ASSUME_NONNULL_END
