/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "BMSDmetamacros.h"

#ifndef BMSD_LOCK
#define BMSD_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef BMSD_UNLOCK
#define BMSD_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

#ifndef BMSD_OPTIONS_CONTAINS
#define BMSD_OPTIONS_CONTAINS(options, value) (((options) & (value)) == (value))
#endif

#ifndef BMSD_CSTRING
#define BMSD_CSTRING(str) #str
#endif

#ifndef BMSD_NSSTRING
#define BMSD_NSSTRING(str) @(BMSD_CSTRING(str))
#endif

#ifndef BMSD_SEL_SPI
#define BMSD_SEL_SPI(name) NSSelectorFromString([NSString stringWithFormat:@"_%@", BMSD_NSSTRING(name)])
#endif

#ifndef bmweakify
#define bmweakify(...) \
bmsd_keywordify \
bmmetamacro_foreach_cxt(bmsd_weakify_,, __weak, __VA_ARGS__)
#endif

#ifndef bmstrongify
#define bmstrongify(...) \
bmsd_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
bmmetamacro_foreach(bmsd_strongify_,, __VA_ARGS__) \
_Pragma("clang diagnostic pop")
#endif

#define bmsd_weakify_(INDEX, CONTEXT, VAR) \
CONTEXT __typeof__(VAR) bmmetamacro_concat(VAR, _weak_) = (VAR);

#define bmsd_strongify_(INDEX, VAR) \
__strong __typeof__(VAR) VAR = bmmetamacro_concat(VAR, _weak_);

#if DEBUG
#define bmsd_keywordify autoreleasepool {}
#else
#define bmsd_keywordify try {} @catch (...) {}
#endif

#ifndef bmonExit
#define bmonExit \
bmsd_keywordify \
__strong bmsd_cleanupBlock_t bmmetamacro_concat(bmsd_exitBlock_, __LINE__) __attribute__((cleanup(bmsd_executeCleanupBlock), unused)) = ^
#endif

typedef void (^bmsd_cleanupBlock_t)(void);

#if defined(__cplusplus)
extern "C" {
#endif
    void bmsd_executeCleanupBlock (__strong bmsd_cleanupBlock_t *block);
#if defined(__cplusplus)
}
#endif
