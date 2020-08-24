/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Laurin Brandner
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+BMGIF.h"
#import "BMSDImageGIFCoder.h"

@implementation UIImage (BMGIF)

+ (nullable UIImage *)bmsd_imageWithGIFData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    return [[BMSDImageGIFCoder sharedCoder] decodedImageWithData:data options:0];
}

@end
