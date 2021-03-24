/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "BMSDAssociatedObject.h"
#import "UIImage+BMMetadata.h"
#import "UIImage+BMExtendedCacheData.h"
#import "UIImage+BMMemoryCacheCost.h"
#import "UIImage+BMForceDecode.h"

void BMSDImageCopyAssociatedObject(UIImage * _Nullable source, UIImage * _Nullable target) {
    if (!source || !target) {
        return;
    }
    // Image Metadata
    target.bmsd_isIncremental = source.bmsd_isIncremental;
    target.bmsd_imageLoopCount = source.bmsd_imageLoopCount;
    target.bmsd_imageFormat = source.bmsd_imageFormat;
    // Force Decode
    target.bmsd_isDecoded = source.bmsd_isDecoded;
    // Extended Cache Data
    target.bmsd_extendedObject = source.bmsd_extendedObject;
}
