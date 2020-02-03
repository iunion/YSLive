//
//  YSLessonModel.m
//  YSLive
//
//  Created by fzxm on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLessonModel.h"

@implementation YSLessonModel
- (CGFloat)nameHeight
{
    if (!_nameHeight)
    {
        _nameHeight = [_name bm_sizeToFitWidth:UI_SCREEN_WIDTH - 72 - 62 withFont:UI_FSFONT_MAKE(FontNamePingFangSCRegular, 14)].height + 5;
    }
    return _nameHeight;
}
- (CGFloat)detailsHeight
{
    if (!_detailsHeight)
    {
        _detailsHeight = [_details bm_sizeToFitWidth:UI_SCREEN_WIDTH - 62 - 72 withFont:UI_FSFONT_MAKE(FontNamePingFangSCRegular, 14)].height;
    }
    return _detailsHeight;
}

- (CGFloat)translatHeight
{
    if (!_translatHeight)
    {
        _translatHeight = [_detailTrans bm_sizeToFitWidth:UI_SCREEN_WIDTH - 62 - 72 withFont:UI_FSFONT_MAKE(FontNamePingFangSCRegular, 14)].height;
    }
    return _translatHeight;
}
@end
