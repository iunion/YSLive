//
//  SCTopToolBarModel.h
//  YSLive
//
//  Created by fzxm on 2019/11/9.
//  Copyright © 2019 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCTopToolBarModel : NSObject
/// 房间号
@property (nonatomic, strong) NSString *roomID;
/// 上课时间
@property (nonatomic, strong) NSString *lessonTime;
/// 网络状态
@property (nonatomic, assign) CHNetQuality netQuality;
/// 网络延迟
@property (nonatomic, assign) NSInteger netDelay;
/// 丢包率
@property (nonatomic, assign) CGFloat lostRate;

@end

NS_ASSUME_NONNULL_END
