//
//  YSLiveRoomUser.h
//  YSAll
//
//  Created by jiang deng on 2019/12/27.
//  Copyright © 2019 YS. All rights reserved.
//

#import <YSRoomSDK/YSRoomSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSRoomUser (YSLive)

@property (nonatomic, assign) SCUserPublishState liveUserPublishState;

@end

NS_ASSUME_NONNULL_END
