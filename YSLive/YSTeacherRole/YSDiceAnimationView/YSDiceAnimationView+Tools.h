//
//  LHDiceAnimationView+Tools.h
//  LHDiceAnimation
//
//  Created by ma c on 2018/6/11.
//  Copyright © 2018年 LIUHAO. All rights reserved.
//

#import "YSDiceAnimationView.h"

@interface YSDiceAnimationView (Tools)

- (NSMutableArray *)getRandomNumbers:(NSUInteger)count length:(uint32_t)length;
- (NSMutableArray *)diceAimalImages:(NSUInteger)fourMultiple;
- (NSMutableArray *)diceAnimalPathWithBasePath:(CGPoint)basePoint withPointsCount:(NSUInteger)count withMaxDistance:(uint32_t)maxDistance;

@end
