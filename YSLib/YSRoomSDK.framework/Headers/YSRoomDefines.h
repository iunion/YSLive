//
//  YSRoomDefines.h
//  YSRoomSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define YS_Deprecated(string) __attribute__((deprecated(string)))
#
#pragma mark -  房间初始化相关设置
#
//******调用- (int)initWithAppKey:optional: 初始化设置 optional字典 key值定义*******//
//socekt 自动重连次数，默认是无限次
FOUNDATION_EXTERN NSString * const YSRoomSettingOptionalReconnectattempts;
//若有使用到sdk白板功能，需要设置次参数，表示会接收到白板消息通知。 若不是用sdk白板功能，可不需要设置。
//value：NSNumber类型 YES表示接受通知，NO表示不通知。
FOUNDATION_EXTERN NSString * const YSRoomSettingOptionalWhiteBoardNotify;

//设置编码格式 @optional Key值，可不传，若不传会根据房间属性设置。 value：NSNumber类型 YSVideoCodecType枚举值
FOUNDATION_EXTERN NSString * const YSRoomSettingOptionalVideoCodec;
//设置即时房间类型 @optional Key值，可不传，默认是一对多YSRoomType_More。 value：NSNumber类型 YSRoomTypes枚举值
FOUNDATION_EXTERN NSString * const YSRoomSettingOptionalRoomType;

#pragma mark socekt使用协议参数
//value: NSNumber类型 YES:使用https wss, NO:使用http ws  默认为YES。
FOUNDATION_EXTERN NSString * const YSRoomSettingOptionalSecureSocket;

#pragma mark - 私有部署房间相关
//私有地址  默认为api.roadofcloud.com
FOUNDATION_EXTERN NSString * const YSRoomSettingOptionalPrivateHostAddress;
//私有端口  如果YSRoomSettingOptionalSecureSocket 设置为YES，默认为443；如果YSRoomSettingOptionalSecureSocket 设置为NO，默认为80.
// ***YSRoomSettingOptionalSecureSocket优先.***
FOUNDATION_EXTERN NSString * const YSRoomSettingOptionalPrivatePort;

#
#pragma mark - joinroom 相关定义
#
//******调用joinroom 接口进入房间，roomParams字典参数所需 Key值定义******//
//房间ID @required
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsRoomIDKey;
//密码key值 @required，如果该房间或者该用户角色没有密码，value：@""
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsPasswordKey;

//用户角色key值 @optional
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsUserRoleKey;
//用户ID的key值 @optional，如果不传用户ID，sdk会自动生成用户ID
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsUserIDKey;

//******调用pubMsg以及delMsg 接口发送信令，toID参数相关传值；表示：此信令需要通知的对象******//
//所有人
FOUNDATION_EXTERN NSString * const YSRoomPubMsgTellAll;
//除自己以外的所有人
FOUNDATION_EXTERN NSString * const YSRoomPubMsgTellAllExceptSender;
//除旁听用户以外的所有人
FOUNDATION_EXTERN NSString * const YSRoomPubMsgTellAllExceptAuditor;
//不通知任何人
FOUNDATION_EXTERN NSString * const YSRoomPubMsgTellNone;
//通知老师和助教
FOUNDATION_EXTERN NSString * const YSRoomPubMsgTellAllSuperUsers;


#
#pragma mark - block重命名
#
typedef void (^completion_block)(NSError *error);
typedef void (^progress_block)(int playID, int64_t current, int64_t total);

#
#pragma mark - YSRoomWarningCode 警告码
#
typedef NS_ENUM(NSInteger, YSRoomWarningCode) {
    YSRoomWarning_UnKnow,
    YSRoomWarning_Microphone_NotWorking                 = 111,         //麦克风不可用
    YSRoomWarning_Micphone_InterruptionBegan,          // the system has interrupted your audio session,the interruption has began
    YSRoomWarning_Micphone_InterruptionEnded,          // the interruption has ended
    YSRoomWarning_AudioRouteChange_Headphones           = 121,   //耳机
    YSRoomWarning_AudioRouteChange_BuiltInReceiver,    //听筒模式（手机靠近耳边）
    YSRoomWarning_AudioRouteChange_BuiltInSpeaker,     // 内置扬声器（外放）
    YSRoomWarning_AudioRouteChange_Bluetooth,          // 蓝牙
    
    YSRoomWarning_RequestAccessForVideo_Failed          = 131,   //请求获取摄像头失败
    YSRoomWarning_RequestAccessForAudio_Failed          = 132,   //请求获取麦克风失败
    
    
    YSRoomWarning_CheckRoom_Completed                   = 1001,    //CheckRoom 成功
    YSRoomWarning_GetConfig_Completed                   = 1002,    //GetConfig 成功
    
    YSRoomWarning_UnpublishVideo_By_SwitchAudioRoom     = 1011,
    YSRoomWarning_PublishVideo_By_SwitchAudioVideoRoom  = 1012,
    YSRoomWarning_UnpublishVideo_By_Max_Reconnect_Count = 1013,
    YSRoomWarning_UnpublishAudio_By_Max_Reconnect_Count = 1014,
    
    YSRoomWarning_Stream_Connected                      = 1101,
    YSRoomWarning_Stream_Failed                         = 1102,
    YSRoomWarning_Stream_Closed                         = 1103,

    YSRoomWarning_ReConnectSocket_ServerChanged         = 5002,   //切换了服务器
    YSRoomWarning_DevicePerformance_Low                 = 5003,   //设备性能过低
};

#
#pragma mark - YSRoomErrorCode 错误码
#
typedef NS_ENUM(NSInteger, YSRoomErrorCode) {
    YSErrorCode_UnKnow              = -2,
    YSErrorCode_Internal_Exception  = -1,
    YSErrorCode_OK                  = 0,
    
    YSErrorCode_Not_Initialized     = 101,
    YSErrorCode_Bad_Parameters      = 102,
    YSErrorCode_Room_StateError     = 103,
    YSErrorCode_Publish_StateError  = 104,
    YSErrorCode_Stream_StateError   = 105,
    YSErrorCode_Stream_NotFound     = 106,
    YSErrorCode_FilePath_NotExist   = 107,
    YSErrorCode_CreateFile_Failed   = 108,
    YSErrorCode_TestSpeed_Failed     = 109,
    YSErrorCode_RenderView_ReUsed               = 110,//view已被使用
    
    YSErrorCode_Publish_NoAck                    = 401,
    YSErrorCode_Publish_RoomNotExist             = 402,
    YSErrorCode_Publish_RoomMaxVideoLimited      = 403,
    YSErrorCode_Publish_ErizoJs_Timeout          = 404,
    YSErrorCode_Publish_Agent_Timeout            = 405,
    YSErrorCode_Publish_UndefinedRPC_Timeout     = 406,
    YSErrorCode_Publish_AddingInput_Error        = 407,
    YSErrorCode_Publish_DuplicatedExtensionId    = 408,
    YSErrorCode_Publish_Unauthorized             = 409,
    YSErrorCode_Publish_Failed                   = 410,//发布失败，自动重新发布
    YSErrorCode_Publish_Timeout                  = 411,//发布失败，自动重新发布
    
    YSErrorCode_Subscribe_RoomNotExist           = 501,
    YSErrorCode_Subscribe_StreamNotDefine        = 502,
    YSErrorCode_Subscribe_MediaRPC_Timeout       = 503,
    YSErrorCode_Subscribe_Fail                   = 504,//订阅失败，自动重新订阅
    YSErrorCode_Subscribe_Timeout                = 505,//订阅超时，自动重新订阅
    
    YSErrorCode_ConnectSocketError               = 601,

    YSErrorCode_JoinRoom_WrongParam              = 701,// 参数错误
    
    YSErrorCode_CheckRoom_RequestFailed          = 801,    //获取房间信息失败
    YSErrorCode_RoomConfig_RequestFailed         = 802,    //获取房间配置失败
    
    YSErrorCode_CheckRoom_ServerOverdue          = 3001,    //服务器过期
    YSErrorCode_CheckRoom_RoomFreeze             = 3002,    //公司被冻结
    YSErrorCode_CheckRoom_RoomDeleteOrOrverdue   = 3003,    //房间已删除或过期
    YSErrorCode_CheckRoom_CompanyNotExist        = 4001,    //该公司不存在
    YSErrorCode_CheckRoom_RoomNonExistent        = 4007,    //房间不存在
    YSErrorCode_CheckRoom_PasswordError          = 4008,    //房间密码错误
    YSErrorCode_CheckRoom_WrongPasswordForRole   = 4012,    //密码与身份不符
    YSErrorCode_CheckRoom_RoomNumberOverRun      = 4103,    //房间人数超限
    YSErrorCode_CheckRoom_RoomAuthenError        = 4109,    //认证错误
    YSErrorCode_CheckRoom_NeedPassword           = 4110,    //该房间需要密码，请输入密码
    YSErrorCode_CheckRoom_RoomPointOverrun       = 4112,    //企业点数超限
};


#
#pragma mark - YSMediaType 媒体类型
#
typedef NS_ENUM(NSInteger, YSMediaType) {
    YSMediaSourceType_unknow    = -1,
    YSMediaSourceType_camera    = 0,      //视频
    YSMediaSourceType_mic       = 11,
    YSMediaSourceType_file      = 101,    //本地电影共享
    YSMediaSourceType_screen    = 102,    //屏幕共享
    YSMediaSourceType_media     = 103,    //媒体文件 mp4、mp3
};

#
#pragma mark - YSPublishState 发布状态
#
typedef NS_ENUM(NSInteger, YSPublishState) {
    YSUser_PublishState_UNKown          = -2,                //未知状态
    YSUser_PublishState_NONE            = 0,          //没有
    YSUser_PublishState_AUDIOONLY,                  //只有音频
    YSUser_PublishState_VIDEOONLY,                  //只有视频
    YSUser_PublishState_BOTH,                       //都有
};
#
#pragma mark - YSMediaState 媒体流发布状态
#
typedef NS_ENUM(NSInteger, YSMediaState) {
    YSMedia_Unpulished  = 0,  //未发布
    YSMedia_Pulished    = 1,    //发布
};

#
#pragma mark - YSVideoStreamType 视频流类型
#
typedef NS_ENUM(NSInteger, YSVideoStreamType) {
    YSVideoStream_Big   = 0,  //
    YSVideoStream_Small = 1,    //小流
};

#
#pragma mark - YSVideoCodecType 视频编码格式
#
typedef NS_ENUM(NSUInteger, YSVideoCodecType) {
    YSVideoCodec_VP8 = 0,       //vp8
    YSVideoCodec_H264 = 2,      //h264
};

#
#pragma mark - YSRoomType 即时房间类型
#
typedef NS_ENUM(NSUInteger, YSRoomTypes) {
    YSRoomType_One = 0,       //一对一房间
    YSRoomType_More = 1,      //一对多房间
};

#
#pragma mark - YSRenderMode 渲染模式
#
typedef NS_ENUM(NSInteger, YSRenderMode) {
    YSRenderMode_fit       = 0,  //等比拉伸
    YSRenderMode_adaptive  = 1,  //等比拉伸，并占满全屏
};

#
#pragma mark - YSRenderState 
#
typedef NS_ENUM(NSInteger, YSRenderState) {
    YSRenderState_Interruption  = 0,   //中断
    YSRenderState_Resumption    = 1,   //恢复
    YSRenderState_NoSignal      = 2,   //等待首次数据时间过长
};

#
#pragma mark - YSVideoMirrorMode 视频渲染镜像模式
#
typedef NS_ENUM(NSUInteger, YSVideoMirrorMode) {
    YSVideoMirrorModeAuto       = 0,  //默认设置，前置摄像头时开启镜像模式，后置摄像头时不开启镜像
    YSVideoMirrorModeEnabled    = 1,  //前置和后置均开启镜像模式
    YSVideoMirrorModeDisabled   = 2,  //前置和后置均不开启镜像模式
};
#
#pragma mark - YSLogLevel 日志等级
#
typedef NS_ENUM(NSUInteger, YSLogLevel){
    /**
     *  No logs
     */
    YSLogLevelOff = 0,
    
    /**
     *  Error logs only
     */
    YSLogLevelError = (1 << 0),
    
    /**
     *  Error and warning logs
     */
    YSLogLevelWarning = (YSLogLevelError | 1 << 1),
    
    /**
     *  Error, warning and info logs
     */
    YSLogLevelInfo = (YSLogLevelWarning | 1 << 2),
    
    /**
     *  Error, warning, info and debug logs
     */
    YSLogLevelDebug = (YSLogLevelInfo | 1 << 3),
    
    /**
     *  Error, warning, info, debug and verbose logs
     */
    YSLogLevelVerbose = (YSLogLevelDebug | 1 << 4),
    
    /**
     *  All logs (1...11111)
     */
    YSLogLevelAll = NSUIntegerMax
};

#
#pragma mark - YSUserRoleType 用户角色
#
typedef NS_ENUM(NSInteger, YSUserRoleType) {
    YSUserType_Playback   = -1,   //回放
    YSUserType_Teacher    = 0,    //老师
    YSUserType_Assistant,         //助教
    YSUserType_Student,           //学生
    YSUserType_Live,              //直播
    YSUserType_Patrol             //巡课
};
#
#pragma mark - YSRecordType 录制件类型
#
typedef NS_ENUM(NSInteger, YSRecordType) {
    YSRecordType_RecordFile     = 0,    //生成录制件
    YSRecordType_RecordList     = 1,    //生成录制列表
    YSRecordType_RecordMp3File  = 2, //只生成mp3
    YSRecordType_RecordMaxFile  = 3, //同时生产mp3和mp4
};

typedef NS_ENUM(NSInteger, YSNetQuality) {
    YSNetQuality_Excellent  = 1, //优
    YSNetQuality_Good,          //良
    YSNetQuality_Accepted,      //中
    YSNetQuality_Bad,           //差
    YSNetQuality_VeryBad,       //极差
    YSNetQuality_Down,
};

typedef NS_ENUM(NSInteger, YSSampleFormat) {

    YSSampleFormat_None = -1,
    YSSampleFormat_U8,          ///< unsigned 8 bits
    YSSampleFormat_S16,         ///< signed 16 bits
    YSSampleFormat_S32,         ///< signed 32 bits
    YSSampleFormat_FLT,         ///< float
    YSSampleFormat_DBL,         ///< double
    
    YSSampleFormat_U8P,         ///< unsigned 8 bits, planar
    YSSampleFormat_S16P,        ///< signed 16 bits, planar
    YSSampleFormat_S32P,        ///< signed 32 bits, planar
    YSSampleFormat_FLTP,        ///< float, planar
    YSSampleFormat_DBLP,        ///< double, planar
    YSSampleFormat_S64,         ///< signed 64 bits
    YSSampleFormat_S64P,        ///< signed 64 bits, planar
    
    YSAVSampleFormat_NB           ///< Number of sample formats. DO NOT USE if linking dynamically
};
#
#pragma mark - YSMediaFileInfo 媒体文件信息
#
@interface YSMediaFileInfo : NSObject
@property (assign, nonatomic) NSInteger duration;
@property (assign, nonatomic) NSInteger width;
@property (assign, nonatomic) NSInteger height;
@property (assign, nonatomic) NSInteger fps;
@property (assign, nonatomic) BOOL video;
@property (assign, nonatomic) BOOL audio;
@end

#
#pragma mark - YSDeviceFaultType 设备故障类型
#
typedef NS_ENUM(NSInteger, YSDeviceFaultType) {
    YSDeviceFaultNone           = 0, //设备流正常
    YSDeviceFaultUnknown        = 1, //未知错误
    YSDeviceFaultNotFind        = 2, //没找到设备
    YSDeviceFaultNotAuth        = 3, //没有授权
    YSDeviceFaultOccupied       = 4, //设备占用
    YSDeviceFaultConError       = 5, //约束无法获取设备流
    YSDeviceFaultConFalse       = 6, //约束都为false
    YSDeviceFaultStreamOverTime = 7, //获取设备流超时
    YSDeviceFaultStreamEmpty    = 8, //设备流没有数据
    YSDeviceFaultSDPFail = 9 //协商不成功
};

#
#pragma mark - YSVideoProfile 视频属性
#
@interface YSVideoProfile : NSObject
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger maxfps;
@end

#
#pragma mark - YSVideoCanvas 视频属性
#
@interface YSVideoCanvas : NSObject

@property (strong, nonatomic) UIView *view;// 视频渲染窗口
@property (assign, nonatomic) YSRenderMode renderMode;//渲染模式
@property (assign, nonatomic) BOOL isMirror;// 是否是镜像
@end


#
#pragma mark - YSAudioFrame 音频数据
#
@interface YSAudioFrame : NSObject
/**
 number of samples in this frame
 */
@property (assign, nonatomic) NSInteger samples;

/**
 number of bytes per sample: 2 for PCM16
 */
@property (assign, nonatomic) NSInteger bytesPerSample;

/**
 number of channels (data are interleaved if stereo)
 */
@property (assign, nonatomic) NSInteger channels;

/**
 sampling rate
 */
@property (assign, nonatomic) NSInteger samplesPerSec;

@property (assign, nonatomic) YSSampleFormat format;

/**
 data buffer
 */
@property (nonatomic) void *buffer;
@end
#
#pragma mark - YSVideoFrame 视频数据
#
@interface YSVideoFrame : NSObject

/**
 width of video frame
 */
@property (assign, nonatomic) NSInteger width;

/**
 height of video frame
 */
@property (assign, nonatomic) NSInteger height;

/**
 stride of Y data buffer
 */
@property (assign, nonatomic) NSInteger yStride;

/**
 stride of U data buffer
 */
@property (assign, nonatomic) NSInteger uStride;

/**
 stride of V data buffer
 */
@property (assign, nonatomic) NSInteger vStride;

/**
 Y data buffer
 */
@property (nonatomic) void *yBuffer;

/**
 U data buffer
 */
@property (nonatomic) void *uBuffer;

/**
 V data buffer
 */
@property (nonatomic) void *vBuffer;

/**
 rotation of this frame (0, 90, 180, 270)
 */
@property (assign, nonatomic) NSInteger rotation;

@end


#
#pragma mark - YSAudioStats 音频统计数据
#
@interface YSAudioStats : NSObject
/**
 带宽 bps
 */
@property (assign, nonatomic) NSInteger bitsPerSecond;

/**
 总字节数
 */
@property (assign, nonatomic) int64_t totalBytes;
/**
 丢包数
 */
@property (assign, nonatomic) NSInteger packetsLost;

/**
 总包数
 */
@property (assign, nonatomic) NSInteger totalPackets;

/**
 延迟 毫秒
 */
@property (assign, nonatomic) NSInteger currentDelay;

/**
 抖动
 */
@property (assign, nonatomic) NSInteger jitter;

/**
 网络质量
 */
@property (assign, nonatomic) YSNetQuality netLevel;
@property (assign, nonatomic) NSTimeInterval timeStamp;

@end
//丢包率  packetsLost/totalPackets  0~1%优 1%~3% 3%~5%中等 5~10%差  >10%极差
//延迟                              80ms  120ms  300ms  800ms  >800ms
#
#pragma mark - YSVideoStats 视频统计数据
#
@interface YSVideoStats : NSObject

@property (assign, nonatomic) NSInteger firsCount;
@property (assign, nonatomic) NSInteger plisCount;

@property (assign, nonatomic) NSInteger bitsPerSecond;
@property (assign, nonatomic) int64_t totalBytes;

/**
 延迟
 */
@property (assign, nonatomic) NSInteger currentDelay;

/**
 帧率
 */
@property (assign, nonatomic) NSInteger frameRate;

/**
 视频宽
 */
@property (assign, nonatomic) NSInteger frameWidth;

/**
 视频高
 */
@property (assign, nonatomic) NSInteger frameHeight;
/**
 网络质量
 */
@property (assign, nonatomic) YSNetQuality netLevel;

@property (assign, nonatomic) NSTimeInterval timeStamp;

@property (assign, nonatomic) NSInteger packetsLost;
@property (assign, nonatomic) NSInteger totalPackets;

@end


#
#pragma mark - YSRtcStats 音视频总统计数据
#
@interface YSRtcStats : NSObject

/**
 下行音频帧率
 */
@property (assign, nonatomic) NSInteger outAudioBitRate;

/**
 上行音频帧率
 */
@property (assign, nonatomic) NSInteger inAudioBitRate;

/**
 下行视频帧率
 */
@property (assign, nonatomic) NSInteger outVideoBitRate;

/**
 上行视频帧率
 */
@property (assign, nonatomic) NSInteger inVideoBitRate;

/**
 下行总字节数
 */
@property (assign, nonatomic) int64_t outBytes;

/**
 上行总字节数
 */
@property (assign, nonatomic) int64_t inBytes;

/**
 下行总包数
 */
@property (assign, nonatomic) NSInteger outPackets;

/**
 上行总包数
 */
@property (assign, nonatomic) NSInteger inPackets;

/**
 下行音频丢包率
 */
@property (assign, nonatomic) CGFloat outAudioPacketLostRate;

/**
 上行音频丢包率
 */
@property (assign, nonatomic) CGFloat inAudioPacketLostRate;

/**
 下行视频丢包率
 */
@property (assign, nonatomic) CGFloat outVideoPacketLostRate;

/**
 上行视频丢包率
 */
@property (assign, nonatomic) CGFloat inVideoPacketLostRate;

/**
 下行网络质量
 */
@property (assign, nonatomic) YSNetQuality outNetQuality;

/**
 上行网络质量
 */
@property (assign, nonatomic) YSNetQuality inNetQuality;

/**
 网络质量
 */
@property (assign, nonatomic) YSNetQuality netQuality;

/**
 音频延迟
 */
@property (assign, nonatomic) NSInteger audioDelay;

/**
 视频延迟
 */
@property (assign, nonatomic) NSInteger videoDelay;

/**
 时长
 */
@property (assign, nonatomic) int64_t duration;

@end

