//
//  CHSessionForWhiteBoardDelegate.h
//  CHSession
//
//

#ifndef CHSessionForWhiteBoardDelegate_h
#define CHSessionForWhiteBoardDelegate_h

NS_ASSUME_NONNULL_BEGIN

@protocol CHSessionForWhiteBoardDelegate <CloudHubRtcEngineDelegate>

/// checkRoom获取房间信息
- (void)roomWhiteBoardOnCheckRoom:(NSDictionary *)roomDic cloudHubRtcEngineKit:(CloudHubRtcEngineKit *)cloudHubRtcEngineKit;

/// 获取服务器地址
- (void)roomWhiteBoardOnChangeServerAddrs:(NSDictionary *)serverDic;

/// 设置文件列表
- (void)roomWhiteBoardOnFileList:(nullable NSArray <NSDictionary *> *)fileList;

@end

NS_ASSUME_NONNULL_END

#endif /* CHSessionForWhiteBoardDelegate_h */
