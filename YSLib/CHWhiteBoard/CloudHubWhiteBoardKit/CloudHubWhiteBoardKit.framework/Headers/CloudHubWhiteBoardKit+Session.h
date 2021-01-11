//
//  CloudHubWhiteBoardKit+Session.h
//  CloudHubWhiteBoardKit
//
//  Created by jiang deng on 2020/12/26.
//

#import <UIKit/UIKit.h>
#import <CloudHubWhiteBoardKit/CloudHubWhiteBoardKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CloudHubWhiteBoardKit (Session)

/// 暖场视频课件
@property (nonatomic, weak, readonly) CHFileModel *warmFileModel;


- (void)registeWhiteBoardWithConfigration:(nullable CloudHubWhiteBoardConfig *)config userId:(nullable NSString *)userId nickName:(nullable NSString *)nickName host:(nullable NSString *)host port:(NSUInteger)port mainWhiteBoardViewSize:(CGSize)size cloudHubRtcEngineKit:(CloudHubRtcEngineKit *)cloudHubRtcEngineKit;

/// 获取服务器地址
- (void)roomWhiteBoardOnChangeServerAddrs:(NSDictionary *)serverDic;

/// 设置文件列表
- (void)roomWhiteBoardOnFileList:(nullable NSArray <NSDictionary *> *)fileList;

/// 上传图片
- (void)uploadImageWithImage:(UIImage *)image addInClass:(BOOL)addInClass success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSInteger errorCode))failure;

@end

NS_ASSUME_NONNULL_END
