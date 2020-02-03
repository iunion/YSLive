//
//  YSRoomUser+YSLive.m
//  YSAll
//
//  Created by jiang deng on 2019/12/27.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSRoomUser+YSLive.h"
#import "YSLiveManager.h"

@implementation YSRoomUser (YSLive)

- (SCUserPublishState)liveUserPublishState
{
    YSPublishState publishState = [self.properties bm_intForKey:sUserPublishstate];
    
    switch (publishState)
    {
        case YSUser_PublishState_UNKown:
            return SCUserPublishState_NONE;
            
        case YSUser_PublishState_AUDIOONLY:
            return SCUserPublishState_NONEONSTAGE | SCUserPublishState_AUDIOONLY;
            
        case YSUser_PublishState_VIDEOONLY:
            return SCUserPublishState_NONEONSTAGE | SCUserPublishState_VIDEOONLY;
            
        case YSUser_PublishState_BOTH:
            return SCUserPublishState_NONEONSTAGE | SCUserPublishState_BOTH;
            
        case 4:
            return SCUserPublishState_NONEONSTAGE;
            
        default:
            return SCUserPublishState_NONE;
    }
}

- (void)setLiveUserPublishState:(SCUserPublishState)liveUserPublishState
{
    YSPublishState publishState = YSUser_PublishState_NONE;
    
    switch (liveUserPublishState)
    {
        case SCUserPublishState_BOTH | SCUserPublishState_NONEONSTAGE:
            publishState = YSUser_PublishState_BOTH;
            break;
            
        case SCUserPublishState_AUDIOONLY | SCUserPublishState_NONEONSTAGE:
            publishState = YSUser_PublishState_AUDIOONLY;
            break;
            
        case SCUserPublishState_VIDEOONLY | SCUserPublishState_NONEONSTAGE:
            publishState = YSUser_PublishState_VIDEOONLY;
            break;
            
        case SCUserPublishState_NONEONSTAGE:
            publishState = 4;
            break;
            
        case SCUserPublishState_NONE:
            publishState = YSUser_PublishState_NONE;
            break;
            
        default:
            break;
    }
    
    [[YSLiveManager shareInstance].roomManager changeUserProperty:self.peerID tellWhom:YSRoomPubMsgTellAll key:sUserPublishstate value:@(publishState) completion:nil];
}

@end
