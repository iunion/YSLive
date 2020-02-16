//
//  DIYCalendarCell.m
//  FSCalendar
//
//  Created by dingwenchao on 02/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//


#import "YSCalendarCell.h"
#import "FSCalendarExtensions.h"

@interface YSCalendarCell()

@property (weak, nonatomic) UIView *lineView;

@end


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
        
        UILabel *circleLab = [[UILabel alloc] init];
        [self.contentView insertSubview:circleLab aboveSubview:self.titleLabel];
        circleLab.font = [UIFont systemFontOfSize:11];
        circleLab.textAlignment = NSTextAlignmentCenter;
        circleLab.textColor = UIColor.grayColor;
        self.circleLab = circleLab;
        
        UIView * lineView= [[UIView alloc]initWithFrame:CGRectMake(0, self.bm_height-1, self.bm_width, 1)];
        lineView.backgroundColor = [UIColor bm_colorWithHex:0x6D7278];
        [self.contentView addSubview:lineView];
        self.lineView = lineView;
    }
    return self;
}
- (void)setDateDict:(NSDictionary *)dateDict
{
    _dateDict = dateDict;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = CGRectInset(self.bounds, 1, 1);
    self.selectionLayer.frame = CGRectMake(0, 0, self.bm_width-20, self.bm_height-20) ;
    self.selectionLayer.path = [UIBezierPath bezierPathWithRect:self.selectionLayer.bounds].CGPath;
    self.circleLab.frame = CGRectMake(0, self.bm_height-20, self.backgroundView.frame.size.width, 20);
    
    if ([self.dateDict bm_isNotEmpty]) {
        self.circleLab.hidden = NO;
        self.selectionLayer.hidden = NO;
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString * nowDateStr = [dateFormatter stringFromDate:currentDate];
        NSDate * nowDate = [dateFormatter dateFromString:nowDateStr];
        NSString * key = self.dateDict.allKeys.firstObject;
        
        NSDate * dateKey = [dateFormatter dateFromString:key];
        self.titleLabel.textColor = UIColor.whiteColor;
//        self.appearance.selectionColor = UIColor.whiteColor;
        
        //日期比较
        NSComparisonResult result = [dateKey compare:nowDate];
        if (result == -1)
        {//之前
            self.selectionLayer.fillColor = [UIColor bm_colorWithHex:0xA2A2A2].CGColor;
        }
        else if (result == 1)
        {//以后
            self.selectionLayer.fillColor = [UIColor bm_colorWithHex:0xFF9E00].CGColor;
        }
        else
        {//今天
            self.selectionLayer.fillColor = [UIColor bm_colorWithHex:0x5A8CDC].CGColor;
        }
        CGFloat diameter = MIN(self.selectionLayer.fs_height, self.selectionLayer.fs_width);
        self.selectionLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.contentView.fs_width/2-diameter/2, 0, diameter, diameter)].CGPath;
        if ([self.dateDict bm_uintForKey:key] >0) {
            self.circleLab.hidden = NO;
            self.circleLab.text = [NSString stringWithFormat:@"共%@节",[self.dateDict bm_stringForKey:key]];
        }
        else
        {
            self.circleLab.hidden = YES;
        }
    }
    else
    {
        self.titleLabel.textColor = UIColor.grayColor;
//        self.appearance.selectionColor = UIColor.whiteColor;
        self.circleLab.hidden = YES;
        self.selectionLayer.hidden = YES;
    }
}

@end
