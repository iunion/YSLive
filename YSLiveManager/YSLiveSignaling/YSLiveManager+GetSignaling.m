//
//  YSLiveManager+GetSignaling.m
//  YSLive
//
//  Created by jiang deng on 2019/10/22.
//Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveManager.h"
#import "YSQuestionModel.h"

@implementation YSLiveManager (GetSignaling)

// room信令会同时发布到whitebord 只在handleWhiteBroadPubMsgWithMsgID中l处理即可

// 收到自定义信令 发布消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (void)handleRoomPubMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                             data:(NSObject *)data
                           fromID:(NSString *)fromID
                           inList:(BOOL)inlist
                               ts:(long)ts
                             body:(NSDictionary *)msgBody
{
    if (![msgID bm_isNotEmpty] || ![msgName bm_isNotEmpty])
    {
        return;
    }

//    if (![msgName isEqualToString:@"Server_Sort_Result"])
//    {
////        NSLog(@"weee");
//    }
    
    ///全体静音 全体发言
    if ([msgName isEqualToString:YSSignalingName_LiveAllNoAudio])
    {
        BMLog(@"全体静音");
        self.isEveryoneNoAudio = YES;
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToliveAllNoAudio:)])
        {
            [self.roomManagerDelegate handleSignalingToliveAllNoAudio:YES];
        }
        return;
    }
    
    // 不是备份信令时同步服务器时间
    if (!inlist && [msgName isEqualToString:YSSignalingName_UpdateTime])
    {
        NSTimeInterval timeInterval = ts;
        self.tServiceTime = timeInterval;
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingUpdateTimeWithTimeInterval:)])
        {
            [self.roomManagerDelegate handleSignalingUpdateTimeWithTimeInterval:timeInterval];
        }
        
        return;
    }
    
    // 上课
    if ([msgName isEqualToString:YSSignalingName_ClassBegin])
    {
        NSTimeInterval timeInterval = ts;
        self.tClassStartTime = timeInterval;
        self.isBeginClass = YES;

        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingClassBeginWihInList:)])
        {
            [self.roomManagerDelegate handleSignalingClassBeginWihInList:inlist];
        }
        
        return;
    }

    // 解除全体禁言
    if ([msgName isEqualToString:YSSignalingName_EveryoneBanChat])
    {
        [self sendTipMessage:YSLocalized(@"Prompt.BanChatInView") tipType:YSChatMessageTypeTips];
        
        self.isEveryoneBanChat = YES;
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToDisAbleEveryoneBanChatWithIsDisable:)])
        {
            [self.roomManagerDelegate handleSignalingToDisAbleEveryoneBanChatWithIsDisable:YES];
        }
        return;
    }

    //同意各端开始举手
    if ([msgName isEqualToString:YSSignalingName_RaiseHandStart])
    {
        self.raisehandMsgID = msgID;
        //RaiseHandStart_1931343076_1584580626
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingAllowEveryoneRaiseHand)])
        {
            [self.roomManagerDelegate handleSignalingAllowEveryoneRaiseHand];
        }
        return;
    }
        
    //老师/助教获取到的举手列表订阅结果
    if ([msgName isEqualToString:YSSignalingName_Server_Sort_Result])
    {
//        msgBody
        NSArray * resultArray = [msgBody bm_arrayForKey:@"sortResult"];
        NSString *type = [msgBody bm_stringForKey:@"id"];
        if ([type bm_containString:@"Contest"])
        {
            /// 学生抢答
//            if ([resultArray bm_isNotEmpty])
//            {
                if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingContestCommitWithData:)])
                {
                    [self.roomManagerDelegate handleSignalingContestCommitWithData:resultArray];
                }

//            }
        }
        else
        {
            NSMutableArray * userArray = [NSMutableArray array];
            
            
                for (NSDictionary * dict in resultArray)
                {
                    NSString * userId = dict.allKeys.firstObject;
                    
                    NSMutableDictionary * mutDict = [NSMutableDictionary dictionary];
                    
                    [mutDict setValue:userId forKey:@"peerId"];
                    [mutDict setValue:[dict bm_stringForKey:userId] forKey:@"nickName"];
                    [mutDict setValue:@(YSUser_PublishState_NONE) forKey:@"publishState"];
                    
                    [userArray addObject:mutDict];
                }
            
            if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingRaiseHandUserArray:)])
            {
                [self.roomManagerDelegate handleSignalingRaiseHandUserArray:userArray];
            }
        }
        return;
    }
    
    /// 老师获取学生的答题情况
    if ([msgName isEqualToString:YSSignalingName_AnswerGetResult])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingTeacherAnswerGetResultWithAnswerId:totalUsers:values:)])
        {
            if ([msgBody bm_isNotEmptyDictionary])
            {
                NSString *answerId = [msgBody bm_stringTrimForKey:@"id"];
                NSInteger totalUsers = [msgBody bm_intForKey:@"answerCount"];

                NSDictionary *answers = [msgBody bm_dictionaryForKey:@"values"];
                
                [self.roomManagerDelegate handleSignalingTeacherAnswerGetResultWithAnswerId:answerId totalUsers:totalUsers values:answers];
            }
        }
        return;
    }
    
    // 收到开始抢答
    if ([msgName isEqualToString:YSSignalingName_ShowContest])
    {
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingShowContestFromID:)])
        {
            [self.roomManagerDelegate handleSignalingShowContestFromID:fromID];
        }
        return;
    }

    // 收到抢答排序
    if ([msgName isEqualToString:YSSignalingName_Contest])
    {
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingContestFromID:)])
        {
            [self.roomManagerDelegate handleSignalingContestFromID:fromID];
        }
        return;
    }
    /// 助教强制刷新
    if ([msgName isEqualToString:YSSignalingName_RemoteControl])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToForceRefresh)])
        {
            [self.roomManagerDelegate handleSignalingToForceRefresh];
        }
        return;
    }

    /// 收到取消订阅排序
    if ([msgName isEqualToString:YSSignalingName_ContestSubsort])
    {
        
        if ([msgBody bm_isNotEmptyDictionary])
        {
            NSString *type = [msgBody bm_stringTrimForKey:@"type"];
            if ([type isEqualToString:@"unsubSort"])
            {
                if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingCancelContestSubsort)])
                {
                    [self.roomManagerDelegate handleSignalingCancelContestSubsort];
                }

            }
        }
        
        return;
    }
    
    /// 助教刷新课件
    if ([msgName isEqualToString:YSSignalingName_refeshCourseware])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingTorefeshCourseware)])
        {
            [self.roomManagerDelegate handleSignalingTorefeshCourseware];
        }
        return;
    }
    

#pragma mark 以下需要check data数据
    
//    if (![YSLiveUtil checkDataType:data])
//    {
//        return;
//    }
    
    // 转换数据
    NSDictionary *dataDic = [YSLiveUtil convertWithData:data];
    if (dataDic == nil)
    {
//        if ([msgName isEqualToString:YSSignalingName_ClassBegin])
//        {
//            NSAssert(NO, @"ClassBegin error");
//        }
        return;
    }
    
    NSNumber *dataNum = nil;
    if (![dataDic bm_isNotEmptyDictionary])
    {
        dataNum = (NSNumber *)data;
    }
    
    
    // 处理所有Pub信令
    
    // 房间即将关闭消息
    if ([msgName isEqualToString:YSSignalingName_Notice_PrepareRoomEnd])
    {
        //        NSUInteger countdown = [dataDic bm_uintForKey:@"countdown"];
        YSPrepareRoomEndType prepareRoomEndType = YSPrepareRoomEndType_TeacherLeaveTimeout;
        if ([msgID isEqualToString:YSSignalingId_Notice_PrepareRoomEnd])
        {
            prepareRoomEndType = YSPrepareRoomEndType_RoomTimeOut;
        }
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingPrepareRoomEndWithDataDic:addReason:)])
        {
            [self.roomManagerDelegate handleSignalingPrepareRoomEndWithDataDic:dataDic addReason:prepareRoomEndType];
        }
        
        return;
    }
    
    // 房间踢出所有用户消息
    if ([msgName isEqualToString:YSSignalingName_Notice_EvictAllRoomUse]) {
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingEvictAllRoomUseWithDataDic:)])
        {
            [self.roomManagerDelegate handleSignalingEvictAllRoomUseWithDataDic:dataDic];
        }
        
        return;
    }
    
    // 切换窗口布局
    if ([msgName isEqualToString:YSSignalingName_SetRoomLayout])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingSetRoomLayout:withPeerId:)])
        {
            NSString *roomLayout = [dataDic bm_stringTrimForKey:@"roomLayout"];
            NSString *peerId = [dataDic bm_stringTrimForKey:@"focusVideoId"];
            
            if ([roomLayout isEqualToString:@"videoLayout"])
            {
                [self.roomManagerDelegate handleSignalingSetRoomLayout:YSLiveRoomLayout_VideoLayout withPeerId:peerId];
            }
            else if ([roomLayout isEqualToString:@"aroundLayout"])
            {
                [self.roomManagerDelegate handleSignalingSetRoomLayout:YSLiveRoomLayout_AroundLayout withPeerId:peerId];
            }
            else if ([roomLayout isEqualToString:@"focusLayout"])
            {
                [self.roomManagerDelegate handleSignalingSetRoomLayout:YSLiveRoomLayout_FocusLayout withPeerId:peerId];
            }
        }
        
        return;
    }
    
    /// 拖出视频
    if ([msgName isEqualToString:YSSignalingName_VideoDrag])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDragOutVideoWithPeerId:atPercentLeft:percentTop:isDragOut:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                //data: {
                //     userId: id,// 用户id
                //     percentTop: dragEleTop, y轴百分比
                //     percentLeft: dragEleLeft, x轴百分比
                //     isDrag: true, // 是否拖拽了
                //   }
                NSString *peerId = [dataDic bm_stringTrimForKey:@"userId"];
                // percentLeft  = x / ( width - videowidth )
                CGFloat percentLeft = [dataDic bm_doubleForKey:@"percentLeft"];
                CGFloat percentTop = [dataDic bm_doubleForKey:@"percentTop"];
                BOOL isDrag = YES;//[dataDic bm_boolForKey:@"isDrag"];
                if (peerId)
                {
                    [self.roomManagerDelegate handleSignalingDragOutVideoWithPeerId:peerId atPercentLeft:percentLeft percentTop:percentTop isDragOut:isDrag];
                }
            }
        }
        
        return;
    }
    
    /// 拖出视频拉伸
    if ([msgName isEqualToString:YSSignalingName_VideoChangeSize])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDragOutVideoChangeSizeWithPeerId:scale:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                //name: 'VideoChangeSize', // 视频拉伸信令
                //associatedMsgID: 'VideoDrag', // 绑定视频拖拽信令
                //data: {
                //    userId: id, // 用户id
                //    scale: 1, // type:Number 视频拉伸的比例
                // }
                NSString *peerId = [dataDic bm_stringTrimForKey:@"userId"];
                CGFloat scale = [dataDic bm_doubleForKey:@"scale"];
                if (peerId)
                {
                    [self.roomManagerDelegate handleSignalingDragOutVideoChangeSizeWithPeerId:peerId scale:scale];
                }
            }
        }
        
        return;
    }
    
    /// 双击视频最大化
    if ([msgName isEqualToString:YSSignalingName_DoubleClickVideo])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDragOutVideoChangeFullSizeWithPeerId:isFull:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                //name: 'doubleClickVideo', // 视频拉伸信令
                //data: {
                //    doubleId: id, // 用户id
                // }
                NSString *peerId = [dataDic bm_stringTrimForKey:@"doubleId"];
                if (peerId)
                {
                    [self.roomManagerDelegate handleSignalingDragOutVideoChangeFullSizeWithPeerId:peerId isFull:YES];
                }
            }
        }
        
        return;
    }
    
    /// 白板视频标注
    if ([msgName isEqualToString:YSSignalingName_VideoWhiteboard])
    {
        if (self.roomConfig.isMultiCourseware)
        {
            return;
        }
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingShowVideoWhiteboardWithData:videoRatio:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                //NSString *whiteboardID = [dataDic bm_stringTrimForKey:@"whiteboardID"];
                //if ([whiteboardID isEqualToString:@"videoDrawBoard"])
                {
                    CGFloat videoRatio = [dataDic bm_doubleForKey:@"videoRatio"];
                    [self.roomManagerDelegate handleSignalingShowVideoWhiteboardWithData:dataDic videoRatio:videoRatio];
                }
            }
        }
        
        return;
    }
    
    if ([msgName isEqualToString:YSSignaling_Whiteboard_SharpsChange])
    {
        if (self.roomConfig.isMultiCourseware)
        {
            return;
        }
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDrawVideoWhiteboardWithData:inList:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSString *whiteboardID = [dataDic bm_stringTrimForKey:@"whiteboardID"];
                if ([whiteboardID isEqualToString:@"videoDrawBoard"])
                {
                    [self.roomManagerDelegate handleSignalingDrawVideoWhiteboardWithData:dataDic inList:inlist];
                }
            }
        }
        
        return;
    }
    
    
    // 发起点名
    // stateType    0--1分钟  1--3分钟  2--5分钟  3--10分钟  4--30分钟
    if ([msgName isEqualToString:YSSignalingName_LiveCallRoll])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingLiveCallRollWithStateType:callRollId:apartTimeInterval:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSUInteger stateType = [dataDic bm_uintForKey:@"stateType"];
                NSString *callRollId = [dataDic bm_stringTrimForKey:@"callRollId"];
                NSTimeInterval timeInterval = [dataDic bm_doubleForKey:@"time"];
                
                NSTimeInterval apartTimeInterval;
                if (inlist)
                {
                    apartTimeInterval = self.tCurrentTime - timeInterval;
                }
                else
                {
                    apartTimeInterval = self.tCurrentTime - timeInterval;
                }
                
                if ([callRollId bm_isNotEmpty])
                {
                    [self.roomManagerDelegate handleSignalingLiveCallRollWithStateType:stateType callRollId:callRollId apartTimeInterval:apartTimeInterval];
                }
            }
        }
        
        return;
    }
    
    // 抽奖
    if ([msgName isEqualToString:YSSignalingName_LiveLuckDraw])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingLiveLuckDraw)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                if ([[dataDic bm_stringForKey:@"luckyState"] isEqualToString:@"pub"])
                {
                    [self.roomManagerDelegate handleSignalingLiveLuckDraw];
                }
            }
            
        }
        
        return;
    }
    
    // 中奖结果
    if ([msgName isEqualToString:YSSignalingName_LiveLuckDrawResult])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingLiveLuckDrawResultWithNameList:withEndTime:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSMutableArray <NSString *> *nameList = [[NSMutableArray alloc] init];
                BOOL win = NO;
                NSString * endTime = [dataDic[@"winners"] bm_stringForKey:@"endtime"];
                NSArray *winners = [dataDic[@"winners"] bm_arrayForKey:@"winners"];
                for (NSDictionary *dic in winners)
                {
                    NSString *name = [dic bm_stringTrimForKey:@"buddyname"];
                    if (!win)
                    {
                        NSString *peerId = [dic bm_stringTrimForKey:@"buddyid"];
                        if ([peerId isEqualToString:self.localUser.peerID])
                        {
                            win = YES;
                        }
                    }
                    if ([name bm_isNotEmpty])
                    {
                        [nameList addObject:name];
                    }
                }
                
                if ([nameList bm_isNotEmpty])
                {
                    [self.roomManagerDelegate handleSignalingLiveLuckDrawResultWithNameList:nameList withEndTime:endTime];
                }
                
                if (win)
                {
                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingLiveNoticeInfoWithNotice:timeInterval:)])
                    {
                        [self.roomManagerDelegate handleSignalingLiveNoticeInfoWithNotice:YSLocalized(@"Alert.Reward.title") timeInterval:ts];
                    }
                    //                    [self sendSignalingLiveNoticeInfoWithNotice:@"恭喜，您在抽奖活动里中奖" toID:self.localUser.peerID completion:^(NSError *error) {
                    //                    }];
                }
            }
        }
        
        return;
    }
    
    // 投票
    if ([msgName isEqualToString:YSSignalingName_VoteStart])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingVoteStartWithVoteId:userName:subject:time:desc:isMulti:voteList:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSString *voteId = [dataDic bm_stringTrimForKey:@"voteId"];
                if ([voteId bm_isNotEmpty])
                {
                    NSString *sendVoteUserName = [dataDic bm_stringTrimForKey:@"sendVoteUserName"];//发起人
                    NSString *subject = [dataDic bm_stringTrimForKey:@"subject"];//主题
                    NSString *sendVoteTime = [dataDic bm_stringTrimForKey:@"sendVoteTime"];//发起时间
                    
                    NSString *pattern = [dataDic bm_stringTrimForKey:@"pattern"];//单选还是多选
                    NSString *desc = [dataDic bm_stringTrimForKey:@"desc"];//详情
                    BOOL isMulti = [pattern isEqualToString:@"multi"];
                    
                    NSMutableArray <NSString *> *voteList = [[NSMutableArray alloc] init];
                    NSArray *options = [dataDic bm_arrayForKey:@"options"];
                    for (NSDictionary *dic in options)
                    {
                        NSString *vote = [dic bm_stringTrimForKey:@"content"];
                        if ([vote bm_isNotEmpty])
                        {
                            [voteList addObject:vote];
                        }
                    }
                    
                    if ([voteList bm_isNotEmpty])
                    {
                        [self.roomManagerDelegate handleSignalingVoteStartWithVoteId:voteId userName:sendVoteUserName subject:subject time:sendVoteTime desc:desc isMulti:isMulti voteList:voteList];
                    }
                }
            }
        }
        
        return;
    }
    
    // 投票结果
    if ([msgName isEqualToString:YSSignalingName_PublicVoteResult])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingVoteResultWithVoteId:userName:subject:time:desc:isMulti:voteResult:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSString *voteId = [dataDic bm_stringTrimForKey:@"voteId"];
                if ([voteId bm_isNotEmpty])
                {
                    NSString *sendVoteUserName = [dataDic bm_stringTrimForKey:@"sendVoteUserName"];//发起人
                    NSString *subject = [dataDic bm_stringTrimForKey:@"subject"];//主题
                    NSString *sendVoteTime = [dataDic bm_stringTrimForKey:@"sendVoteTime"];//发起时间
                    
                    NSString *pattern = [dataDic bm_stringTrimForKey:@"pattern"];//单选还是多选
                    NSString *desc = [dataDic bm_stringTrimForKey:@"desc"];//详情
                    
                    BOOL isMulti = [pattern isEqualToString:@"multi"];
                    
                    //NSMutableArray <NSDictionary *> *voteResult = [[NSMutableArray alloc] init];
                    NSArray *options = [dataDic bm_arrayForKey:@"options"];
                    //                    for (NSDictionary *dic in options)
                    //                    {
                    //                        NSString *vote = [dic bm_stringTrimForKey:@"content"];
                    //                        NSUInteger count = [dic bm_uintForKey:@"count"];
                    //                        if ([vote bm_isNotEmpty])
                    //                        {
                    //                            NSDictionary *voteDic = @{ vote : @(count) };
                    //                            [voteResult addObject:voteDic];
                    //                        }
                    //                    }
                    //
                    if ([options bm_isNotEmpty])
                    {
                        [self.roomManagerDelegate handleSignalingVoteResultWithVoteId:voteId userName:sendVoteUserName subject:subject time:sendVoteTime desc:desc isMulti:isMulti voteResult:options];
                    }
                }
            }
        }
        
        return;
    }
    
    // 通知
    if ([msgName isEqualToString:YSSignalingName_LiveNoticeInform])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingLiveNoticeInfoWithNotice:timeInterval:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSString *text = [dataDic bm_stringTrimForKey:@"text"];
                if ([text bm_isNotEmpty])
                {
                    [self.roomManagerDelegate handleSignalingLiveNoticeInfoWithNotice:text timeInterval:ts];
                }
            }
        }
        
        return;
    }
    
    // 公告
    if ([msgName isEqualToString:YSSignalingName_LiveNoticeBoard])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingLiveNoticeBoardWithNotice:timeInterval:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSString *text = [dataDic bm_stringTrimForKey:@"text"];
                if ([text bm_isNotEmpty])
                {
                    [self.roomManagerDelegate handleSignalingLiveNoticeBoardWithNotice:text timeInterval:ts];
                }
            }
        }
        
        return;
    }
    
    // 提问 确认 回答 删除 LiveQuestions
    if ([msgName isEqualToString:YSSignalingName_LiveQuestions])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingQuestionResponedWithQuestion:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                // 删除
                if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDeleteQuestionWithQuestionId:)])
                {
                    //data: "{"delQuestionMsgId":"quiz_1bcf955b-71ce-d2ee-e8b9-6bc6d6e7dfef_1572072815334","type":1}"
                    if ([dataDic bm_containsObjectForKey:@"delQuestionMsgId"])
                    {
                        NSString *questionId = [dataDic bm_stringTrimForKey:@"delQuestionMsgId"];
                        if ([questionId bm_isNotEmpty])
                        {
                            [self.roomManagerDelegate handleSignalingDeleteQuestionWithQuestionId:questionId];
                        }
                        
                        return;
                    }
                }
                
                NSDictionary *senderDic = [dataDic bm_dictionaryForKey:@"sender"];
                
                // id
                NSString *questionId = [dataDic bm_stringTrimForKey:@"id"];
                // 名字
                NSString *nickName = [senderDic bm_stringTrimForKey:@"nickname"];
                // 时间戳
                NSTimeInterval timeInterval = self.tCurrentTime;
                
                YSQuestionModel *questionModel = [[YSQuestionModel alloc] init];
                questionModel.questionId = questionId;
                questionModel.nickName = nickName;
                questionModel.timeInterval = timeInterval;
                questionModel.toUserNickname = [dataDic bm_stringTrimForKey:@"toUserNickname"];
                
                BOOL hasPassed = [dataDic bm_boolForKey:@"hasPassed"];
                // 确认
                if (hasPassed)
                {
                    YSQuestionState state = YSQuestionState_Responed;
                    // 提问详情
                    NSString *questDetails = [dataDic bm_stringTrimForKey:@"msg"];
                    questionModel.state = state;
                    questionModel.questDetails = questDetails;
                    
                }
                else // 回答
                {
                    YSQuestionState state = YSQuestionState_Answer;
                    // 回复详情
                    NSString *answerDetails = [dataDic bm_stringTrimForKey:@"msg"];
                    questionModel.questDetails = [dataDic bm_stringTrimForKey:@"selectUserQuestion"];
                    questionModel.state = state;
                    questionModel.answerDetails = answerDetails;
                }
                
                [self.roomManagerDelegate handleSignalingQuestionResponedWithQuestion:questionModel];
                
                //            data: "{"hasPassed":true,"msg":"上课了？","type":1,"id":"quiz_1bcf955b-71ce-d2ee-e8b9-6bc6d6e7dfef_1572062001849","toUserID":"","toUserNickname":"学生","msgtype":"text","sender":{"id":"89aebd32-3f82-6661-8b16-df5cfa3756f5","role":0,"nickname":"老师"}}"
                
                //            data: "{"msg":"11111","type":1,"id":"quiz_1bcf955b-71ce-d2ee-e8b9-6bc6d6e7dfef_1572072815334","time":"15:17","toUserNickname":"","msgtype":"text","sender":{"id":"89aebd32-3f82-6661-8b16-df5cfa3756f5","role":0,"nickname":"老师"}}"
                
            }
        }
        
        return;
    }
    
    if ([msgName isEqualToString:YSSignalingName_SendFlower])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingSendFlowerWithSenderId:senderName:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSString *senderId = [dataDic bm_stringTrimForKey:@"senderId"];
                NSString *nickname = [dataDic bm_stringTrimForKey:@"nickname"];
                [self.roomManagerDelegate handleSignalingSendFlowerWithSenderId:senderId senderName:nickname];
            }
        }
        
        return;
    }
    
    /// 答题卡
    if ([msgName isEqualToString:YSSignalingName_Answer])
    {
        if ([dataDic bm_isNotEmptyDictionary])
        {
#if DEBUG
            if ([dataDic bm_containsObjectForKey:@"status"])
            {
                NSString *status = [dataDic bm_stringTrimForKey:@"status"];
                BMLog(@"========================Answer status: %@", status);
            }
#endif
            NSString *answerId = [dataDic bm_stringTrimForKey:@"answerId"];
            
            if ([[dataDic bm_stringForKey:@"status"] isEqualToString:@"occupyed"])
            {
                if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingAnswerOccupyedWithAnswerId:startTime:)])
                {
                    if ([self.localUser.peerID isEqualToString:fromID])
                    {
                        [self.roomManagerDelegate handleSignalingAnswerOccupyedWithAnswerId:answerId startTime:ts];
                    }
                }

                return;
            }
            if ([dataDic bm_containsObjectForKey:@"options"])
            {
                
                NSArray *options = [dataDic bm_arrayForKey:@"options"];
                if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingSendAnswerWithAnswerId:options:startTime:fromID:)])
                {
                    [self.roomManagerDelegate handleSignalingSendAnswerWithAnswerId:answerId options:options startTime:ts fromID:fromID];
                }
            }
        }
        
        return;
    }
    
    /// 答题结果
    if ([msgName isEqualToString:YSSignalingName_AnswerPublicResult])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingAnswerPublicResultWithAnswerId:resault:durationStr:answers:totalUsers:fromID:)])
        {
            if ([dataDic bm_isNotEmptyDictionary])
            {
                NSString *answerId = [dataDic bm_stringTrimForKey:@"answerId"];
                NSUInteger totalUsers = [dataDic bm_intForKey:@"totalUsers"];
                NSDictionary *resault = [dataDic bm_dictionaryForKey:@"selecteds"];
                NSString *durationStr = [dataDic bm_stringTrimForKey:@"duration"];
                NSArray *answers = [dataDic bm_arrayForKey:@"detailData"];
                [self.roomManagerDelegate handleSignalingAnswerPublicResultWithAnswerId:answerId resault:resault durationStr:durationStr answers:answers totalUsers:totalUsers fromID:fromID];
            }
        }
        return;
    }
    
    if ([msgName isEqualToString:YSSignalingName_ShowPage] || [msgName isEqualToString:YSSignalingName_ExtendShowPage])
    {
//        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingWhiteBroadShowPageMessage:isDynamic:)])
//        {
//            NSDictionary *resault = [dataDic bm_dictionaryForKey:@"filedata"];
//            
//            if ([resault bm_isNotEmptyDictionary])
//            {
//                BOOL isDynamic = NO;
//                if ([dataDic bm_boolForKey:@"isDynamicPPT"] || [dataDic bm_boolForKey:@"isH5Document"])
//                {
//                    isDynamic = YES;
//                }
//                else if ([dataDic bm_boolForKey:@"isGeneralFile"])
//                {
//                    NSString *filetype = [[resault bm_stringForKey:@"filetype"] lowercaseString];
//                    NSString *path = [[resault bm_stringForKey:@"swfpath"] lowercaseString];
//                    if ([filetype isEqualToString:@"gif"] || [filetype isEqualToString:@"svg"])
//                    {
//                        isDynamic = YES;
//                    }
//                    else if ([path hasSuffix:@".gif"] || [path hasSuffix:@".svg"])
//                    {
//                        isDynamic = YES;
//                    }
//                }
//                
//                [self.roomManagerDelegate handleSignalingWhiteBroadShowPageMessage:resault isDynamic:isDynamic];
//                
//            }
//        }
        
        return;
    }
    
    //双师：老师拖拽视频布局相关信令
    if ([msgName isEqualToString:YSSignalingName_DoubleTeacher])
    {
        
        NSDictionary * dict = [NSDictionary bm_dictionaryWithJsonString:(NSString*)data];
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToDoubleTeacherWithData:)])
        {
            [self.roomManagerDelegate handleSignalingToDoubleTeacherWithData:dict];
        }
        return;
    }
        
    // 收到学生抢答
//    if ([msgName isEqualToString:YSSignalingName_ContestCommit])
//    {
//        NSDictionary *actions = [msgBody bm_dictionaryForKey:@"actions"];
//
//        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingContestCommitWithData:)])
//        {
//            [self.roomManagerDelegate handleSignalingContestCommitWithData:actions];
//        }
//        return;
//    }
    /// 收到抢答结果
    if ([msgName isEqualToString:YSSignalingName_ContestResult])
    {
        NSDictionary * dict = [NSDictionary bm_dictionaryWithJsonString:(NSString*)data];
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingContestResultWithName:)])
        {
            NSString *name = [dict bm_stringForKey:@"nickName"];

            [self.roomManagerDelegate handleSignalingContestResultWithName:name];
        }
        return;
    }
    /// 收到轮播
    if ([msgName isEqualToString:YSSignalingName_VideoPolling])
    {
        NSString *associatedID = [msgBody bm_stringForKey:@"associatedUserID"];
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToStartVideoPollingFromID:)])
        {
            [self.roomManagerDelegate handleSignalingToStartVideoPollingFromID:associatedID];
        }
        return;
    }

    
    
    // 计时器
    if ([msgName isEqualToString:YSSignalingName_Timer])
    {
        
        if ([dataDic bm_isNotEmptyDictionary])
        {
            NSInteger defaultTime = [dataDic bm_intForKey:@"defaultTime"];
            NSInteger time = [dataDic bm_intForKey:@"time"];
            BOOL isShow = [dataDic bm_boolForKey:@"isShow"];
            BOOL isStatus = [dataDic bm_boolForKey:@"isStatus"];
            BOOL isRestart = [dataDic bm_boolForKey:@"isRestart"];
            if (isShow)
            {
                if (isStatus && isRestart)
                {
                    if (self.tCurrentTime != ts)
                    {
                        time = time - (self.tCurrentTime - ts);
                        time = time < 0 ? 0 : time;
                    }

                    /// 开始计时    重置以后直接开始计时
                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingTimerWithTime:pause:defaultTime:)])
                    {
                        [self.roomManagerDelegate handleSignalingTimerWithTime:time pause:isStatus defaultTime:defaultTime];
                    }
                }
                else if (!isStatus && !isRestart)
                {
                    /// 暂停
                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingPauseTimerWithTime:defaultTime:)])
                    {
                        [self.roomManagerDelegate handleSignalingPauseTimerWithTime:time defaultTime:defaultTime];
                    }

                }
                else if (isStatus && !isRestart)
                {
                    if (self.tCurrentTime != ts)
                    {
                        time = time - (self.tCurrentTime - ts);
                        time = time < 0 ? 0 : time;
                    }

                    /// 继续
                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingContinueTimerWithTime:defaultTime:)])
                    {
                        [self.roomManagerDelegate handleSignalingContinueTimerWithTime:time defaultTime:defaultTime];
                    }
                }
                else if (!isStatus && isRestart)
                {
                    if (self.tCurrentTime != ts)
                    {
                        time = time - (self.tCurrentTime - ts);
                        time = time < 0 ? 0 : time;
                    }

                    /// 开始计时    重置以后先暂停开始计时
                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingTimerWithTime:pause:defaultTime:)])
                    {
                        [self.roomManagerDelegate handleSignalingTimerWithTime:defaultTime pause:isStatus defaultTime:defaultTime];
                    }
                }

            }
            else
            {
                if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingTeacherTimerShow)])
                {
                    [self.roomManagerDelegate handleSignalingTeacherTimerShow];
                }
            }
            
            
//            if ([dataDic bm_containsObjectForKey:@"isStatus"])
//            {
//
//                if (isStatus)
//                {
//                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingStudentPauseTimerWithTime:)])
//                    {
//                        [self.roomManagerDelegate handleSignalingStudentPauseTimerWithTime:time];
//                    }
//
//                }
//                else
//                {
//                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingStudentContinueTimerWithTime:)])
//                    {
//                        [self.roomManagerDelegate handleSignalingStudentContinueTimerWithTime:time];
//                    }
//                }
//            }
            
//            if ([dataDic bm_containsObjectForKey:@"isRestart"])
//            {
//
//                if (isRestart)
//                {
//                    //重置
//                    if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingStudentRestartTimerWithTime:)])
//                    {
//                        [self.roomManagerDelegate handleSignalingStudentRestartTimerWithTime:defaultTime];
//                    }
//                }
//                else
//                {
//
//                }
//            }
        }
        
        return;
    }
    
    //老师处理的接收信令
    BOOL isTrue = [self handleRoomTeacherPubMsgWithMsgID:msgID msgName:msgName data:data fromID:fromID inList:inlist ts:ts];
    if (isTrue) {
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomRemotePubMsgWithMsgID:msgName:data:fromID:inList:ts:body:)])
    {
        [self.roomManagerDelegate onRoomRemotePubMsgWithMsgID:msgID msgName:msgName data:dataDic fromID:fromID inList:inlist ts:ts body:msgBody];
    }
}

// 收到自定义信令 删去消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (void)handleRoomDelMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                             data:(NSObject *)data
                           fromID:(NSString *)fromID
                           inList:(BOOL)inlist
                               ts:(long)ts
{
    if (![msgID bm_isNotEmpty] || ![msgName bm_isNotEmpty])
    {
        return;
    }
    
    if (![YSLiveUtil checkDataType:data])
    {
        return;
    }
    
    NSDictionary *dataDic = [YSLiveUtil convertWithData:data];
    NSNumber *dataNum = nil;
    if (![dataDic bm_isNotEmptyDictionary])
    {
        dataNum = (NSNumber *)data;
    }
    
    // 取消房间即将关闭消息
    if ([msgName isEqualToString:YSSignalingName_Notice_PrepareRoomEnd])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(stopSignalingLivePrepareRoomEnd_TeacherLeaveTimeout)])
        {
            [self.roomManagerDelegate stopSignalingLivePrepareRoomEnd_TeacherLeaveTimeout];
        }
        
        return;
    }
    
    // 下课
    if ([msgName isEqualToString:YSSignalingName_ClassBegin])
    {
        self.isBeginClass = NO;
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingClassEndWithText:)])
        {
            [self.roomManagerDelegate handleSignalingClassEndWithText:YSLocalized(@"Prompt.ClassEnd")];
        }
        
        return;
    }
    
    // 切换窗口布局恢复
    if ([msgName isEqualToString:YSSignalingName_SetRoomLayout])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDefaultRoomLayout)])
        {
            [self.roomManagerDelegate handleSignalingDefaultRoomLayout];
        }
        return;
    }
    
    /// 拖出视频恢复
    if ([msgName isEqualToString:YSSignalingName_VideoDrag])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDragOutVideoWithPeerId:atPercentLeft:percentTop:isDragOut:)])
        {
            //if ([dataDic bm_isNotEmptyDictionary])
            {
                //data: {
                //     userId: id,// 用户id
                //     percentTop: dragEleTop, y轴百分比
                //     percentLeft: dragEleLeft, x轴百分比
                //     isDrag: true, // 是否拖拽了
                //   }
                //NSString *peerId = [dataDic bm_stringTrimForKey:@"userId"];
                // percentLeft  = x / ( width - videowidth )
                //CGFloat percentLeft = [dataDic bm_doubleForKey:@"percentLeft"];
                //CGFloat percentTop = [dataDic bm_doubleForKey:@"percentTop"];
                NSString *peerId = [msgID stringByReplacingOccurrencesOfString:@"VideoDrag_" withString:@""];
                
                BOOL isDrag = NO;//[dataDic bm_boolForKey:@"isDrag"];
                if (peerId)
                {
                    [self.roomManagerDelegate handleSignalingDragOutVideoWithPeerId:peerId atPercentLeft:0 percentTop:0 isDragOut:isDrag];
                }
            }
        }
        
        return;
    }
    
    /// 双击视频最大化
    if ([msgName isEqualToString:YSSignalingName_DoubleClickVideo])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDragOutVideoChangeFullSizeWithPeerId:isFull:)])
        {
            //if ([dataDic bm_isNotEmptyDictionary])
            {
                //name: 'doubleClickVideo', // 视频拉伸信令
                //data: {
                //    doubleId: id, // 用户id
                // }
                //NSString *peerId = [dataDic bm_stringTrimForKey:@"doubleId"];
                //if (peerId)
                {
                    [self.roomManagerDelegate handleSignalingDragOutVideoChangeFullSizeWithPeerId:nil isFull:NO];
                }
            }
        }
        
        return;
    }
    
    /// 白板视频标注
    if ([msgName isEqualToString:YSSignalingName_VideoWhiteboard])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingShowVideoWhiteboardWithData:videoRatio:)])
        {
            if (self.roomConfig.isMultiCourseware)
            {
                return;
            }
            //if ([dataDic bm_isNotEmptyDictionary])
            {
                //NSString *whiteboardID = [dataDic bm_stringTrimForKey:@"whiteboardID"];
                //if ([whiteboardID isEqualToString:YSSignaling_VideoWhiteboard_Id])
                {
                    [self.roomManagerDelegate handleSignalingHideVideoWhiteboard];
                }
            }
        }
        
        return;
    }
    
    // 结束点名
    // stateType    0--1分钟  1--3分钟  2--5分钟  3--10分钟  4--30分钟
    if ([msgName isEqualToString:YSSignalingName_LiveCallRoll])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(closeSignalingLiveCallRoll)])
        {
            [self.roomManagerDelegate closeSignalingLiveCallRoll];
        }
        
        return;
    }
    
    // 抽奖结束
    if ([msgName isEqualToString:YSSignalingName_LiveLuckDraw])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(closeSignalingLiveLuckDraw)])
        {
            [self.roomManagerDelegate closeSignalingLiveLuckDraw];
        }
        
        return;
    }
    
    // 投票结束
    if ([msgName isEqualToString:YSSignalingName_VoteStart])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingVoteEndWithVoteId:)])
        {
            NSString *voteId = msgID;
            
            if ([voteId bm_isNotEmpty])
            {
                [self.roomManagerDelegate handleSignalingVoteEndWithVoteId:voteId];
            }
        }
        
        return;
    }
    
    // 答题结束
    if ([msgName isEqualToString:YSSignalingName_Answer])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingAnswerEndWithAnswerId:fromID:)])
        {
            NSString *answerId = msgID;
            
            if ([answerId bm_isNotEmpty])
            {
                [self.roomManagerDelegate handleSignalingAnswerEndWithAnswerId:answerId fromID:fromID];
            }
        }
        
        return;
    }
    

//    // 答题结果关闭
//    if ([msgName isEqualToString:YSSignalingName_AnswerPublicResult])
//    {
//        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDelAnswerResultWithAnswerId:)])
//        {
//            NSString *answerId = msgID;
//
//            if ([answerId bm_isNotEmpty])
//            {
//                [self.roomManagerDelegate handleSignalingDelAnswerResultWithAnswerId:answerId];
//            }
//        }
//
//        return;
//    }

    // 答题结果关闭
    if ([msgName isEqualToString:YSSignalingName_AnswerPublicResult])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDelAnswerResultWithAnswerId:)])
        {
            NSString *answerId = msgID;

            if ([answerId bm_isNotEmpty])
            {
                [self.roomManagerDelegate handleSignalingDelAnswerResultWithAnswerId:answerId];
            }
        }

        return;
    }
    
    /// 结束轮播
    if ([msgName isEqualToString:YSSignalingName_VideoPolling])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToStopVideoPolling)])
        {
            [self.roomManagerDelegate handleSignalingToStopVideoPolling];
        }
        return;
    }

    
    // 全体禁言
    if ([msgName isEqualToString:YSSignalingName_EveryoneBanChat])
    {
        [self sendTipMessage:YSLocalized(@"Prompt.CancelBanChatInView") tipType:YSChatMessageTypeTips];
        
        self.isEveryoneBanChat = NO;
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToDisAbleEveryoneBanChatWithIsDisable:)]) {
            [self.roomManagerDelegate handleSignalingToDisAbleEveryoneBanChatWithIsDisable:NO];
        }
        return;
    }
    
    // 取消全体静音
    if ([msgName isEqualToString:YSSignalingName_LiveAllNoAudio])
    {
        BMLog(@"取消全体静音");
//        BOOL isNoAudio = [dataDic bm_boolForKey:@"liveAllNoAudio"];
        self.isEveryoneNoAudio = NO;
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToliveAllNoAudio:)])
        {
            [self.roomManagerDelegate handleSignalingToliveAllNoAudio:NO];
        }
        
        return;
    }
    
    // 结束抢答排序
    if ([msgName isEqualToString:YSSignalingName_Contest])
    {
        BMLog(@"结束抢答排序");
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDelContest)])
        {
            [self.roomManagerDelegate handleSignalingDelContest];
        }
        
        return;
    }
    
    // 关闭抢答器
    if ([msgName isEqualToString:YSSignalingName_ShowContest])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToCloseResponder)])
        {
            [self.roomManagerDelegate handleSignalingToCloseResponder];
        }
        return;
    }
    
    //是否开启上麦功能
//    if ([msgName isEqualToString:YSSignalingName_UpPlatForm])
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:msgID forKey:@"UpPlatFormId"];
//
//        self.allowEveryoneUpPlatform = NO;
//
//        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingAllowEveryoneUpPlatformWithIsAllow:)]) {
//            [self.roomManagerDelegate handleSignalingAllowEveryoneUpPlatformWithIsAllow:NO];
//        }
//        return;
//    }
    //关闭计时器
    if ([msgName isEqualToString:YSSignalingName_Timer])
    {
       
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingDeleteTimerWithTime)]) {
            [self.roomManagerDelegate handleSignalingDeleteTimerWithTime];
        }
        return;
    }

    
    //双师：老师拖拽视频布局相关信令
    if ([msgName isEqualToString:YSSignalingName_DoubleTeacher]) {
        
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingToDoubleTeacherWithData:)])
        {
            [self.roomManagerDelegate handleSignalingToDoubleTeacherWithData:@{@"one2one":@""}];
        }
        return;
    }
    
    //老师处理的接收信令
    BOOL isTrue = [self handleRoomTeacherDelMsgWithMsgID:msgID msgName:msgName data:data fromID:fromID inList:inlist ts:ts];
    
    if (isTrue) {
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomRemoteDelMsgWithMsgID:msgName:data:fromID:inList:ts:)])
    {
        [self.roomManagerDelegate onRoomRemoteDelMsgWithMsgID:msgID msgName:msgName data:dataDic fromID:fromID inList:inlist ts:ts];
    }
}

// 收到白板Pub消息
- (void)handleWhiteBroadPubMsgWithMsgID:(NSString *)msgID
                                msgName:(NSString *)msgName
                                   data:(NSObject *)data
                                 fromID:(NSString *)fromID
                                 inList:(BOOL)inlist
                                     ts:(long)ts
{
    if (![msgID bm_isNotEmpty] || ![msgName bm_isNotEmpty])
    {
        return;
    }
    
    if (![YSLiveUtil checkDataType:data])
    {
        return;
    }
    
    // 转换数据
    NSDictionary *dataDic = [YSLiveUtil convertWithData:data];
    NSNumber *dataNum = nil;
    if (![dataDic bm_isNotEmptyDictionary])
    {
        dataNum = (NSNumber *)data;
    }
    
    if ([msgName isEqualToString:sDocumentChange])
    {
        if ([self.roomManagerDelegate respondsToSelector:@selector(handleSignalingWhiteBroadDocumentChange)])
        {
            [self.roomManagerDelegate handleSignalingWhiteBroadDocumentChange];
        }
    }
    
    BMLog(@"msgName: %@", msgName);
    BMLog(@"%@", dataDic);
}

@end
