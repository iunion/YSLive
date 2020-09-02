//
//  SCColorListView.m
//  YSLive
//
//  Created by fzxm on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCColorListView.h"

@implementation SCColorListView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint point = [[touches anyObject] locationInView:self];
    if (self.BeganBlock) {
        self.BeganBlock(point);
    }
    
    [super touchesBegan:touches withEvent:event];
}

@end
