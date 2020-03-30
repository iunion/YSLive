//
//  YSQuestionModel.m
//  YSLive
//
//  Created by 马迪 on 2019/10/26.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSQuestionModel.h"

@implementation YSQuestionModel

//提问
- (CGSize)questDetailsSize
{
    if (CGSizeEqualToSize(_questDetailsSize, CGSizeZero))
    {
        self.questDetailsSize = [_questDetails bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_14];
    }
    return _questDetailsSize;
}
//回复
- (CGSize)answerDetailsSize
{
    if (CGSizeEqualToSize(_answerDetailsSize, CGSizeZero))
    {
        _answerDetailsSize = [_answerDetails bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_14];
    }
    return _answerDetailsSize;
}

//翻译
- (CGSize)translatSize
{
    if (CGSizeEqualToSize(_translatSize, CGSizeZero))
    {
        self.translatSize = [self.detailTrans bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_14];
    }
    return _translatSize;
}

//时间戳转字符串
- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    _timeInterval = timeInterval;
    self.timeStr = [NSDate bm_stringFromTs:timeInterval formatter:@"HH:mm:ss"];
}

@end
