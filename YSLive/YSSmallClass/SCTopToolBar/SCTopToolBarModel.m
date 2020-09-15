//
//  SCTopToolBarModel.m
//  YSLive
//
//  Created by fzxm on 2019/11/9.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTopToolBarModel.h"

@implementation SCTopToolBarModel
- (instancetype)init
{
    if (self = [super init]) {
        self.roomID = @"";
        self.lessonTime = @"00:00:00";
        self.netQuality =CHNetQuality_Good;
        self.netDelay = 0;
        self.lostRate = 0;
    }
    return self;
}
- (NSString *)roomID
{
    if (!_roomID)
    {
        _roomID = @"";
    }
    return _roomID;
}
- (NSString *)lessonTime
{
    if (!_lessonTime)
    {
        _lessonTime = @"";
    }
    return _lessonTime;
}

- (CHNetQuality)netQuality
{
    if (!_netQuality)
    {
        _netQuality = CHNetQuality_Good;
    }
    return _netQuality;
}

- (NSInteger)netDelay
{
    if (!_netDelay)
    {
        _netDelay = 0;
    }
    return _netDelay;
}
- (CGFloat)lostRate
{
    if (!_lostRate)
    {
        _lostRate = 0;
    }
    
    return _lostRate;
}
@end
