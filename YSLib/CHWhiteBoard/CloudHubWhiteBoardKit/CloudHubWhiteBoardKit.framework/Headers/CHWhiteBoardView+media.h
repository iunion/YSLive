//
//  CHWhiteBoardView+media.h
//  CloudHubWhiteBoardKit
//
//  Created by jiang deng on 2020/12/28.
//

#import "CHWhiteBoardView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHWhiteBoardView (media)

/// 是否媒体课件
@property (nonatomic, assign, readonly) BOOL isMediaView;


- (instancetype)initWithFrame:(CGRect)frame whiteboardId:(nullable NSString *)whiteboardId isMediaView:(BOOL)isMediaView whiteBoardConfig:(nullable CloudHubWhiteBoardConfig *)whiteBoardConfig;

/// 设置白板图片url，只加载一次不会重试
- (void)setWhiteBoardImageWithImageDict:(NSDictionary *)imageDict;

/// 移除白板图片
- (void)removeWhiteBoardImage;

/// 切换画笔数据
- (void)switchToFileId:(NSString *)fileId pageNum:(NSUInteger)currentPage updateImmediately:(BOOL)update;

@end

NS_ASSUME_NONNULL_END
