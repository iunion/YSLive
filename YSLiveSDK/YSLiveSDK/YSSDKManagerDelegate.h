//
//  YSSDKManagerDelegate.h
//  YSLiveSDK
//
//  Created by fzxm on 2020/10/29.
//  Copyright © 2020 jiang deng. All rights reserved.
//

#ifndef YSSDKManagerDelegate_h
#define YSSDKManagerDelegate_h

@protocol YSSDKManagerDelegate <CHSessionDelegate>

@optional

/// 即将离开房间
- (void)onRoomWillLeft;

@end

#endif /* YSSDKManagerDelegate_h */
