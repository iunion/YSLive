//
//  YSLiveManager+SendSignaling.m
//  YSLive
//
//  Created by jiang deng on 2019/10/21.
//Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveManager.h"

@implementation YSLiveManager (SendSignaling)

// toID 定义
// 所有人
//NSString *const YSRoomPubMsgTellAll              = @"__all";
// 除自己以外的所有人
//NSString *const YSRoomPubMsgTellAllExceptSender  = @"__allExceptSender";
// 除旁听用户以外的所有人
//NSString *const YSRoomPubMsgTellAllExceptAuditor = @"__allExceptAuditor";
// 不通知任何人
//NSString *const YSRoomPubMsgTellNone             = @"__None";

// 发布自定义消息
// @param msgName 消息名字
// @param msgID ：消息id
// @param toID 要通知给哪些用户。NSString类型，详情见 YSRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param save ：是否保存，详见3.5：自定义信令
// @param completion 完成的回调
// @return 0表示调用成功，非0表示调用失败
- (BOOL)sendPubMsg:(NSString *)msgName
              toID:(NSString *)toID
              data:(id)data
              save:(BOOL)save
        completion:(completion_block)completion
{
    if (![msgName bm_isNotEmpty] || ![toID bm_isNotEmpty])
    {
        return NO;
    }
    
    if (![YSLiveUtil checkDataType:data])
    {
        return NO;
    }
    
    if (![data bm_isNotEmpty])
    {
        data = @"";
    }

    if ([self.roomManager pubMsg:msgName msgID:msgName toID:toID data:data save:save completion:completion] == 0)
    {
        return YES;
    }
    
    return NO;
}

// expires ：这个消息，多长时间结束，以秒为单位，是相对时间。一般用于classbegin，给定一个相对时间
- (BOOL)sendPubMsg:(NSString *)msgName
              toID:(NSString *)toID
              data:(id)data
              save:(BOOL)save
   associatedMsgID:(NSString *)associatedMsgID
  associatedUserID:(NSString *)associatedUserID
           expires:(NSTimeInterval)expires
        completion:(completion_block)completion
{
    if (![msgName bm_isNotEmpty] || ![toID bm_isNotEmpty])
    {
        return NO;
    }
    
    if (![YSLiveUtil checkDataType:data])
    {
        return NO;
    }
    
    if (![data bm_isNotEmpty])
    {
        data = @"";
    }

    if ([self.roomManager pubMsg:msgName msgID:msgName toID:toID data:data save:save associatedMsgID:associatedMsgID associatedUserID:associatedUserID expires:expires completion:completion] == 0)
    {
        return YES;
    }
    
    return NO;
}

// expendData:拓展数据，与msgName同级
- (BOOL)sendPubMsg:(NSString *)msgName
              toID:(NSString *)toID
              data:(id)data
              save:(BOOL)save
     extensionData:(NSDictionary *)extensionData
        completion:(completion_block)completion
{
    if (![msgName bm_isNotEmpty] || ![toID bm_isNotEmpty])
    {
        return NO;
    }
    
    if (![YSLiveUtil checkDataType:data])
    {
        return NO;
    }
    
    if (![data bm_isNotEmpty])
    {
        data = @"";
    }

    if ([self.roomManager pubMsg:msgName msgID:msgName toID:toID data:data save:save extensionData:extensionData associatedMsgID:nil associatedUserID:nil expires:0 completion:completion] == 0)
    {
        return YES;
    }
    
    return NO;
}

// 删除自定义消息
// @param msgName 消息名字
// @param msgID ：消息id
// @param toID 要通知给哪些用户。NSString类型，详情见 YSRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param completion 完成的回调
// @return 0表示调用成功，非0表示调用失败
- (BOOL)deleteMsg:(NSString *)msgName
            toID:(NSString *)toID
            data:(id)data
      completion:(completion_block)completion
{
    if (![msgName bm_isNotEmpty] || ![toID bm_isNotEmpty])
    {
        return NO;
    }
    
    if (![YSLiveUtil checkDataType:data])
    {
        return NO;
    }
    
    if (![data bm_isNotEmpty])
    {
        data = @"";
    }

    if ([self.roomManager delMsg:msgName msgID:msgName toID:toID data:data completion:completion] == 0)
    {
        return YES;
    }
    
    return NO;
}



#pragma mark -
#pragma mark 信令

/// 客户端请求关闭信令服务器房间
- (BOOL)sendSignalingDestroyServerRoomWithCompletion:(completion_block)completion
{
    return ([self sendPubMsg:YSSignalingName_Notice_Server_RoomEnd toID:YSRoomPubMsgTellNone data:@"" save:NO completion:completion]);
    
    return NO;
}

// 同步服务器时间
- (BOOL)sendSignalingUpdateTimeWithCompletion:(completion_block)completion
{
    NSString *peerId = self.localUser.peerID;
    if ([peerId bm_isNotEmpty])
    {
        return ([self sendPubMsg:YSSignalingName_UpdateTime toID:peerId data:@"" save:NO associatedMsgID:nil associatedUserID:nil expires:0 completion:completion]);
    }
    
    return NO;
}

// 发起点名
// stateType    0--1分钟  1--3分钟  2--5分钟  3--10分钟  4--30分钟
- (BOOL)sendSignalingLiveCallRollWithStateType:(NSUInteger)stateType completion:(completion_block)completion
{
    if (self.localUser.role != YSUserType_Teacher)
    {
        return NO;
    }
    
    NSDictionary *sendDic = @{ @"stateType" : @(stateType) };
    
    return ([self sendPubMsg:YSSignalingName_LiveCallRoll toID:YSRoomPubMsgTellAllExceptSender data:sendDic save:NO completion:completion]);
}

// 结束点名
- (BOOL)closeSignalingLiveCallRollWithcompletion:(completion_block)completion
{
    if (self.localUser.role != YSUserType_Teacher)
    {
        return NO;
    }
    
    return ([self deleteMsg:YSSignalingName_LiveCallRoll toID:YSRoomPubMsgTellAllExceptSender data:@"" completion:completion]);
}

// 发起抽奖
- (BOOL)sendSignalingLiveLuckDrawWithCompletion:(completion_block)completion
{
    if (self.localUser.role != YSUserType_Teacher)
    {
        return NO;
    }
    
    return ([self sendPubMsg:YSSignalingName_LiveLuckDraw toID:YSRoomPubMsgTellAll data:@"" save:YES completion:completion]);
}


// 上麦申请
- (BOOL)sendSignalingUpPlatformWithCompletion:(completion_block)completion
{
    
    long time =1000 * (long)self.tCurrentTime;
    NSDictionary *actions = @{ @"id" : self.localUser.peerID,@"name":self.localUser.nickName,@"time":@(time)};
    NSString * dataStr = [actions bm_toJSON];
    NSDictionary * dataDict = @{self.localUser.peerID:dataStr};
    
    NSDictionary * extensionData = @{@"actions":dataDict,@"modify":@0,@"type":@"sort"};
    
    NSString * msgID = [NSString stringWithFormat:@"TestSortCommitId_%@",self.localUser.peerID];
       
    NSString * UpPlatFormId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UpPlatFormId"];
    
    return  ([self.roomManager pubMsg:YSSignalingName_ApplyUpPlatForm msgID:msgID toID:YSRoomPubMsgTellNone data:@"" save:NO extensionData:extensionData associatedMsgID:UpPlatFormId associatedUserID:self.localUser.peerID expires:0 completion:completion] == 0);
    
}

/// 上麦申请结果
- (BOOL)answerSignalingUpPlatformWithCompletion:(completion_block)completion
{
    NSDictionary *actions = @{ @"id" : self.localUser.peerID,@"name":self.localUser.nickName,@"time":@(self.tCurrentTime)};
    NSString * dataStr = [actions bm_toJSON];
    NSDictionary * dataDict = @{self.localUser.peerID:dataStr};
    
    NSDictionary * extensionData = @{@"actions":dataDict,@"modify":@1,@"type":@"sort"};
    
    
    NSString * msgID = [NSString stringWithFormat:@"TestSortCommitId_%@",self.localUser.peerID];
    
    NSString * UpPlatFormId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UpPlatFormId"];
    
    int ii = [self.roomManager pubMsg:YSSignalingName_ApplyUpPlatForm msgID:msgID toID:YSRoomPubMsgTellNone data:@"" save:NO extensionData:extensionData associatedMsgID:UpPlatFormId associatedUserID:self.localUser.peerID expires:0 completion:completion];
    
    return  (ii);
    
}


// 发起投票
//- (BOOL)sendSignalingVoteStartWithCompletion:(completion_block)completion
//{
//    if (self.localUser.role != YSUserType_Teacher)
//    {
//        return NO;
//    }
//    
//data: "{"voteId":"2928553212019102388758","sendVoteUserName":"老师","subject":"呱呱","desc":"哒哒哒哒哒哒","pattern":"multi","status":"voting","options":[{"isRight":false,"content":"11111111","count":0},{"isRight":false,"content":"222222","count":0},{"isRight":false,"content":"333333","count":0}],"sendVoteTime":"10-23 15:46","createTime":1571816808152}"
//
//
//    return [self sendPubMsg:YSSignalingName_LiveLuckDraw toID:YSRoomPubMsgTellAll data:nil save:NO completion:completion];
//}


// 发送投票
- (BOOL)sendSignalingVoteCommitWithVoteId:(NSString *)voteId voteResault:(NSArray *)voteResault completion:(completion_block)completion
{
    NSMutableDictionary *actions = [[NSMutableDictionary alloc] init];
    for (NSString *vote in voteResault)
    {
        [actions setObject:@(1) forKey:vote];
    }
    NSDictionary *extensionData = @{ @"actions" :  actions,@"modify":@(0), @"type":@"count" };
    
    return ([self.roomManager pubMsg:YSSignalingName_VoteCommit msgID:voteId toID:YSRoomPubMsgTellNone data:@"" save:NO extensionData:extensionData associatedMsgID:nil associatedUserID:nil expires:0 completion:completion] == 0);
}

// 通知
- (BOOL)sendSignalingLiveNoticeInfoWithNotice:(NSString *)text completion:(completion_block)completion
{
    return [self sendSignalingLiveNoticeInfoWithNotice:text toID:YSRoomPubMsgTellAll completion:completion];
}

- (BOOL)sendSignalingLiveNoticeInfoWithNotice:(NSString *)text toID:(NSString *)peerId completion:(completion_block)completion
{
    NSDictionary *sendDic = @{ @"text" : text };
    if (![peerId bm_isNotEmpty])
    {
        peerId = YSRoomPubMsgTellAll;
    }
    
    return ([self sendPubMsg:YSSignalingName_LiveNoticeInform toID:peerId data:sendDic save:NO completion:completion]);
}

// 公告
- (BOOL)sendSignalingLiveNoticeBoardWithNotice:(NSString *)text completion:(completion_block)completion
{
    NSDictionary *sendDic = @{ @"text" : text };
    
    return ([self sendPubMsg:YSSignalingName_LiveNoticeBoard toID:YSRoomPubMsgTellAll data:sendDic save:NO completion:completion]);
}

/// 送花
- (BOOL)sendSignalingLiveNoticesSendFlowerWithSenderName:(NSString *)nickName completion:(completion_block)completion
{
    NSDictionary *sendDic = @{ @"nickname" : nickName, @"num" : @1, @"senderId" : self.localUser.peerID};
    
    return ([self sendPubMsg:YSSignalingName_SendFlower toID:YSRoomPubMsgTellAll data:sendDic save:NO completion:completion]);
}

/// 发送答题卡答案
- (BOOL)sendSignalingAnwserCommitWithAnswerId:(NSString *)answerId anwserResault:(NSArray *)answerResault completion:(completion_block)completion
{
    NSMutableDictionary *actions = [[NSMutableDictionary alloc] init];
    for (NSString *answer in answerResault)
    {
        [actions setObject:@(1) forKey:answer];
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:answerResault];
    [tempArr sortUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        
        return [obj1 compare:obj2];
    }];
    NSString *mineResultStr = [tempArr componentsJoinedByString:@","];
    NSDictionary *extensionData = @{ @"actions" :  actions,@"modify":@(0), @"type":@"count" ,@"write2DB":@1,@"data":mineResultStr};
    
    return ([self.roomManager pubMsg:YSSignalingName_AnswerCommit msgID:answerId toID:YSRoomPubMsgTellNone data:@"" save:NO extensionData:extensionData associatedMsgID:nil associatedUserID:nil expires:0 completion:completion] == 0);
}

/// 修改答题卡答案
- (BOOL)sendSignalingAnwserModifyWithAnswerId:(NSString *)answerId addAnwserResault:(NSArray *)addAnwserResault  delAnwserResault:(NSArray *)delAnwserResault notChangeAnwserResault:(NSArray *)notChangeAnwserResault completion:(completion_block)completion
{
    NSMutableDictionary *actions = [[NSMutableDictionary alloc] init];
    for (NSString *answer in addAnwserResault)
    {
        [actions setObject:@(1) forKey:answer];
    }
    for (NSString *answer in delAnwserResault)
    {
        [actions setObject:@(-1) forKey:answer];
    }
    for (NSString *answer in notChangeAnwserResault)
    {
        [actions setObject:@(0) forKey:answer];
    }
    
    NSArray *mineResultArr = [notChangeAnwserResault arrayByAddingObjectsFromArray:addAnwserResault];
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:mineResultArr];
    [tempArr sortUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        
        return [obj1 compare:obj2];
    }];
    NSString *mineResultStr = [tempArr componentsJoinedByString:@","];
    NSDictionary *extensionData = @{ @"actions" :  actions,@"modify":@(1), @"type":@"count" ,@"write2DB":@1,@"data":mineResultStr};


    return ([self.roomManager pubMsg:YSSignalingName_AnswerCommit msgID:answerId toID:YSRoomPubMsgTellNone data:@"" save:NO extensionData:extensionData associatedMsgID:nil associatedUserID:nil expires:0 completion:completion] == 0);
}


- (BOOL)sendSignalingStudentContestCommitCompletion:(completion_block)completion
{
    NSDictionary *sendDic = @{@"peerId" : self.localUser.peerID};
    
//    return ([self.roomManager pubMsg:YSSignalingName_ContestCommit msgID:YSSignalingName_ContestCommit toID:YSRoomPubMsgTellAll data:nil save:NO extensionData:sendDic associatedMsgID:nil associatedUserID:nil expires:0 completion:completion] == 0);
    
    return ([self sendPubMsg:YSSignalingName_ContestCommit toID:@"__allSuperUsers" data:[sendDic bm_toJSON] save:NO completion:completion]);
}
@end

