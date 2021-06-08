//
//  LongPressControl.m
//  Classroom
//
//  Created by pigpigdaddy on 14-3-24.
//  Copyright (c) 2014年 pigpigdaddy. All rights reserved.
//

#import "CHPanGestureControl.h"

@implementation CHPanGestureControl

static CHPanGestureControl *_panGestureControl = nil;

#pragma mark
#pragma mark-------------创建 销毁---------------------
/**   函数名称 :shareInfo
 **   函数作用 :创建 LongPressControl 单例对象
 **   函数参数 :
 **   函数返回值:URLog 单例对象
 **/
+ (CHPanGestureControl *)shareInfo
{
    @synchronized(self){
        if (!_panGestureControl)
        {
            _panGestureControl = [[self alloc] init];
        }
    }
    
    return _panGestureControl;
}

/**   函数名称 :freeInfo
 **   函数作用 :释放 LongPressControl 单例对象
 **   函数参数 :
 **   函数返回值:
 **/
+ (void)freeInfo
{
    if (_panGestureControl)
    {
        _panGestureControl = nil;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _arrayPanGestureView = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/*!
 *  TODO:添加拖拽事件
 *
 *  @param view 调用的view
 *
 *  @author pigpigdaddy
 */
- (void)addPanGestureAction:(CHLONG_PRESS_VIEW)view
{
    [_arrayPanGestureView addObject:[NSString stringWithFormat:@"%@", @(view)]];
}

/*!
 *  TODO:删除拖拽事件
 *
 *  @param view 调用的view
 *
 *  @author pigpigdaddy
 */
- (void)removePanGestureAction:(CHLONG_PRESS_VIEW)view
{
    if ([_arrayPanGestureView containsObject:[NSString stringWithFormat:@"%@", @(view)]])
    {
        [_arrayPanGestureView removeObject:[NSString stringWithFormat:@"%@", @(view)]];
    }
}

/*!
 *  TODO:是否存在拖拽事件
 *
 *  @param view 是那个View
 *
 *  @return isExistPan
 *
 *  @author pigpigdaddy
 */
- (BOOL)isExistPanGestureAction:(CHLONG_PRESS_VIEW)view
{
    return [_arrayPanGestureView containsObject:[NSString stringWithFormat:@"%@", @(view)]];
}

@end
