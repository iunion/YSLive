//
//  NSData+BMCompress.h
//  BMKit
//
//  Created by jiang deng on 2021/7/12.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (BMCompress)

#pragma mark - gzip

/// 是否数据经过gzip编码
- (BOOL)bm_isGzippedData;

/// 默认压缩级别。0.7
- (nullable NSData *)bm_gzippedDefault;
/// 此方法将应用gzip deflate算法并返回压缩数据。 压缩级别是介于0.0和1.0之间的浮点值，其中0.0表示无压缩，而1.0表示最大压缩。 值0.1将提供最快的压缩率。 如果提供负值，这将应用默认的压缩级别，该值大约等于0.7。
/// @param level 0.0 ~ 1.0
- (nullable NSData *)bm_gzippedDataWithCompressionLevel:(float)level;

/// 此方法将解压缩使用deflate算法压缩的数据并返回结果。
- (nullable NSData *)bm_gunzippedData;


#pragma mark - zlib

/// 是否数据经过zlib编码
- (BOOL)bm_isZlibbedData;

/// 以默认压缩级别将数据压缩为zlib压缩。
- (nullable NSData *)bm_zlibbedDefault;
/// 此方法将应用zlib deflate算法并返回压缩数据。
/// @param level 压缩级别
- (nullable NSData *)bm_zlibbedDataWithCompressionLevel:(float)level;

/// 从zlib压缩的数据中解压缩数据。
- (nullable NSData *)bm_unzlibbedData;

@end

NS_ASSUME_NONNULL_END
