//
//  UIBezierPath+BMCategory.h
//  BMKit
//
//  Created by jiang deng on 2020/12/11.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (BMCategory)

- (UIBezierPath *)bm_cloneEmptyPath;

// returns a point in the center of
// the path's bounds
- (CGPoint)bm_center;

@end

@interface UIBezierPath (BMUtil)

/// returns the shortest distance from a point to a line
+ (CGFloat)bm_distanceOfPointToLine:(const CGPoint)point lineStart:(const CGPoint)start lineEnd:(const CGPoint)end;

/// returns the distance between two points
+ (CGFloat)bm_distance:(const CGPoint)p1 p2:(const CGPoint)p2;

///  Determines the intersection point of the line A segment defined by points AStart and AEnd
///  with the line B segment defined by points BStart and BEnd.
+ (CGPoint)bm_lineSegmentIntersectionPointWithLineAStart:(CGPoint)AStart AEnd:(CGPoint)AEnd lineBStart:(CGPoint)BStart BEnd:(CGPoint)BEnd;

@end

NS_ASSUME_NONNULL_END
