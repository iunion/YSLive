/**
 * Tencent is pleased to support the open source community by making MLeaksFinder available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import "MLeakedObjectProxy.h"
#import "MLeaksFinder.h"
#import "MLeaksMessenger.h"
#import "NSObject+MemoryLeak.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#if _INTERNAL_MLF_RC_ENABLED
#import "FBRetainCycleDetector.h"
#endif

static NSMutableSet *leakedObjectPtrs;

@interface MLeakedObjectProxy ()<UIAlertViewDelegate>
@property (nonatomic, weak) id object;
@property (nonatomic, strong) NSNumber *objectPtr;
@property (nonatomic, strong) NSArray *viewStack;
@end

@implementation MLeakedObjectProxy

+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        leakedObjectPtrs = [[NSMutableSet alloc] init];
    });
    
    if (!ptrs.count)
    {
        return NO;
    }
    if ([leakedObjectPtrs intersectsSet:ptrs])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (void)addLeakedObject:(id)object
{
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    MLeakedObjectProxy *proxy = [[MLeakedObjectProxy alloc] init];
    proxy.object = object;
    proxy.objectPtr = @((uintptr_t)object);
    proxy.viewStack = [object viewStack];
    static const void *const kLeakedObjectProxyKey = &kLeakedObjectProxyKey;
    objc_setAssociatedObject(object, kLeakedObjectProxyKey, proxy, OBJC_ASSOCIATION_RETAIN);
    [leakedObjectPtrs addObject:proxy.objectPtr];
    NSString *string = [NSString stringWithFormat:@"%@\n",object];
    NSString *strFileName = [[[string componentsSeparatedByString:@":"] objectAtIndex:0] substringFromIndex:1];
    NSMutableString *str = [proxy.viewStack componentsJoinedByString:@"."];
    str = [NSString stringWithFormat:@"%@\n",str];
   // NSString *str = [NSString stringWithFormat:@"%@\n",strFileName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/leak.txt",
                          documentsDirectory];
    // check for file exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"leaksClassName: %@",fileName);
    if (![fileManager fileExistsAtPath:fileName])
    {
        // the file doesn't exist,we can write out the text using the  NSString convenience method
        NSError *error = noErr;
        BOOL success = [str writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!success)
        {
            // handle the error
            NSLog(@"%@", error);
        }
        
    }
    else
    {
        
        // the file already exists, append the text to the end
        
        // get a handle
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        
        // move to the end of the file
        [fileHandle seekToEndOfFile];
        
        // convert the string to an NSData object
        NSString *content = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
        if (![content containsString: str])
        {
            NSData *textData = [str dataUsingEncoding:NSUTF8StringEncoding];
            // write the data to the end of the file
            [fileHandle writeData:textData];
        }
        
        // clean up
        [fileHandle closeFile];
    }
       
    [MLeaksMessenger alertWithTitle:@"Memory Leak"
                                message:[NSString stringWithFormat:@"%@", proxy.viewStack]];
}

- (void)dealloc {
    NSNumber *objectPtr = _objectPtr;
    NSArray *viewStack = _viewStack;
    dispatch_async(dispatch_get_main_queue(), ^{
        [leakedObjectPtrs removeObject:objectPtr];
        [MLeaksMessenger alertWithTitle:@"Object Deallocated"
                                message:[NSString stringWithFormat:@"%@", viewStack]];
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) {
        return;
    }
    
    id object = self.object;
    if (!object) {
        return;
    }
    
#if _INTERNAL_MLF_RC_ENABLED
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FBRetainCycleDetector *detector = [FBRetainCycleDetector new];
        [detector addCandidate:self.object];
        NSSet *retainCycles = [detector findRetainCyclesWithMaxCycleLength:20];
        
        BOOL hasFound = NO;
        for (NSArray *retainCycle in retainCycles) {
            NSInteger index = 0;
            for (FBObjectiveCGraphElement *element in retainCycle) {
                if (element.object == object) {
                    NSArray *shiftedRetainCycle = [self shiftArray:retainCycle toIndex:index];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MLeaksMessenger alertWithTitle:@"Retain Cycle"
                                                message:[NSString stringWithFormat:@"%@", shiftedRetainCycle]];
                    });
                    hasFound = YES;
                    break;
                }
                
                ++index;
            }
            if (hasFound) {
                break;
            }
        }
        if (!hasFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MLeaksMessenger alertWithTitle:@"Retain Cycle"
                                        message:@"Fail to find a retain cycle"];
            });
        }
    });
#endif
}

- (NSArray *)shiftArray:(NSArray *)array toIndex:(NSInteger)index {
    if (index == 0) {
        return array;
    }
    
    NSRange range = NSMakeRange(index, array.count - index);
    NSMutableArray *result = [[array subarrayWithRange:range] mutableCopy];
    [result addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, index)]];
    return result;
}

@end
