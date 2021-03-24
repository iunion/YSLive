/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageCompat.h"

@class BMSDAsyncBlockOperation;
typedef void (^BMSDAsyncBlock)(BMSDAsyncBlockOperation * __nonnull asyncOperation);

/// A async block operation, success after you call `completer` (not like `NSBlockOperation` which is for sync block, success on return)
@interface BMSDAsyncBlockOperation : NSOperation

- (nonnull instancetype)initWithBlock:(nonnull BMSDAsyncBlock)block;
+ (nonnull instancetype)blockOperationWithBlock:(nonnull BMSDAsyncBlock)block;
- (void)complete;

@end
