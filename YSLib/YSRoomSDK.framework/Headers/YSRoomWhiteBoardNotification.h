//
//  YSRoomWhiteBoardNotification.h
//  YSRoomSDK
//

#ifndef YSRoomWhiteBoardNotification_h
#define YSRoomWhiteBoardNotification_h

/*=================================YSRoomWhiteBoard Notification====================================*/

/* key for YSRoomWhiteBoardNotification userInfo*/
/* value is an id*/
FOUNDATION_EXTERN NSString * const YSWhiteBoardNotificationUserInfoKey;


//进入教室，checkRoom相关通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnCheckRoomNotification;
//关于获取白板 服务器地址、备份地址、web地址相关通知
FOUNDATION_EXTERN NSString * const YSWhiteBoardGetServerAddrKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardGetServerAddrBackupKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardGetWebAddrKey;
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnServerAddrsNotification;

//用户属性改变通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRoomUserPropertyChangedNotification;
//有用户离开通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRoomUserLeavedNotification;
//有用户进入通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRoomUserJoinedNotification;
//大并发房间用户上台通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnBigRoomUserPublishedNotification;
//自己被踢出教室通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnSelfEvictedNotification;
//收到远端pubMsg消息通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRemotePubMsgNotification;
//收到远端delMsg消息的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRemoteDelMsgNotification;
//连接教室的通知
/* key for YSWhiteBoardOnRoomConnectedNotification userInfo*/
/* value is an id*/
FOUNDATION_EXTERN NSString * const YSWhiteBoardOnRoomConnectedCodeKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardOnRoomConnectedRoomMsgKey;

FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRoomConnectedNotification;
//断开链接的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRoomDisconnectNotification;
//重连服务器次数的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnReconnectingTimesNotification;
//回放总时长的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardReceivePlaybackDurationNotification;
//回放结束的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardPlaybackEndNotification;
//更新回放时间的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardPlaybackUpdateTimeNotification;
//教室文件列表的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardFileListNotification;
//教室消息列表的通知
FOUNDATION_EXTERN NSString * const YSWhiteBoardOnRemoteMsgListAddKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardOnRemoteMsgListKey;
//
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnRemoteMsgListNotification;
//关于共享媒体视频状态的通知
FOUNDATION_EXTERN NSString * const YSWhiteBoardOnShareMediaStateExtensionIdKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardOnShareMediaStateKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardOnShareMediaStateExtensionMsgKey;

FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnShareMediaStateNotification;
//更新共享媒体视频播放进度的通知
FOUNDATION_EXTERN NSString * const YSWhiteBoardUpadteMediaStreamDurationKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardUpadteMediaStreamPositionKey;
FOUNDATION_EXTERN NSString * const YSWhiteBoardUpadteMediaStreamPlayingKey;

FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardUpdateMediaStreamNotification;
//收到媒体视频第一帧画面的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardMediaFirstFrameLoadedNotification;
//关于画笔消息列表的通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardOnMsgListNotification;

    //关于发送获取白板消息列表通知
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardGetMsgListNotification;
    //关于获取白板消息列表ACK
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardMsgListACKNotification;
// 白板预加载
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardPreloadFileNotification;
// 白板预加载结束
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardDocPreloadFinishNotification;
// 白板课件加载失败
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardEventLoadFileFail;
// 白板课件加载页翻页超时失败
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardEventLoadSlideFail;


    //关于上传当前文档服务器地址
FOUNDATION_EXTERN NSNotificationName const YSWhiteBoardDocServerNotification;
FOUNDATION_EXTERN NSString * const YSWhiteBoardDocServerKey;

#endif /* YSRoomWhiteBoardNotification_h */
