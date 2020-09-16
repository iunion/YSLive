//
//  CHBrushToolsConfigs.h
//  CHWhiteBoard
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHBrushToolsConfigs : NSObject

/// 选择类型
@property (nonatomic, assign) CHDrawType drawType;
/// 颜色
@property (nonatomic, strong) NSString *colorHex;
/// 滑动条进度
@property (nonatomic, assign) CGFloat progress;

@end

NS_ASSUME_NONNULL_END
