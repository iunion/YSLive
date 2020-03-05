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

/// 一V一时改变布局
- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(YSLiveRoomLayout)layoutType
{
    return [self sendSignalingToChangeLayoutWithLayoutType:layoutType appUserType:YSAppUseTheTypeSmallClass];
}

/// 一V一时改变布局
- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(YSLiveRoomLayout)layoutType appUserType:(YSAppUseTheType)appUserType
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
    else
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
    
    return result;
}

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
    
    NSString *msgID = [NSString stringWithFormat:@"VideoDrag_%@", [data bm_stringForKey:@"userId"]];
    if ([data bm_boolForKey:@"isDrag"])
    {
        result = [self.roomManager pubMsg:YSSignalingName_VideoDrag msgID:msgID toID:YSRoomPubMsgTellAll data:data save:YES completion:nil];
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
- (BOOL)sendSignalingTeacherToSwitchDocumentWithFile:(YSFileModel *)fileModel completion:(nullable completion_block)completion
{
    if (![fileModel bm_isNotEmpty])
    {
        return NO;
    }
    
    if ([YSLiveUtil checkIsMedia:fileModel.filetype])
    {
        BOOL tIsVideo = [YSLiveUtil checkIsVideo:fileModel.filetype];
        
        NSString *filename = fileModel.filename ? fileModel.filename : @"";
        NSDictionary *sendDic = @{@"filename":filename,
                                  @"fileid":fileModel.fileid,
                                  @"pauseWhenOver":@(true),
                                  @"type": @"media",
                                  @"source": @"mediaFileList"
                                
                                };
        
        NSString *url = [self absolutefileUrl:fileModel.swfpath];
        BOOL result = [self.roomManager startShareMediaFile:url isVideo:tIsVideo toID:YSRoomPubMsgTellAll attributes:sendDic block:completion] == 0;
        return result;
        
    }
    else
    {
        NSNumber *currpage = [fileModel.currpage bm_isNotEmpty] ? @(fileModel.currpage.integerValue) : @(1);
        NSNumber *pptslide = [fileModel.pptslide bm_isNotEmpty] ? @(fileModel.pptslide.integerValue) : @(1);
        NSNumber *pptstep = [fileModel.pptstep bm_isNotEmpty] ? @(fileModel.pptstep.integerValue) : @(0);
        NSNumber *steptotal = [fileModel.steptotal bm_isNotEmpty] ? @(fileModel.steptotal.integerValue) : @(0);
        NSNumber *pagenum = [fileModel.pagenum bm_isNotEmpty] ? @(fileModel.pagenum.integerValue) : @(1);
        NSString *filetype = [fileModel.filetype bm_isNotEmpty] ? fileModel.filetype : @"";
        NSString *filename = fileModel.filename ? fileModel.filename : @"";
        NSString *swfpath = fileModel.swfpath ? fileModel.swfpath : @"";
        NSDictionary *fileData = @{@"currpage":currpage,
                                   @"pptslide":pptslide,
                                   @"pptstep":pptstep ,
                                   @"steptotal":steptotal,
                                   @"fileid":fileModel.fileid,
                                   @"pagenum":pagenum,
                                   @"filename":filename,
                                   @"filetype":filetype,
                                   @"isContentDocument":fileModel.isContentDocument,
                                   @"cospdfpath":@"",
                                   @"swfpath":swfpath
                                };
        
        NSDictionary *sendDic = @{@"sourceInstanceId":@"default",
                                  @"isGeneralFile":@(fileModel.isGeneralFile.boolValue),
                                  @"isMedia": @(fileModel.isMedia.boolValue),
                                  @"isDynamicPPT": @(fileModel.isDynamicPPT.boolValue),
                                  @"isH5Document": @(fileModel.isH5Document.boolValue),
                                  @"action":@"show",
                                  @"mediaType":@"",
                                  @"filedata":fileData
                                };
        BOOL result = [self.roomManager pubMsg:sShowPage msgID:sDocumentFilePage_ShowPage toID:YSRoomPubMsgTellAll data:[sendDic bm_toJSON] save:YES completion:completion] == 0;
        return result;
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
    
    if (![detailData bm_isNotEmpty])
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
    NSDictionary *sendDic = @{ @"state" : @"starting" };
    BOOL result = [self.roomManager pubMsg:YSSignalingName_Contest msgID:YSSignalingName_Contest toID:YSRoomPubMsgTellAllExceptSender data:[sendDic bm_toJSON] save:NO extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;

}

/// 发布抢答器结果
- (BOOL)sendSignalingTeacherToContestResultWithName:(NSString *)name completion:(nullable completion_block)completion
{
    if (![name bm_isNotEmpty])
    {
        return NO;
    }

    NSDictionary *sendDic = @{ @"nickName" : name };
    BOOL result = [self.roomManager pubMsg:YSSignalingName_ContestResult msgID:YSSignalingName_ContestResult toID:YSRoomPubMsgTellAllExceptSender data:[sendDic bm_toJSON] save:NO extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

    return result;

}
/// 关闭抢答器
- (BOOL)sendSignalingTeacherToCloseResponderCompletion:(nullable completion_block)completion
{
    BOOL result = [self.roomManager pubMsg:YSSignalingName_delContest msgID:YSSignalingName_delContest toID:YSRoomPubMsgTellAllExceptSender data:@"" save:NO extensionData:nil associatedMsgID:nil associatedUserID:nil expires:0 completion:nil] == 0;

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
    NSString * msgID = [NSString stringWithFormat:@"RaiseHandStart%@_%f",self.room_Id,self.tClassStartTime];
    
    BOOL result = [self.roomManager pubMsg:YSSignalingName_RaiseHandStart msgID:msgID toID:YSRoomPubMsgTellAll data:@{@"maxSort":@300,@"subInterval":@2500} save:YES extensionData:@{@"type":@"useSort"} associatedMsgID:nil associatedUserID:nil expires:0 completion:completion];
    
    return (result == 0);
}


/// 老师订阅/取消订阅举手列表   type  subSort订阅/  unsubSort取消订阅
- (BOOL)sendSignalingToSubscribeAllRaiseHandMemberWithType:(NSString*)type Completion:(nullable completion_block)completion
{
    NSString * msgID = [YSLiveUtil createUUID];
//    NSString *associatedMsgID = [NSString stringWithFormat:@"RaiseHandStart%@_%f",self.room_Id,self.tClassStartTime];
    NSString *associatedMsgID = [[NSUserDefaults standardUserDefaults] valueForKey:sUserRaisehand];
    BOOL result = [self.roomManager pubMsg:YSSignalingName_RaiseHandResult msgID:msgID toID:YSRoomPubMsgTellNone data:@{@"min":@1,@"max":@300} save:NO extensionData:@{@"type":type} associatedMsgID:associatedMsgID associatedUserID:nil expires:0 completion:completion];
    
    return (result == 0);
}


@end
