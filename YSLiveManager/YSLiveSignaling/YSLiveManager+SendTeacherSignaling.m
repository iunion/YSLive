//
//  YSLiveManager+TeacherSendSignaling.m
//  YSAll
//
//  Created by 马迪 on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

//#import "YSLiveManager+TeacherSendSignaling.h"

#import <YSRoomSDK/YSRoomInterface.h>
#import "YSLiveManager.h"

@implementation YSLiveManager (SendTeacherSignaling)

/// 老师发起上课
- (BOOL)sendSignalingTeacherToClassBeginWithCompletion:(completion_block)completion
{
    NSDictionary *sendDic = @{ @"recordchat" : @1 };
    BOOL result = [self sendPubMsg:YSSignalingName_TeacherClassBegain toID:YSRoomPubMsgTellAll data:sendDic save:YES completion:completion];
    
    return result;
}

/// 老师发起下课
- (BOOL)sendSignalingTeacherToDismissClassWithCompletion:(completion_block)completion
{
    BOOL result = [self deleteMsg:YSSignalingName_TeacherClassBegain toID:YSRoomPubMsgTellAll data:@"" completion:completion];
    return result;
}

/// 修改指定用户的属性
- (BOOL)sendSignalingToChangePropertyWithRoomUser:(YSRoomUser *)user withKey:(NSString *)key WithValue:(NSObject *)value
{
    int result = [[YSRoomInterface instance] changeUserProperty:user.peerID tellWhom:YSRoomPubMsgTellAll key:key value:value completion:nil];
    return (result==0);
}

/// 改变布局
- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(YSLiveRoomLayout)layoutType
{
    return [self sendSignalingToChangeLayoutWithLayoutType:layoutType appUserType:YSAppUseTheTypeSmallClass withFouceUserId:nil];
}

/// 改变布局
- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(YSLiveRoomLayout)layoutType appUserType:(YSAppUseTheType)appUserType withFouceUserId:(NSString *)peerId
{
    BOOL result;
//    data:｛roomLayout : 'defaultLayout'-默认布局/'videoLayout'-视频布局｝
    if (layoutType == YSLiveRoomLayout_VideoLayout)
    {
        if (appUserType == YSAppUseTheTypeMeeting)
        {
            result = [self deleteMsg:YSSignalingName_SetRoomLayout toID:YSRoomPubMsgTellAll data:@"" completion:nil];
        }
        else
        {
            NSDictionary *data = @{ @"roomLayout" : @"videoLayout" };
            result = [self sendPubMsg:YSSignalingName_SetRoomLayout toID:YSRoomPubMsgTellAll data:data save:YES completion:nil];
        }
    }
    else if (layoutType == YSLiveRoomLayout_AroundLayout)
//    else
    {
        if (appUserType == YSAppUseTheTypeMeeting)
        {
            NSDictionary *data = @{ @"roomLayout" : @"aroundLayout" };
            result = [self sendPubMsg:YSSignalingName_SetRoomLayout toID:YSRoomPubMsgTellAll data:data save:YES completion:nil];
        }
        else
        {
            result = [self deleteMsg:YSSignalingName_SetRoomLayout toID:YSRoomPubMsgTellAll data:@"" completion:nil];
        }
    }
    else
    {
        if (appUserType == YSAppUseTheTypeSmallClass)
        {
            if (![peerId bm_isNotEmpty])
            {
                return NO;
            }
            NSDictionary *data = @{ @"roomLayout" : @"focusLayout",@"focusVideoId":peerId };
            BOOL result = [self sendPubMsg:YSSignalingName_SetRoomLayout toID:YSRoomPubMsgTellAll data:data save:YES completion:nil];
            return result;
        }
        else
        {
            return YES;
        }
    }
    
       
    return result;
}

//- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(YSLiveRoomLayout)layoutType withFouceUserId:(NSString *)peerId
//{
//    NSDictionary *data = @{ @"roomLayout" : @"focusLayout",@"focusVideoId":peerId };
//    BOOL result = [self sendPubMsg:YSSignalingName_SetRoomLayout toID:YSRoomPubMsgTellAll data:data save:YES completion:nil];
//    return result;
//}


/// 发送双击视频放大
- (BOOL)sendSignalingToDoubleClickVideoViewWithPeerId:(NSString *)peerId
{
    if (![peerId bm_isNotEmpty])
    {
        return NO;
    }
    
    NSDictionary *sendDic = @{ @"doubleId" : peerId };
    
    BOOL result = [self.roomManager pubMsg:YSSignalingName_DoubleClickVideo msgID:YSSignalingName_DoubleClickVideo toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;
}

/// 取消双击视频放大
- (BOOL)deleteSignalingToDoubleClickVideoView
{
    BOOL result = [self deleteMsg:YSSignalingName_DoubleClickVideo toID:YSRoomPubMsgTellAll data:@"" completion:nil];;

    return result;
}

/// 拖出视频/复位视频
- (BOOL)sendSignalingToDragOutVideoViewWithData:(NSDictionary*)data
{
    int result = 0;
    
    NSString * userId = [data bm_stringForKey:@"userId"];
    
    NSString *msgID = [NSString stringWithFormat:@"VideoDrag_%@", userId];
    if ([data bm_boolForKey:@"isDrag"])
    {
        result = [self.roomManager pubMsg:YSSignalingName_VideoDrag msgID:msgID toID:YSRoomPubMsgTellAllExceptSender data:data save:YES associatedMsgID:nil associatedUserID:userId expires:0 completion:nil];
    }
    else
    {
        result = [self.roomManager delMsg:YSSignalingName_VideoDrag msgID:msgID toID:YSRoomPubMsgTellAll data:@{} completion:nil];
    }
    return (result == 0);
}

/// 拖出视频后捏合动作
- (BOOL)sendSignalingTopinchVideoViewWithPeerId:(NSString *)peerId scale:(CGFloat)scale
{
    if (![peerId bm_isNotEmpty])
    {
        return NO;
    }
    
    BOOL result = [self sendPubMsg:YSSignalingName_VideoChangeSize toID:YSRoomPubMsgTellAll data: @{@"userId":peerId, @"scale":@(scale)} save:YES completion:nil];
    return  result;
}

/// 全体静音
- (BOOL)sendSignalingTeacherToLiveAllNoAudioCompletion:(completion_block)completion
{
//    NSDictionary *sendDic = @{@"liveAllNoAudio":@(true)};
    BOOL result = [self sendPubMsg:YSSignalingName_LiveAllNoAudio toID:YSRoomPubMsgTellAll data:@"" save:YES completion:completion];

    return result;
}

/// 取消全体静音
- (BOOL)deleteSignalingTeacherToLiveAllNoAudioCompletion:(completion_block)completion
{
//    NSDictionary *sendDic = @{@"liveAllNoAudio":@(false)};
//    BOOL result = [self sendPubMsg:YSSignalingName_LiveAllNoAudio toID:YSRoomPubMsgTellAll data:sendDic save:NO completion:completion];
    
    BOOL result  = [self deleteMsg:YSSignalingName_LiveAllNoAudio toID:YSRoomPubMsgTellAll data:@"" completion:completion];
    
    return result;
}

/// 全体禁言
- (BOOL)sendSignalingTeacherToLiveAllNoChatSpeakingCompletion:(nullable completion_block)completion
{
    //兼容
    NSDictionary *sendDic = @{ @"isAllBanSpeak" : @(true) };
    BOOL result = [self sendPubMsg:YSSignalingName_EveryoneBanChat toID:YSRoomPubMsgTellAll data:sendDic save:YES completion:completion];

    return result;
}

/// 解除禁言
- (BOOL)deleteSignalingTeacherToLiveAllNoChatSpeakingCompletion:(nullable completion_block)completion
{
    BOOL result = [self deleteMsg:YSSignalingName_EveryoneBanChat toID:YSRoomPubMsgTellAll data:@"" completion:completion];

    return result;
}

/// 删除课件
- (BOOL)sendSignalingTeacherToDeleteDocumentWithFile:(YSFileModel *)fileModel completion:(completion_block)completion
{
    if (![fileModel bm_isNotEmpty])
    {
        return NO;
    }
 
    NSDictionary *jsDic = [fileModel bm_toDictionary];

    NSDictionary *sendDic = @{@"isDel":@(true),
                              @"isGeneralFile":@(fileModel.isGeneralFile.boolValue),
                              @"isMedia": @(fileModel.isMedia.boolValue),
                              @"isDynamicPPT": @(fileModel.isDynamicPPT.boolValue),
                              @"isH5Document": @(fileModel.isH5Document.boolValue),
                              @"fileid" : fileModel.fileid,
                              @"filedata":[self nullDicToDic:jsDic]
                            };

    BOOL result = [self sendPubMsg:sDocumentChange toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES completion:completion];
  
    return result;
}

/// 切换课件
- (BOOL)sendSignalingTeacherToSwitchDocumentWithFile:(YSFileModel *)fileModel isFresh:(BOOL)isFresh completion:(nullable completion_block)completion
{
    if (![fileModel bm_isNotEmpty])
    {
        return NO;
    }
    
    NSString *toWho = YSRoomPubMsgTellAll;
    if (isFresh)
    {
        toWho = self.localUser.peerID;
    }
    
//    if ([YSLiveUtil checkIsMedia:fileModel.filetype])
//    {
//        BOOL tIsVideo = [YSLiveUtil checkIsVideo:fileModel.filetype];
//        
//        NSString *filename = fileModel.filename ? fileModel.filename : @"";
//        NSDictionary *sendDic = @{@"filename":filename,
//                                  @"fileid":fileModel.fileid,
//                                  @"pauseWhenOver":@(true),
//                                  @"type": @"media",
//                                  @"source": @"mediaFileList"
//                                
//                                };
//        
//        NSString *url = [self absolutefileUrl:fileModel.swfpath];
//        BOOL result = [self.roomManager startShareMediaFile:url isVideo:tIsVideo toID:toWho attributes:sendDic block:completion] == 0;
//        return result;
//    }
//    else
    {
        [self.whiteBoardManager changeCourseWithFileId:fileModel.fileid];
        return YES;
    }

    return NO;
}

- (NSString*)absolutefileUrl:(NSString*)fileUrl
{
    NSString *tUrl = [NSString stringWithFormat:@"%@://%@:%@%@", YSLive_Http, [YSLiveManager shareInstance].liveHost,@(YSLive_Port),fileUrl];
    NSString *tdeletePathExtension = tUrl.stringByDeletingPathExtension;
    NSString *tNewURLString = [NSString stringWithFormat:@"%@-1.%@",tdeletePathExtension,tUrl.pathExtension];
    NSArray *tArray          = [tNewURLString componentsSeparatedByString:@"/"];
    if ([tArray count]<4) {
        return @"";
    }
    NSString *tNewURLString2 = [NSString stringWithFormat:@"%@//%@/%@/%@",[tArray objectAtIndex:0],[tArray objectAtIndex:1],[tArray objectAtIndex:2],[tArray objectAtIndex:3]];
    return tNewURLString2;
}

- (NSMutableDictionary *)nullDicToDic:(NSDictionary *)dic
{
    NSMutableDictionary *resultDic = [@{} mutableCopy];
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return resultDic;
    }
    for (NSString *key in [dic allKeys]) {
        if ([(id)[dic objectForKey:key] isKindOfClass:[NSNull class]]) {
            [resultDic setValue:@"" forKey:key];
        }else{
            [resultDic setValue:[dic objectForKey:key] forKey:key];
        }
    }
    return resultDic;
}

/// 答题器占用操作
- (BOOL)sendSignalingTeacherToAnswerOccupyedCompletion:(completion_block)completion
{
    NSString *uuid = [YSLiveUtil createUUID];
    NSString *answerID = [NSString stringWithFormat:@"answer_%@%@", [YSLiveManager shareInstance].room_Id,uuid];
    NSDictionary *sendDic = @{@"status" : @"occupyed",
                              @"answerId" : answerID
                            };
    BOOL result = [self.roomManager pubMsg:YSSignalingName_Answer msgID:answerID toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:@{@"type" : @"useCount"} associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;
}

/// 发布答题器
- (BOOL)sendSignalingTeacherToAnswerWithOptions:(NSArray *)answers answerID:(NSString *)answerID completion:(nullable completion_block)completion
{
    if (![answers bm_isNotEmpty])
    {
        return NO;
    }
    
    if (![answerID bm_isNotEmpty])
    {
        return NO;
    }
    
    NSDictionary *sendDic = @{@"options" : answers,
                              @"answerId" : answerID
                            };
    BOOL result = [self.roomManager pubMsg:YSSignalingName_Answer msgID:answerID toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:@{@"type" : @"useCount"} associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;
}

/// 获取答题器进行时的结果
- (BOOL)sendSignalingTeacherToAnswerGetResultWithAnswerID:(NSString *)answerID completion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager pubMsg:YSSignalingName_AnswerGetResult msgID:answerID toID:self.localUser.peerID data:@"" save:NO extensionData:@{@"type":@"getCount"} associatedMsgID:answerID associatedUserID:nil expires:0 completion:nil] == 0;

    return result;
}

/// 结束答题
- (BOOL)sendSignalingTeacherToDeleteAnswerWithAnswerID:(NSString *)answerID completion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager delMsg:YSSignalingName_Answer msgID:answerID toID:YSRoomPubMsgTellAll data:@"" completion:completion] == 0;

    return result;
}

/// 发布答题结果
/// @param answerID 答题ID
/// @param selecteds 统计数据
/// @param duration 答题时间
/// @param detailData 详情数据
/// @param completion 回调
- (BOOL)sendSignalingTeacherToAnswerPublicResultWithAnswerID:(NSString *)answerID selecteds:(NSDictionary *)selecteds duration:(NSString *)duration detailData:(NSArray *)detailData totalUsers:(NSInteger)totalUsers completion:(nullable completion_block)completion
{
    if (![answerID bm_isNotEmpty])
    {
        return NO;
    }
    
    if (![selecteds bm_isNotEmpty])
    {
        return NO;
    }
    
    if (![duration bm_isNotEmpty])
    {
        return NO;
    }
    
    if (!detailData)
    {
        return NO;
    }

    NSDictionary *sendDic = @{@"answerId":answerID,
                              @"selecteds":selecteds,
                              @"duration":duration,
                              @"detailData":detailData,
                              @"totalUsers":@(totalUsers),
                              @"isPublicResult":@(true)
                            };
    BOOL result = [self.roomManager pubMsg:YSSignalingName_AnswerPublicResult msgID:YSSignalingName_AnswerPublicResult toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;
}

/// 结束答题结果
- (BOOL)sendSignalingTeacherToDeleteAnswerPublicResultCompletion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager delMsg:YSSignalingName_AnswerPublicResult msgID:YSSignalingName_AnswerPublicResult toID:YSRoomPubMsgTellAll data:@"" completion:completion] == 0;

    return result;
}

/// 抢答器  开始
- (BOOL)sendSignalingTeacherToStartResponderCompletion:(nullable completion_block)completion
{
//    NSDictionary *sendDic = @{ @"state" : @"starting" };
    BOOL result = [self.roomManager pubMsg:YSSignalingName_ShowContest msgID:@"ShowContest" toID:YSRoomPubMsgTellAll data:@{} save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;

}

/// 助教、老师发起抢答排序
- (BOOL)sendSignalingTeacherToContestResponderWithMaxSort:(NSInteger)maxSort completion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{@"maxSort" : @(maxSort),
                              @"subInterval" : @(1000)
                            };
    NSDictionary * extensionData = @{@"type":@"useSort"};
    BOOL result = [self.roomManager pubMsg:YSSignalingName_Contest msgID:@"Contest" toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:extensionData associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;
}

/// 发布抢答器结果
- (BOOL)sendSignalingTeacherToContestResultWithName:(NSString *)name completion:(nullable completion_block)completion
{
    NSString *nickName = @"";
    if ([name bm_isNotEmpty])
    {
        nickName = name;
    }

    NSDictionary *sendDic = @{ @"nickName" : nickName };
    BOOL result = [self.roomManager pubMsg:YSSignalingName_ContestResult msgID:@"ContestResult" toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:NO extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;

}

/// 订阅抢答排序
- (BOOL)sendSignalingTeacherToContestSubsortWithMin:(NSInteger)min max:(NSInteger)max completion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{@"min" : @(min),
                              @"max" : @(max)
                            };
    NSDictionary * extensionData = @{@"type":@"subSort"};
    BOOL result = [self.roomManager pubMsg:YSSignalingName_ContestSubsort msgID:@"ContestSubsort" toID:YSRoomPubMsgTellNone data:[sendDic bm_toJSON] save:YES extensionData:extensionData associatedMsgID:@"Contest" associatedUserID:nil expires:0 completion:nil] == 0;

    return result;

}

/// 取消订阅抢答排序
- (BOOL)sendSignalingTeacherToCancelContestSubsortCompletion:(nullable completion_block)completion
{
    
    NSDictionary * extensionData = @{@"type":@"unsubSort"};
    BOOL result = [self.roomManager pubMsg:YSSignalingName_ContestSubsort msgID:@"ContestSubsort" toID:YSRoomPubMsgTellNone data:@{} save:NO extensionData:extensionData associatedMsgID:@"Contest" associatedUserID:nil expires:0 completion:nil] == 0;

    return result;

}

/// 结束抢答排序
- (BOOL)sendSignalingTeacherToDeleteContestCompletion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager delMsg:YSSignalingName_Contest msgID:@"Contest" toID:YSRoomPubMsgTellAll data:@"" completion:completion] == 0;

    return result;
}


/// 关闭抢答器
- (BOOL)sendSignalingTeacherToCloseResponderCompletion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager delMsg:YSSignalingName_ShowContest msgID:@"ShowContest" toID:YSRoomPubMsgTellAll data:@"" completion:completion] == 0;

    return result;
    
}

/// fas计时器
/// @param time 计时器时间
/// @param isStatus 当前状态 暂停 继续
/// @param isRestart 重置是否
/// @param isShow 是否显示弹窗  老师第一次点击计时器传false  老师显示，老师点击开始计时，传true ，学生显示

/// @param defaultTime 开始计时时间
/// @param completion 回调
- (BOOL)sendSignalingTeacherToStartTimerWithTime:(NSInteger)time isStatus:(BOOL)isStatus isRestart:(BOOL)isRestart isShow:(BOOL)isShow defaultTime:(NSInteger)defaultTime completion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{@"time": @(time),
                              @"isStatus": isStatus ? @(true): @(false),
                              @"isRestart": isRestart ? @(true): @(false),
                              @"isShow": isShow ? @(true): @(false),
                              @"defaultTime": @(defaultTime)
                             };
     BOOL result = [self.roomManager pubMsg:YSSignalingName_Timer msgID:YSSignalingName_Timer toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

     return result;
}

- (BOOL)sendSignalingTeacherToShowTimerCompletion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{
                              @"isShow": @(false)
                             };
     BOOL result = [self.roomManager pubMsg:YSSignalingName_Timer msgID:YSSignalingName_Timer toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

     return result;

}

/// 学生计时器显示
- (BOOL)sendSignalingStudentToShowTimerWithTime:(NSInteger)time completion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{@"isShow": @(true),
                              @"time" : @(time)
                             };
     BOOL result = [self.roomManager pubMsg:YSSignalingName_Timer msgID:YSSignalingName_Timer toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

     return result;

}

/// 老师计时器暂停
- (BOOL)sendSignalingTeacherToPauseTimerWithTime:(NSInteger)time completion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{@"time": @(time),
                              @"isStatus": @(true),
                             };
     BOOL result = [self.roomManager pubMsg:YSSignalingName_Timer msgID:YSSignalingName_Timer toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

     return result;
}

/// 老师计时器继续
- (BOOL)sendSignalingTeacherToContinueTimerWithTime:(NSInteger)time completion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{@"time": @(time),
                              @"isStatus": @(false),
                             };
     BOOL result = [self.roomManager pubMsg:YSSignalingName_Timer msgID:YSSignalingName_Timer toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

     return result;
}

/// 计时器中重置
- (BOOL)sendSignalingTeacherToRestartTimerWithDefaultTime:(NSInteger)defaultTime completion:(nullable completion_block)completion
{
    NSDictionary *sendDic = @{@"defaultTime": @(defaultTime),
                              @"isRestart": @(true)
                             };
     BOOL result = [self.roomManager pubMsg:YSSignalingName_Timer msgID:YSSignalingName_Timer toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

     return result;
}

/// 结束计时
- (BOOL)sendSignalingTeacherToDeleteTimerCompletion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager delMsg:YSSignalingName_Timer msgID:YSSignalingName_Timer toID:YSRoomPubMsgTellAll data:@{} completion:completion] == 0;

    return result;
} 

/// 通知各端开始举手
- (BOOL)sendSignalingToLiveAllAllowRaiseHandCompletion:(nullable completion_block)completion
{
    NSInteger classStartTime = self.tClassStartTime;//1584526733
    
    NSString * msgID = [NSString stringWithFormat:@"RaiseHandStart_%@_%ld",self.room_Id,(long)classStartTime];
    //RaiseHandStart_1931343076_1584526733.000000
    
    BOOL result = [self.roomManager pubMsg:YSSignalingName_RaiseHandStart msgID:msgID toID:YSRoomPubMsgTellAll data:@{@"maxSort":@300,@"subInterval":@2500} save:YES extensionData:@{@"type":@"useSort"} associatedMsgID:nil associatedUserID:nil expires:0 completion:completion];
    
    return (result == 0);
}


/// 老师订阅/取消订阅举手列表   type  subSort订阅/  unsubSort取消订阅
- (BOOL)sendSignalingToSubscribeAllRaiseHandMemberWithType:(NSString*)type Completion:(nullable completion_block)completion
{
    NSString * msgID = [YSLiveUtil createUUID];
    BOOL result = [self.roomManager pubMsg:YSSignalingName_RaiseHandResult msgID:msgID toID:YSRoomPubMsgTellNone data:@{@"min":@1,@"max":@300} save:NO extensionData:@{@"type":type} associatedMsgID:self.raisehandMsgID associatedUserID:nil expires:0 completion:completion];
    
    return (result == 0);
}


/// 老师发起轮播
- (BOOL)sendSignalingTeacherToStartVideoPollingWithUserID:(NSString *)peerId completion:(nullable completion_block)completion;
{
    
    BOOL result = [self.roomManager pubMsg:YSSignalingName_VideoPolling msgID:YSSignalingName_VideoPolling toID:YSRoomPubMsgTellAll data:@{} save:YES extensionData:nil associatedMsgID:nil associatedUserID:peerId expires:0 completion:nil] == 0;
    
    return result;
}
/// 老师停止轮播
- (BOOL)sendSignalingTeacherToStopVideoPollingCompletion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager delMsg:YSSignalingName_VideoPolling msgID:YSSignalingName_VideoPolling toID:YSRoomPubMsgTellAll data:@{} completion:completion] == 0;

    return result;
}
@end
