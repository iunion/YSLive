//
//  YSBarrageTrackInfo.h
//  YSBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSBarrageTrackInfo : NSObject

@property (nonatomic, assign) NSInteger trackIndex;
@property (nullable, nonatomic, copy) NSString *trackIdentifier;
/// 下次可用的时间
@property (nonatomic, assign) CFTimeInterval nextAvailableTime;
/// 当前行的弹幕数量
@property (nonatomic, assign) NSInteger barrageCount;
/// 轨道高度
@property (nonatomic, assign) CGFloat trackHeight;

@end

NS_ASSUME_NONNULL_END
