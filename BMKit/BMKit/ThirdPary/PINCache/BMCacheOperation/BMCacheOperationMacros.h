//
//  BMCacheOperationMacros.h
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#ifndef BMCacheOperationMacros_h
#define BMCacheOperationMacros_h

#ifndef BMCOP_SUBCLASSING_RESTRICTED
#if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#define BMCOP_SUBCLASSING_RESTRICTED __attribute__((objc_subclassing_restricted))
#else
#define BMCOP_SUBCLASSING_RESTRICTED
#endif // #if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#endif // #ifndef BMCOP_SUBCLASSING_RESTRICTED


#endif /* BMCacheOperationMacros_h */
