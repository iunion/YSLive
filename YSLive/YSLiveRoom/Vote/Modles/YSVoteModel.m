//
//  YSVoteModel.m
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSVoteModel.h"

@implementation YSVoteModel

- (CGSize)subjectSize
{
    NSString * str = [NSString stringWithFormat:@"%@",_subject];
    _subjectSize = [str bm_sizeToFitWidth:BMUI_SCREEN_WIDTH-30 - 30 - 36 - 3 withFont:UI_FSFONT_MAKE(FontNamePingFangSCRegular, 18)];

    return _subjectSize;
}

- (CGFloat)rightAnswerHeight
{
   
    NSString * str = [NSString stringWithFormat:@"%@：%@",YSLocalized(@"tool.zhengquedaan"),_rightAnswer];
    _rightAnswerHeight = [str bm_sizeToFitWidth:BMUI_SCREEN_WIDTH - 20 withFont:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12)].height;
    return _rightAnswerHeight;
}
- (NSString *)desc
{
    if (!_desc)
    {
        _desc = [_desc bm_isNotEmpty] ? _desc : @"";
    }
    return _desc;
}
@end

@implementation YSVoteResultModel

- (CGFloat)endCellHeight
{
    if (!_endCellHeight)
    {
        _endCellHeight = [_title bm_sizeToFitWidth:BMUI_SCREEN_WIDTH - 30 - 30 withFont:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 12)].height + 5;
    }
    return _endCellHeight;
}

- (CGFloat)ingCellHeight
{
    if (!_ingCellHeight)
    {
        _ingCellHeight = [_title bm_sizeToFitWidth:BMUI_SCREEN_WIDTH - 22 - 17 - 22 - 5 - 10 withFont:UI_FSFONT_MAKE(FontNamePingFangSCMedium, 16)].height + 5;
    }
    return _ingCellHeight;
}

@end
