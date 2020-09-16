//
//  LHDiceAnimationView+Tools.m
//  LHDiceAnimation
//
//  Created by ma c on 2018/6/11.
//  Copyright © 2018年 LIUHAO. All rights reserved.
//

#import "LHDiceAnimationView+Tools.h"

@implementation LHDiceAnimationView (Tools)
#pragma mark - 获取随机数
/**
 return：随机数组
 count:个数
 length:最大数
 */
-(NSMutableArray *)getRandomNumbers:(NSInteger)count length:(uint32_t)length
{
    NSMutableArray *randomNumbers = [NSMutableArray array];
#warning count要小于等于length
    if(count > length)
    {
        return randomNumbers;
    }
    
    for (NSInteger i = 0; i < count; ++i) {
        uint32_t number = arc4random_uniform(length) + 1;
        
        while ([randomNumbers containsObject:[NSNumber numberWithUnsignedInteger:number]]) {
            number = arc4random_uniform(length) + 1;
        }
        [randomNumbers addObject:[NSNumber numberWithUnsignedInteger:number]];
    }
    
    return randomNumbers;
    
}
#pragma mark - 获取随机图片
-(NSMutableArray *)diceAimalImages:(NSUInteger)fourMultiple
{
    NSMutableArray *randImages = [NSMutableArray array];
        
    for (int i = 1; i<=fourMultiple; i++)
    {
        NSString * imageName = [NSString stringWithFormat:@"1_%d.png",i];
        if (i < 10)
        {
            imageName = [NSString stringWithFormat:@"1_0%d.png",i];
        }
        UIImage * image = [UIImage imageNamed:imageName];

        [randImages addObject:image];
    }
    
//    for (int i = 1; i<=fourMultiple; i++)
//    {
//        [randImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"dice_f%d.png",i]]];
//    }
    return randImages;
}

#pragma mark - 获取随机路径
-(NSMutableArray *)diceAnimalPathWithBasePath:(CGPoint)basePoint withPointsCount:(NSUInteger)count withMaxDistance:(uint32_t)maxDistance
{
    BOOL isBigMax = 50 > maxDistance;
    
    maxDistance = isBigMax ? maxDistance : 50;
    
    NSMutableArray *xs = [self getRandomNumbers:count length:maxDistance];
    
    NSMutableArray *ys = [self getRandomNumbers:count length:maxDistance];
    
    NSMutableArray *paths = [NSMutableArray array];
    
    for (NSInteger i = 0; i < count; ++i) {
        BOOL xAdd = arc4random() % 2;
        BOOL yAdd = arc4random() % 2;
        
        CGFloat moveX = [xs[i] floatValue] ;
        CGFloat movey = [ys[i] floatValue];
        CGPoint toPoint = CGPointMake(xAdd ? moveX + basePoint.x : basePoint.x - moveX, yAdd ? movey + basePoint.y : basePoint.y - movey);
        
        [paths addObject:[NSValue valueWithCGPoint:toPoint]];
        [paths addObject:[NSValue valueWithCGPoint:basePoint]];
    }
    
    return paths;
}
@end
