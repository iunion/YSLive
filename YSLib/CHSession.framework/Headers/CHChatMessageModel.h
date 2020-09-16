//
//  CHChatMessageModel.h
//  CHSession
//
//

#import <Foundation/Foundation.h>
#import "CHRoomUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHChatMessageModel : NSObject

/// 发送的用户
@property (nullable, nonatomic, strong) CHRoomUser *sendUser;

/// 发送的用户Id
@property (nullable, nonatomic, strong) NSString *senderPeerId;

/// 发送的用户名
@property (nullable, nonatomic, strong) NSString *senderNickName;

/// 发送的用户role
@property (nullable, nonatomic, strong) NSString *senderRole;

/// 接收消息的人的用户名
@property (nullable, nonatomic, strong) CHRoomUser *receiveUser;
/// 消息时间
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSString *timeStr;
/// 消息内容
@property (nullable, nonatomic, strong) NSString *message;
/// 图片链接
@property (nullable, nonatomic, strong) NSString *imageUrl;
/// 消息类型
@property (nonatomic, assign) CHChatMessageType chatMessageType;
/// 私聊
@property (nonatomic, assign) BOOL isPersonal;
/// 消息高度
@property (nonatomic, assign) CGFloat messageHeight;
@property (nonatomic, assign) CGSize messageSize;
/// 无翻译时行高
@property (nonatomic, assign) CGFloat cellHeight;
/// 有翻译的时候行高
@property (nonatomic, assign) CGFloat transCellHeight;
/// 翻译后详情
@property (nonatomic, strong) NSString *detailTrans;
/// 翻译后详情文字高度
@property (nonatomic, assign) CGFloat translatHeight;
@property (nonatomic, assign) CGSize translatSize;


/// 返回富文本消息（聊天cell文字）
/// @param messageStr 消息字符串
/// @param color 富文本颜色
/// @param font 富文本字体大小
- (nullable NSMutableAttributedString *)emojiViewWithMessage:(NSString *)messageStr color:(UIColor *)color font:(CGFloat)font;

/// 根据表情Id和字体大小返回一个表情图片字符串
/// @param emojiName 表情Id
/// @param font 字体大小
- (NSAttributedString *)emojiAttributedStringWithEmojiName:(NSString *)emojiName font:(CGFloat)font;


@end

NS_ASSUME_NONNULL_END
