//
//  TKChatMessageModel.h
//  EduClassPad
//
//  Created by ifeng on 2017/5/12.
//  Copyright © 2017年 beijing. All rights reserved.
//

#import "YSLiveEnumHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface YSChatMessageModel : NSObject

///用户名
@property (nullable, nonatomic, strong) YSRoomUser *sendUser;
///接收消息的人的用户名
@property (nullable, nonatomic, strong) YSRoomUser *receiveUser;
///消息时间
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSString *timeStr;
///消息内容
@property (nullable, nonatomic, strong) NSString *message;
///图片链接
@property (nullable, nonatomic, strong) NSString *imageUrl;
///消息类型
@property (nonatomic, assign) YSChatMessageType chatMessageType;
///私聊
@property (nonatomic, assign) BOOL isPersonal;
/// 消息高度
@property (nonatomic, assign) CGFloat messageHeight;
@property (nonatomic, assign) CGSize messageSize;
/// 无翻译时行高
@property (nonatomic, assign) CGFloat cellHeight;
/// 有翻译的时候行高
@property (nonatomic, assign) CGFloat transCellHeight;
/// 翻译后详情
@property (nonatomic, strong) NSString * detailTrans;
/// 翻译后详情文字高度
@property (nonatomic, assign) CGFloat translatHeight;
@property (nonatomic, assign) CGSize translatSize;


///返回富文本（聊天cell文字）
- (nullable NSMutableAttributedString *)emojiViewWithMessage:(NSString*)messageStr font:(int)font;

///根据表情Id和字体大小返回一个图片字符串
- (NSAttributedString *)emojiAttributedStringWithEmojiName:(NSString *)emojiName font:(int)font;

@end

NS_ASSUME_NONNULL_END
