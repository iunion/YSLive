//
//  YSLiveSignaling.h
//  YSLive
//
//  Created by jiang deng on 2019/10/23.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSLiveSignaling_h
#define YSLiveSignaling_h

//typedef NS_ENUM(NSUInteger, YSCallRollStateType)
//{
//    YSCallRollStateType_Playback   = -1,   //回放
//    YSUserType_Teacher    = 0,    //老师
//    YSUserType_Assistant,         //助教
//    YSUserType_Student,           //学生
//    YSUserType_Live,              //直播
//    YSUserType_Patrol             //巡课
//};


// 信令 Signaling


// 信令名称

/// 同步服务器时间
#define YSSignalingName_UpdateTime                  @"UpdateTime"

/// 房间即将关闭消息
#define YSSignalingName_Notice_PrepareRoomEnd       @"Notice_PrepareRoomEnd"
#define YSSignalingId_Notice_PrepareRoomEnd                         @"Notice_PrepareRoomEnd"
#define YSSignalingId_Notice_PrepareRoomEnd_TeacherLeaveTimeout     @"PrepareRoomEnd_TeacherLeaveTimeout"

#define YSSignalingName_Notice_EvictAllRoomUse  @"Notice_EvictAllRoomUser"




/// 客户端请求关闭信令服务器房间
#define YSSignalingName_Notice_Server_RoomEnd       @"Server_RoomEnd"

/// 上课
#define YSSignalingName_ClassBegin                  @"ClassBegin"

/// 切换窗口布局
#define YSSignalingName_SetRoomLayout               @"SetRoomLayout"
/// 拖出视频
#define YSSignalingName_VideoDrag                   @"VideoDrag"
/// 拖出视频拉伸
#define YSSignalingName_VideoChangeSize             @"VideoChangeSize"
/// 双击视频最大化
#define YSSignalingName_DoubleClickVideo            @"doubleClickVideo"

/// 白板视频标注
#define YSSignalingName_VideoWhiteboard             @"VideoWhiteboard"

/// 点名
#define YSSignalingName_LiveCallRoll                @"LiveCallRoll"
/// 抽奖
#define YSSignalingName_LiveLuckDraw                @"LiveLuckDraw"
/// 抽奖结果
#define YSSignalingName_LiveLuckDrawResult          @"LiveLuckDrawResult"

/// 投票
#define YSSignalingName_VoteStart                   @"VoteStart"
/// 发送投票
#define YSSignalingName_VoteCommit                  @"voteCommit"
/// 投票结果
#define YSSignalingName_PublicVoteResult            @"PublicVoteResult"

/// 通知
#define YSSignalingName_LiveNoticeInform            @"LiveNoticeInform"
/// 公告
#define YSSignalingName_LiveNoticeBoard             @"LiveNoticeBoard"

/// 全体禁言
#define YSSignalingName_EveryoneBanChat             @"LiveAllNoChatSpeaking"

/// 房间用户数
#define YSSignalingName_Notice_BigRoom_Usernum      @"Notice_BigRoom_Usernum"
/// 用户网络差，被服务器切换媒体线路
#define YSSignalingName_Notice_ChangeMediaLine      @"Notice_ChangeMediaLine"


/// 提问 确认 回答 删除
#define YSSignalingName_LiveQuestions               @"LiveQuestions"

/// 送花
#define YSSignalingName_SendFlower                  @"LiveGivigGifts"

///是否开启上麦
#define YSSignalingName_UpPlatForm                  @"UpperwheatSort"

///同意/拒绝上麦
#define YSSignalingName_AllowUpPlatForm                  @"allowUpperwheat"

///申请上麦
#define YSSignalingName_ApplyUpPlatForm                  @"UpperwheatSortCommit"

///同意各端开始举手
#define YSSignalingName_RaiseHandStart                  @"RaiseHandStart"

///申请举手上台
#define YSSignalingName_RaiseHand                  @"RaiseHand"

///老师/助教  订阅/取消订阅举手列表
#define YSSignalingName_RaiseHandResult                  @"RaiseHandResult"

///老师/助教获取到的举手列表订阅结果
#define YSSignalingName_Server_Sort_Result                 @"Server_Sort_Result"

///双师：老师拖拽视频布局相关信令
#define YSSignalingName_DoubleTeacher                  @"one2oneVideoSwitchLayout"


/// 答题卡
#define YSSignalingName_Answer                      @"Answer"
/// 答题回答
#define YSSignalingName_AnswerCommit                @"AnswerCommit"
/// 老师获取学生的答题情况
#define YSSignalingName_AnswerGetResult             @"AnswerGetResult"
/// 公布答题结果
#define YSSignalingName_AnswerPublicResult          @"AnswerPublicResult"
/// 老师抢答器
#define YSSignalingName_Contest          @"Contest"
/// 收到学生抢答
#define YSSignalingName_ContestCommit          @"ContestCommit"
/// 抢答结果
#define YSSignalingName_ContestResult          @"ContestResult"
/// 关闭抢答
#define YSSignalingName_delContest             @"DelContest"
#define YSSignalingName_Timer             @"timer"
#pragma mark -
#pragma mark whiteBordSignaling

/// 更新白板数据(更换文档，翻页)
#define YSSignalingName_ShowPage                    @"ShowPage"


#pragma mark -
#pragma mark teacherSignaling

/// 老师发起上课/下课
#define YSSignalingName_TeacherClassBegain          @"ClassBegin"
/// 全体静音
#define YSSignalingName_LiveAllNoAudio              @"LiveAllNoAudio"
/// 删除课件
#define YSSignalingName_DocumentChange              @"DocumentChange"

#pragma mark -
#pragma mark Signaling define

#define YSSignaling_VideoWhiteboard_Id              @"videoDrawBoard"
#define YSSignaling_Whiteboard_SharpsChange         @"SharpsChange"

#endif /* YSLiveSignaling_h */
