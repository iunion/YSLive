//
//  SCColorListView.m
//  YSLive
//
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
