//
//  YSWhiteBoardDefines.h
//  YSWhiteBoard
//
//  Created by jiang deng on 2020/3/22.
//  Copyright © 2020 jiang deng. All rights reserved.
//

#ifndef YSWhiteBoardDefines_h
#define YSWhiteBoardDefines_h


/// 白板创建完成
typedef void(^wbLoadFinishedBlock) (void);
/// webview崩溃回调
typedef void(^wbWebViewTerminateBlock)(void);


#define YSWhiteBoard_HttpDnsService_AccountID   131798

/// 网宿host头
static NSString *const YSWhiteBoard_domain_ws_header = @"rddoccdnws.roadofcloud";
static NSString *const YSWhiteBoard_domain_demows_header = @"rddoccdndemows.roadofcloud";
/// 网宿host
static NSString *const YSWhiteBoard_domain_ws = @"rddoccdnws.roadofcloud.net";
static NSString *const YSWhiteBoard_domain_demows = @"rddoccdndemows.roadofcloud.net";

/// 网宿dns解析
static NSString *const YSWhiteBoard_wshttpdnsurl = @"http://edge.wshttpdns.com/v1/httpdns/clouddns";

#define YSWHITEBOARD_USEHTTPDNS 1
#define YSWHITEBOARD_NORMALUSEHTTPDNS 1
//#if YSSDK
#define YSWHITEBOARD_USEHTTPDNS_ADDALI 0
//#else
//#define YSWHITEBOARD_USEHTTPDNS_ADDALI 1
//#endif

#if YSWHITEBOARD_USEHTTPDNS_ADDALI
/// 阿里host头
static NSString *const YSWhiteBoard_domain_ali_header = @"rddoccdn.roadofcloud";
static NSString *const YSWhiteBoard_domain_demoali_header = @"rddocdemo.roadofcloud";
/// 阿里host
static NSString *const YSWhiteBoard_domain_ali = @"rddoccdn.roadofcloud.net";
static NSString *const YSWhiteBoard_domain_demoali = @"rddocdemo.roadofcloud.net";
#endif


#define YSWhiteBoardId_Header                   @"docModule_"
static  NSString *const sWhiteboardID           = @"whiteboardID";
#define YSDefaultWhiteBoardId                   @"default"

/// 默认小班课白板背景颜色
#define YSWhiteBoard_MainBackGroudColor         YSSkinWhiteDefineColor(@"WhiteBoardDrawBoardBgColor")
#define YSWhiteBoard_MainBackDrawBoardBgColor   YSSkinWhiteDefineColor(@"WhiteBoardDrawBoardBgColor")
#define YSWhiteBoard_BackGroudColor             YSSkinWhiteDefineColor(@"WhiteBoardBgColor")

/// 默认直播白板背景颜色
#define YSWhiteBoard_LiveMainBackGroudColor         YSSkinWhiteDefineColor(@"LiveWhiteBoardBgColor")
#define YSWhiteBoard_LiveMainBackDrawBoardBgColor   YSSkinWhiteDefineColor(@"LiveWhiteBoardDrawBoardBgColor")
#define YSWhiteBoard_LiveBackGroudColor             YSSkinWhiteDefineColor(@"LiveWhiteBoardBgColor")

#define YSWhiteBoard_TopBarBackGroudColor       YSSkinWhiteDefineColor(@"videoBackColor")
#define YSWhiteBoard_BorderColor                [YSSkinWhiteDefineColor(@"videoBackColor") changeAlpha:0.8f]
#define YSWhiteBoard_UnTopBarBackGroudColor     YSSkinWhiteDefineColor(@"whiteBoardTopbar_noCurrent")
#define YSWhiteBoard_UnBorderColor              [YSSkinWhiteDefineColor(@"whiteBoardTopbar_noCurrent") changeAlpha:0.8f]


#pragma - mark 用户属性

/// 奖杯数
static  NSString *const sYSUserGiftNumber           = @"giftnumber";
static  NSString *const sYSUserGiftinfo             = @"giftinfo";



#pragma - mark 信令

/// 白板加载完成回调
static  NSString *const sYSSignalOnPageFinished         = @"onPageFinished";

/// 打印h5日志
static  NSString *const sYSSignalPrintLogMessage        = @"printLogMessage";

/// 白板放大事件
static  NSString *const sYSSignalChangeWebPageFullScreen = @"changeWebPageFullScreen";
/// 接收动作指令
static  NSString *const sYSSignalReceiveActionCommand   = @"receiveActionCommand";
/// 发送动作指令
static  NSString *const sYSSignalSendActionCommand      = @"sendActionCommand";

/// 本地持久化当前文档服务器的地址信息
static  NSString *const sYSSignalSaveValueByKey         = @"saveValueByKey";
static  NSString *const sYSSignalGetValueByKey          = @"getValueByKey";

/// 播放ppt内部MP3
static  NSString *const sYSSignalOnJsPlay               = @"isPlayAudio";

/// 显示课件
/// 单课件
static  NSString *const sYSSignalShowPage               = @"ShowPage";
/// 多课件
static  NSString *const sYSSignalExtendShowPage         = @"ExtendShowPage";
static  NSString *const sYSSignalDocumentChange         = @"DocumentChange";
/// 白板增加页数
static  NSString *const sYSSignalWBPageCount            = @"WBPageCount";


/// ShowPage ID
static  NSString *const sYSSignalDocumentFilePage_ShowPage          = @"DocumentFilePage_ShowPage";
static  NSString *const sYSSignalDocumentFilePage_ExtendShowPage    = @"DocumentFilePage_ExtendShowPage_";
static  NSString *const sYSSignalActionShow             = @"show";

/// 更换画笔工具
static  NSString *const sYSSignalSharpsChange           = @"SharpsChange";

/// 白板视频标注
#define YSVideoWhiteboard_Id                            @"videoDrawBoard"
static  NSString *const sYSSignalVideoWhiteboard        = @"VideoWhiteboard";

static  NSString *const sYSSignalH5DocumentAction       = @"H5DocumentAction";
static  NSString *const sYSSignalNewPptTriggerActionClick = @"NewPptTriggerActionClick";

/// 单窗口位置、大小、最小化、最大化数据
static  NSString *const sYSSignalMoreWhiteboardState    = @"MoreWhiteboardState";
static  NSString *const sYSSignalMoreWhiteboardGlobalState  = @"MoreWhiteboardGlobalState";


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

static NSString *const YSWhiteBoardDocProtocolKey = @"doc_protocol";
static NSString *const YSWhiteBoardDocHostKey = @"doc_host";
static NSString *const YSWhiteBoardDocPortKey = @"doc_port";

static NSString *const YSWhiteBoardBackupDocProtocolKey = @"backup_doc_protocol";
static NSString *const YSWhiteBoardBackupDocHostKey = @"backup_doc_host";
static NSString *const YSWhiteBoardBackupDocPortKey = @"backup_doc_port";

static NSString *const YSWhiteBoardBackupDocHostListKey = @"backup_doc_host_list";

#pragma - mark NSNotificationCenter

static NSString *const YSWhiteSendTextDrawIfChooseMouseNotification = @"YSWhiteSendTextDrawIfChooseMouseNotification";

#endif /* YSWhiteBoardDefines_h */
