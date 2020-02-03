//
//  YSQuestionModel.h
//  YSLive
//
//  Created by 马迪 on 2019/10/26.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveEnumHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface YSQuestionModel : NSObject

/// 消息状态
@property (nonatomic, assign) YSQuestionState state;
/// id
@property (nonatomic, strong) NSString *questionId;
/// 提问者名字
@property (nonatomic, strong) NSString *nickName;
///接收消息的人的用户名
@property (nonatomic, strong) NSString *toUserNickname;
/// 提问时间戳
@property (nonatomic, assign) NSTimeInterval timeInterval;
/// 消息时间字符串
@property (nonatomic, strong) NSString *timeStr;
/// 提问详情
@property (nonatomic, strong) NSString *questDetails;
/// 提问详情文字size
@property (nonatomic, assign) CGSize questDetailsSize;
/// 回复详情
@property (nonatomic, strong) NSString *answerDetails;
/// 回复详情文字size
@property (nonatomic, assign) CGSize answerDetailsSize;
/// 提问/回复 详情(翻译后)
@property (nonatomic, strong) NSString * detailTrans;
/// 提问/回复 详情文字高度(翻译后)
@property (nonatomic, assign) CGSize translatSize;
/// 没有翻译的时候行高
@property (nonatomic, assign) CGFloat cellHeight;
/// 有翻译的时候行高
@property (nonatomic, assign) CGFloat transCellHeight;

@end


NS_ASSUME_NONNULL_END
