//
//  TKChatMessageModel.m
//  EduClassPad
//
//  Created by ifeng on 2017/5/12.
//  Copyright © 2017年 beijing. All rights reserved.
//

#import "YSChatMessageModel.h"
#import "PTTextAttachment.h"

@implementation YSChatMessageModel

- (YSRoomUser *)sendUser
{
    if (!_sendUser)
    {
        _sendUser = [[YSRoomUser alloc]init];
    }
    return _sendUser;
}
- (YSRoomUser *)receiveUser
{
    if (!_receiveUser)
    {
        _receiveUser = [[YSRoomUser alloc]init];
    }
    return _receiveUser;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    _timeInterval = timeInterval;
    self.timeStr = [NSDate bm_stringFromTs:timeInterval formatter:@"HH:mm:ss"];
}

- (CGFloat)messageHeight
{
    if (!_messageHeight)
    {
        _messageHeight = [self.message bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_15].height;
        
    }
    return _messageHeight;
}

//翻译
- (CGFloat)translatHeight
{
    if (!_translatHeight)
    {
        _translatHeight = [_detailTrans bm_sizeToFitWidth:BMUI_SCREEN_WIDTH - 50 withFont:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 14)].height;
    }
    return _translatHeight;
}


#pragma mark - 返回富文本（聊天cell文字）

- (NSMutableAttributedString *)emojiViewWithMessage:(NSString*)messageStr font:(int)font
{
    if (![messageStr bm_isNotEmpty])
    {
        return nil;
    }
    
    NSString *regexString = @"(\\[em_)\\d{1}(\\])";
    // 创建正则表达
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    // 开始匹配
    NSArray *matches = [regex matchesInString:messageStr options:0 range:NSMakeRange(0, [messageStr length])];
    NSInteger strLength = 0;
    // 富文本
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc]initWithString:messageStr];
    // 遍历匹配完成的字符串数组去除匹配值
    for (int i = 0; i < matches.count; i ++)
    {
        NSTextCheckingResult *match = matches[i];
        
        NSString *component = [messageStr substringWithRange:match.range];
        // 取值name em_1
        NSString *subString = [component substringWithRange:NSMakeRange(1, component.length - 2)];
        
        NSAttributedString * attStr = [self emojiAttributedStringWithEmojiName:subString font:font];
        NSRange rang = NSMakeRange([match rangeAtIndex:0].location - strLength, [match rangeAtIndex:0].length);
        
        // 开始替换
        if ((rang.location+rang.length)<= emojiAttributedString.length) {
            [emojiAttributedString replaceCharactersInRange:rang withAttributedString:attStr];
            strLength += match.range.length-1 ;
        }
    }
    
    // 设置富文本属性
    [emojiAttributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil] range:NSMakeRange(0, emojiAttributedString.length)];
    
    return emojiAttributedString;
}

#pragma mark - 根据表情Id和字体大小返回一个图片字符串
- (NSAttributedString *)emojiAttributedStringWithEmojiName:(NSString *)emojiName font:(int)font
{
    NSString *emojiPath =  [[NSBundle mainBundle] pathForResource:emojiName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:emojiPath];
    if (!image)
    {
        image = [UIImage imageNamed:emojiName];
    }
    
    PTTextAttachment *attment = [[PTTextAttachment alloc]init];
    
    CGSize maxsize = CGSizeMake(1000, MAXFLOAT);
    // 计算表情的大小
    CGSize size = [@"/" boundingRectWithSize:maxsize options:NSStringDrawingUsesLineFragmentOrigin attributes:[self setAttributes:font] context:nil].size;
    
    attment.emojiSize = CGSizeMake(size.height, size.height);
    attment.image = image;
    
    NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:attment];
    
    return str;
}


//设置富文本属性
- (NSDictionary *)setAttributes:(int)font
{
    // 设置富文本属性
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:4];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    return dict;
}



@end
