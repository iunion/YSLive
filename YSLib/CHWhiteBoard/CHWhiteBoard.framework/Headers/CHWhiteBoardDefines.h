//
//  CHWhiteBoardDefines.h
//  CHWhiteBoard
//
//

#ifndef CHWhiteBoardDefines_h
#define CHWhiteBoardDefines_h

/// 白板创建完成
typedef void(^wbLoadFinishedBlock) (void);
/// webview崩溃回调
typedef void(^wbWebViewTerminateBlock)(void);


#define CHWhiteBoard_HttpDnsService_AccountID   131798

/// 网宿host头
static NSString *const CHWhiteBoard_domain_ws_header = @"rddoccdnws.roadofcloud";
static NSString *const CHWhiteBoard_domain_demows_header = @"rddoccdndemows.roadofcloud";
/// 网宿host
static NSString *const CHWhiteBoard_domain_ws = @"rddoccdnws.roadofcloud.net";
static NSString *const CHWhiteBoard_domain_demows = @"rddoccdndemows.roadofcloud.net";

/// 网宿dns解析
static NSString *const CHWhiteBoard_wshttpdnsurl = @"http://edge.wshttpdns.com/v1/httpdns/clouddns";

#define CHWHITEBOARD_USEHTTPDNS 1
#define CHWHITEBOARD_NORMALUSEHTTPDNS 1
#define CHWHITEBOARD_USEHTTPDNS_ADDALI 0

#if CHWHITEBOARD_USEHTTPDNS_ADDALI
/// 阿里host头
static NSString *const CHWhiteBoard_domain_ali_header = @"rddoccdn.roadofcloud";
static NSString *const CHWhiteBoard_domain_demoali_header = @"rddocdemo.roadofcloud";
/// 阿里host
static NSString *const CHWhiteBoard_domain_ali = @"rddoccdn.roadofcloud.net";
static NSString *const CHWhiteBoard_domain_demoali = @"rddocdemo.roadofcloud.net";
#endif


/// 白板服务器地址
FOUNDATION_EXTERN NSString * const CHWhiteBoardGetServerAddrKey;
/// 白板备份地址
FOUNDATION_EXTERN NSString * const CHWhiteBoardGetServerAddrBackupKey;
/// 白板web地址
FOUNDATION_EXTERN NSString * const CHWhiteBoardGetWebAddrKey;


#define CHWhiteBoardId_Header                   @"docModule_"
static  NSString *const sWhiteboardID           = @"whiteboardID";
#define CHDefaultWhiteBoardId                   @"default"

/// 默认小班课白板背景颜色
#define CHWhiteBoard_MainBackGroudColor         CHSkinWhiteDefineColor(@"WhiteBoardDrawBoardBgColor")
#define CHWhiteBoard_MainBackDrawBoardBgColor   CHSkinWhiteDefineColor(@"WhiteBoardDrawBoardBgColor")
#define CHWhiteBoard_BackGroudColor             CHSkinWhiteDefineColor(@"WhiteBoardBgColor")

/// 默认直播白板背景颜色
#define CHWhiteBoard_LiveMainBackGroudColor         CHSkinWhiteDefineColor(@"LiveWhiteBoardBgColor")
#define CHWhiteBoard_LiveMainBackDrawBoardBgColor   CHSkinWhiteDefineColor(@"LiveWhiteBoardDrawBoardBgColor")
#define CHWhiteBoard_LiveBackGroudColor             CHSkinWhiteDefineColor(@"LiveWhiteBoardBgColor")

#define CHWhiteBoard_TopBarBackGroudColor       CHSkinWhiteDefineColor(@"videoBackColor")
#define CHWhiteBoard_BorderColor                [CHSkinWhiteDefineColor(@"videoBackColor") changeAlpha:0.8f]
#define CHWhiteBoard_UnTopBarBackGroudColor     CHSkinWhiteDefineColor(@"whiteBoardTopbar_noCurrent")
#define CHWhiteBoard_UnBorderColor              [CHSkinWhiteDefineColor(@"whiteBoardTopbar_noCurrent") changeAlpha:0.8f]


#pragma - mark 信令

/// 白板加载完成回调
static  NSString *const sCHWBSignal_OnPageFinished            = @"onPageFinished";

/// 打印h5日志
static  NSString *const sCHWBSignal_PrintLogMessage           = @"printLogMessage";

/// 白板放大事件
static  NSString *const sCHWBSignal_ChangeWebPageFullScreen   = @"changeWebPageFullScreen";
/// 接收动作指令
static  NSString *const sCHWBSignal_ReceiveActionCommand      = @"receiveActionCommand";
/// 发送动作指令
static  NSString *const sCHWBSignal_SendActionCommand         = @"sendActionCommand";

/// 本地持久化当前文档服务器的地址信息
static  NSString *const sCHWBSignal_SaveValueByKey            = @"saveValueByKey";
static  NSString *const sCHWBSignal_GetValueByKey             = @"getValueByKey";

/// 播放ppt内部MP3
static  NSString *const sCHWBSignal_OnJsPlay                  = @"isPlayAudio";

/// 显示课件
/// 单课件
static  NSString *const sCHWBSignal_ShowPage                  = @"ShowPage";
/// 多课件
static  NSString *const sCHWBSignal_ExtendShowPage            = @"ExtendShowPage";
static  NSString *const sCHWBSignal_DocumentChange            = @"DocumentChange";
/// 白板增加页数
static  NSString *const sCHWBSignal_WBPageCount               = @"WBPageCount";


/// ShowPage ID
static  NSString *const sCHWBSignal_DocumentFilePage_ShowPage = @"DocumentFilePage_ShowPage";
static  NSString *const sCHWBSignal_DocumentFilePage_ExtendShowPage = @"DocumentFilePage_ExtendShowPage_";
static  NSString *const sCHWBSignal_ActionShow                = @"show";

/// 更换画笔工具
static  NSString *const sCHWBSignal_SharpsChange              = @"SharpsChange";

static  NSString *const sCHWBSignal_H5DocumentAction          = @"H5DocumentAction";
static  NSString *const sCHWBSignal_ExtendH5DocumentAction    = @"ExtendH5DocumentAction";

static  NSString *const sCHWBSignal_NewPptTriggerActionClick  = @"NewPptTriggerActionClick";
static  NSString *const sCHWBSignal_ExtendNewPptTriggerActionClick  = @"ExtendNewPptTriggerActionClick";

/// 单窗口位置、大小、最小化、最大化数据
static  NSString *const sCHWBSignal_MoreWhiteboardState       = @"MoreWhiteboardState";
static  NSString *const sCHWBSignal_MoreWhiteboardGlobalState = @"MoreWhiteboardGlobalState";


#pragma mark - 小黑板
/// 查看学生的小黑板信令
static  NSString *const sCHWBSignal_showUserSmallBlackBoard   = @"showUserSmallBlackBoard";

/// 小黑板学生上传图片信令
static  NSString *const sCHWBSignal_setSmallBlackBoardImage   = @"setSmallBlackBoardImage";

/// 小黑板阶段状态信令(准备，分发，收回，移除)
static  NSString *const sCHWBSignal_smallBlackBoardState     = @"smallBlackBoardState";

///小黑板,老师的固定whiteBoardId
static  NSString *const sCHWBTeachersmallWhiteBoardId        = @"smallBlackBoard-teacherId";
static  NSString *const sCHWBSmallFileId                     = @"smallFileId";

/// 小黑板答题阶段私聊
static  NSString *const sCHWBSignal_SmallRoomPrivate         = @"RoomPrivate";

#pragma - mark js命令

#define WBDisconnect                                @"disconnect"

//#define WBFakeJsSdkInitInfo                         @"updateFakeJsSdkInitInfo"
/// 更新文档服务地址信令
#define WBUpdateWebAddressInfo                      @"updateWebAddressInfo"

/// 刷新Web显示课件
#define WBReloadCurrentCourse                       @"reloadCurrentCourse"

/// 大房间刷新用户
#define WBParticipantPublished                      @"participantPublished"

/// 视图更新
#define WBViewStateUpdate                           @"viewStateUpdate"
#define WBDocumentLoadSuccessOrFailure              @"documentLoadSuccessOrFailure"
#define WBDocumentSlideLoadTimeout                  @"slideLoadTimeout"

/// 预加载文档
#define WBPreLoadingFile                            @"preLoadingFile"
/// 预加载文档结束
#define WBPreloadingFished                          @"preloadingFished"

#define WBPubMsg                                    @"pubMsg"
#define WBDelMsg                                    @"delMsg"
#define WBSetProperty                               @"setProperty"
#define WBParticipantLeft                           @"participantLeft"
#define WBParticipantJoined                         @"participantJoined"
#define WBParticipantEvicted                        @"participantEvicted"

#define WBUpdatePermission                          @"updatePermission"

#define WBRoomConnected                             @"roomConnected"

/// 更新动态ppt大小
#define WBChangeDynamicPptSize                     @"changeDynamicPptSize"

#define WBAddPage                                  @"whiteboardSDK_addPage"//添加页
/// 翻页 下一页、上一页、下一步上一步
#define WBSlideOrStep                              @"slideOrStep"
#define WBNextPage                                 @"whiteboardSDK_nextPage"//下一页
#define WBPrevPage                                 @"whiteboardSDK_prevPage"//上一页
#define WBNextStep                                 @"whiteboardSDK_nextStep"//下一步
#define WBPrevStep                                 @"whiteboardSDK_prevStep"//上一步

/// enlarge 放大 narrow 缩小 fullScreen 全屏 exitFullScreen 退出全屏
#define WBDocResize                                @"docResize"


#pragma - mark Dictionary Key

static NSString *const CHWhiteBoardDocProtocolKey = @"doc_protocol";
static NSString *const CHWhiteBoardDocHostKey = @"doc_host";
static NSString *const CHWhiteBoardDocPortKey = @"doc_port";

static NSString *const CHWhiteBoardBackupDocProtocolKey = @"backup_doc_protocol";
static NSString *const CHWhiteBoardBackupDocHostKey = @"backup_doc_host";
static NSString *const CHWhiteBoardBackupDocPortKey = @"backup_doc_port";

static NSString *const CHWhiteBoardBackupDocHostListKey = @"backup_doc_host_list";

#pragma - mark NSNotificationCenter

static NSString *const CHWhiteSendTextDrawIfChooseMouseNotification = @"CHWhiteSendTextDrawIfChooseMouseNotification";


#endif /* CHWhiteBoardDefines_h */
