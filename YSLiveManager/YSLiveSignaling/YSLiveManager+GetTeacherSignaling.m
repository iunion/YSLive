//
//  YSLiveManager+GetTeacherSignaling.m
//  YSAll
//
//  Created by 马迪 on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSLiveManager.h"

@implementation YSLiveManager (GetTeacherSignaling)

// 收到自定义信令 发布消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (BOOL)handleRoomTeacherPubMsgWithMsgID:(NSString *)msgID
                                 msgName:(NSString *)msgName
                                    data:(NSObject *)data
                                  fromID:(NSString *)fromID
                                  inList:(BOOL)inlist
                                      ts:(long)ts
{
    
    // 转换数据
    NSDictionary *dataDic = [YSLiveUtil convertWithData:data];
    NSNumber *dataNum = nil;
    if (![dataDic bm_isNotEmptyDictionary])
    {
        dataNum = (NSNumber *)data;
    }
    return NO;
}


// 收到自定义信令 删去消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (BOOL)handleRoomTeacherDelMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                             data:(NSObject *)data
                           fromID:(NSString *)fromID
                           inList:(BOOL)inlist
                               ts:(long)ts
{
    NSDictionary *dataDic = [YSLiveUtil convertWithData:data];
    NSNumber *dataNum = nil;
    if (![dataDic bm_isNotEmptyDictionary])
    {
        dataNum = (NSNumber *)data;
    }

    return NO;
}


@end
