//
//  LongPressControl.h
//  Classroom
//
//  Created by pigpigdaddy on 14-3-24.
//  Copyright (c) 2014年 pigpigdaddy. All rights reserved.
//
//  某些界面上可能会有多个子界面，这些子界面都有自己的拖拽事件，如果你不想让这些拖拽事件先后都触发
//  可以使用本类加以控制

//  2014-04-08 增加区分手势调用

typedef enum {
    LONG_PRESS_VIEW_DEMO = 1,         
}LONG_PRESS_VIEW;

#import <Foundation/Foundation.h>

@interface PanGestureControl : NSObject
{
    NSMutableArray *_arrayPanGestureView;
}

#pragma mark
#pragma mark-------------创建 销毁---------------------
/**   函数名称 :shareInfo
 **   函数作用 :创建 LongPressControl 单例对象
 **   函数参数 :
 **   函数返回值:URLog 单例对象
 **/
+(PanGestureControl *)shareInfo;

/**   函数名称 :freeInfo
 **   函数作用 :释放 LongPressControl 单例对象
 **   函数参数 :
 **   函数返回值:
 **/
+(void)freeInfo;

/*!
 *  TODO:添加拖拽事件
 *
 *  @param view 调用的view
 *
 *  @author pigpigdaddy
 */
- (void)addPanGestureAction:(LONG_PRESS_VIEW)view;

/*!
 *  TODO:删除拖拽事件
 *
 *  @param view 调用的view
 *
 *  @author pigpigdaddy
 */
- (void)removePanGestureAction:(LONG_PRESS_VIEW)view;

/*!
 *  TODO:是否存在拖拽事件
 *
 *  @param view 是那个View
 *
 *  @return
 *
 *  @author pigpigdaddy
 */
- (BOOL)isExistPanGestureAction:(LONG_PRESS_VIEW)view;

@end
