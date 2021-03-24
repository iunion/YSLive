/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "BMSDWebImageDownloaderDecryptor.h"

@interface BMSDWebImageDownloaderDecryptor ()

@property (nonatomic, copy, nonnull) BMSDWebImageDownloaderDecryptorBlock block;

@end

@implementation BMSDWebImageDownloaderDecryptor

- (instancetype)initWithBlock:(BMSDWebImageDownloaderDecryptorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)decryptorWithBlock:(BMSDWebImageDownloaderDecryptorBlock)block {
    BMSDWebImageDownloaderDecryptor *decryptor = [[BMSDWebImageDownloaderDecryptor alloc] initWithBlock:block];
    return decryptor;
}

- (nullable NSData *)decryptedDataWithData:(nonnull NSData *)data response:(nullable NSURLResponse *)response {
    if (!self.block) {
        return nil;
    }
    return self.block(data, response);
}

@end

@implementation BMSDWebImageDownloaderDecryptor (Conveniences)

+ (BMSDWebImageDownloaderDecryptor *)base64Decryptor {
    static BMSDWebImageDownloaderDecryptor *decryptor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decryptor = [BMSDWebImageDownloaderDecryptor decryptorWithBlock:^NSData * _Nullable(NSData * _Nonnull data, NSURLResponse * _Nullable response) {
            NSData *modifiedData = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
            return modifiedData;
        }];
    });
    return decryptor;
}

@end
