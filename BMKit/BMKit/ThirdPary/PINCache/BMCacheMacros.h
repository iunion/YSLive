//
//  BMCacheMacros.h
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#ifndef BMCacheMacros_h
#define BMCacheMacros_h

#ifndef BMC_SUBCLASSING_RESTRICTED
#if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#define BMC_SUBCLASSING_RESTRICTED __attribute__((objc_subclassing_restricted))
#else
#define BMC_SUBCLASSING_RESTRICTED
#endif // #if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#endif // #ifndef BMC_SUBCLASSING_RESTRICTED

#ifndef BMC_NOESCAPE
#if defined(__has_attribute) && __has_attribute(noescape)
#define BMC_NOESCAPE __attribute__((noescape))
#else
#define BMC_NOESCAPE
#endif // #if defined(__has_attribute) && __has_attribute(noescape)
#endif // #ifndef BMC_NOESCAPE

#endif /* BMCacheMacros_h */
