//
//  BMCacheOperationGroup.h
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMCacheOperationMacros.h"
#import "BMCacheOperationTypes.h"

@class BMCacheOperationQueue;

NS_ASSUME_NONNULL_BEGIN

@protocol BMCacheGroupOperationReference;

BMCOP_SUBCLASSING_RESTRICTED
@interface BMCacheOperationGroup : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)asyncOperationGroupWithQueue:(BMCacheOperationQueue *)operationQueue;

- (nullable id <BMCacheGroupOperationReference>)addOperation:(dispatch_block_t)operation;
- (nullable id <BMCacheGroupOperationReference>)addOperation:(dispatch_block_t)operation withPriority:(BMCOperationQueuePriority)priority;
- (void)start;
- (void)cancel;
- (void)setCompletion:(dispatch_block_t)completion;
- (void)waitUntilComplete;

@end

@protocol BMCacheGroupOperationReference <NSObject>

@end

NS_ASSUME_NONNULL_END
