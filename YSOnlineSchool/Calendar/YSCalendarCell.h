//
//  DIYCalendarCell.h
//  FSCalendar
//
//  Created by dingwenchao on 02/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar.h"


@interface YSCalendarCell : FSCalendarCell


@property (weak, nonatomic) UILabel *circleLab;

@property (weak, nonatomic) CAShapeLayer *selectionLayer;

@property (strong, nonatomic) NSDictionary  *dateDict;

@end
