//
//  DIYCalendarCell.m
//  FSCalendar
//
//  Created by dingwenchao on 02/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "YSCalendarCell.h"
#import "FSCalendarExtensions.h"

@implementation YSCalendarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CAShapeLayer *selectionLayer = [[CAShapeLayer alloc] init];
        selectionLayer.fillColor = [UIColor clearColor].CGColor;
        selectionLayer.actions = @{@"hidden":[NSNull null]};
        [self.contentView.layer insertSublayer:selectionLayer below:self.titleLabel.layer];
        self.selectionLayer = selectionLayer;

        self.shapeLayer.hidden = YES;
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        
        UILabel *circleLab = [[UILabel alloc] init];
        [self.contentView insertSubview:circleLab aboveSubview:self.titleLabel];
        circleLab.font = [UIFont systemFontOfSize:14];
        circleLab.textAlignment = NSTextAlignmentCenter;
        circleLab.textColor = UIColor.redColor;
        self.circleLab = circleLab;
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = CGRectInset(self.bounds, 1, 1);
    self.selectionLayer.frame = self.bounds;
    self.selectionLayer.path = [UIBezierPath bezierPathWithRect:self.selectionLayer.bounds].CGPath;
self.circleLab.frame = CGRectMake(0, self.backgroundView.frame.size.height-10, self.backgroundView.frame.size.width, 10);
    [self bringSubviewToFront:self.circleLab];//不起作用
}

- (void)configureAppearance
{
    [super configureAppearance];
    // Override the build-in appearance configuration
    if (self.isPlaceholder) {
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.eventIndicator.hidden = YES;
    }
}

@end
