/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
* (c) Fabrice Aneche
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "UIImage+BMExtendedCacheData.h"
#import <objc/runtime.h>

@implementation UIImage (BMExtendedCacheData)

- (id<NSObject, NSCoding>)bmsd_extendedObject {
    return objc_getAssociatedObject(self, @selector(bmsd_extendedObject));
}

- (void)setBmsd_extendedObject:(id<NSObject, NSCoding>)bmsd_extendedObject {
    objc_setAssociatedObject(self, @selector(bmsd_extendedObject), bmsd_extendedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
