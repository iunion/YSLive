//
//  NSMutableArray+BMCategory.m
//  BMBasekit
//
//  Created by DennisDeng on 2017/5/19.
//  Copyright © 2016年 DennisDeng. All rights reserved.
//

#import "NSMutableArray+BMCategory.h"
#import "NSObject+BMCategory.h"

@implementation NSMutableArray (BMCategory)

- (void)bm_moveObjectToFirst:(NSUInteger)index
{
    if (index == 0)
    {
        return;
    }
    if (index >= self.count)
    {
        return;
    }
    
    id object = [self objectAtIndex:index];
    [self removeObject:object];
    [self insertObject:object atIndex:0];
}

- (void)bm_moveObjectToLast:(NSUInteger)index
{
    if (index == 0)
    {
        return;
    }
    if (index >= self.count)
    {
        return;
    }
    
    id object = [self objectAtIndex:index];
    [self removeObject:object];
    [self addObject:object];
}

- (void)bm_exchangeObjectFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex
{
    if (oldIndex == newIndex)
    {
        return;
    }
    
    if (oldIndex >= self.count || newIndex >= self.count)
    {
        return;
    }
    
    [self exchangeObjectAtIndex:newIndex withObjectAtIndex:oldIndex];
}

- (NSMutableArray *)bm_removeFirstObject
{
    if (self.count)
    {
        [self removeObjectAtIndex:0];
    }
    
    return self;
}

- (BOOL)bm_addObject:(id)anObject withMaxCount:(NSUInteger)maxCount
{
    if (![anObject bm_isNotEmpty])
    {
        return NO;
    }
    
    if (self.count < maxCount)
    {
        [self addObject:anObject];
        return YES;
    }
    return NO;
}

- (NSUInteger)bm_addObjects:(NSArray *)array withMaxCount:(NSUInteger)maxCount
{
    NSUInteger count = 0;
    for (id anObject in array)
    {
        if ([self bm_addObject:anObject withMaxCount:maxCount])
        {
            count++;
        }
        else
        {
            break;
        }
    }
    
    return count;
}

- (void)bm_insertArray:(NSArray *)array atIndex:(NSUInteger)index
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(index, [array count])];
    [self insertObjects:array atIndexes:indexes];
}

- (NSUInteger)bm_replaceObject:(id)objectToReplace withObject:(id)object
{
    NSUInteger index = [self indexOfObject:objectToReplace];
    if (index != NSNotFound)
    {
        [self replaceObjectAtIndex:index withObject:object];
    }
    
    return index;
}

- (void)bm_shuffle
{
    for (NSInteger i = (NSInteger)[self count] - 1; i > 0; i--)
    {
        NSUInteger j = (NSUInteger)arc4random_uniform((uint32_t)i + 1);
        [self exchangeObjectAtIndex:j withObjectAtIndex:(NSUInteger)i];
    }
}

@end


@implementation NSMutableArray (UIValue)

- (void)bm_addPoint:(CGPoint)point
{
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    [self addObject:pointValue];
}

- (void)bm_addSize:(CGSize)size
{
    NSValue *sizeValue = [NSValue valueWithCGSize:size];
    [self addObject:sizeValue];
}

- (void)bm_addRect:(CGRect)rect
{
    NSValue *rectValue = [NSValue valueWithCGRect:rect];
    [self addObject:rectValue];
}

@end
