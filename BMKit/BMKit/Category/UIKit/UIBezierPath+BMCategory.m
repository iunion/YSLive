//
//  UIBezierPath+BMCategory.m
//  BMKit
//
//  Created by jiang deng on 2020/12/11.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "UIBezierPath+BMCategory.h"

#define BMCGPointNotFound CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)

@implementation UIBezierPath (BMCategory)

- (CGPoint)bm_center
{
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

@end

@implementation UIBezierPath (BMUtil)

/// returns the dot product of two coordinates
+ (CGFloat)bm_dotProduct:(const CGPoint)p1 p2:(const CGPoint)p2
{
    return p1.x * p2.x + p1.y * p2.y;
}

/// returns the shortest distance from a point to a line
+ (CGFloat)bm_distanceOfPointToLine:(const CGPoint)point lineStart:(const CGPoint)start lineEnd:(const CGPoint)end
{
    CGPoint v = CGPointMake(end.x - start.x, end.y - start.y);
    CGPoint w = CGPointMake(point.x - start.x, point.y - start.y);
    CGFloat c1 = [UIBezierPath bm_dotProduct:w p2:v];
    CGFloat c2 = [UIBezierPath bm_dotProduct:v p2:v];
    CGFloat d;
    if (c1 <= 0)
    {
        d = [UIBezierPath bm_distance:point p2:start];
    }
    else if (c2 <= c1) {
        d = [UIBezierPath bm_distance:point p2:end];
    }
    else
    {
        CGFloat b = c1 / c2;
        CGPoint Pb = CGPointMake(start.x + b * v.x, start.y + b * v.y);
        d = [UIBezierPath bm_distance:point p2:Pb];
    }
    return d;
}

/// returns the distance between two points
+ (CGFloat)bm_distance:(const CGPoint)p1 p2:(const CGPoint)p2
{
    CGFloat length = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
    return length;
}

///  Determines the intersection point of the line A segment defined by points AStart and AEnd
///  with the line B segment defined by points BStart and BEnd.
///
///  Returns YES if the intersection point was found, and stores that point in X,Y.
///  Returns NO if there is no determinable intersection point, in which case X,Y will
///  be unmodified.
+ (CGPoint)bm_lineSegmentIntersectionPointWithLineAStart:(CGPoint)AStart AEnd:(CGPoint)AEnd lineBStart:(CGPoint)BStart BEnd:(CGPoint)BEnd
{
    double distAB, theCos, theSin, newX, ABpos;

    //  Fail if either line segment is zero-length.
    if ((AStart.x == AEnd.x && AStart.y == AEnd.y) || (BStart.x == BEnd.x && BStart.y == BEnd.y))
    {
        return BMCGPointNotFound;
    }

    //  Fail if the segments share an end-point.
    if ((AStart.x == BStart.x && AStart.y == BStart.y) ||
        (AEnd.x == BStart.x && AEnd.y == BStart.y) ||
        (AStart.x == BEnd.x && AStart.y == BEnd.y) ||
        (AEnd.x == BEnd.x && AEnd.y == BEnd.y))
    {
        return BMCGPointNotFound;
    }

    //  (1) Translate the system so that point A is on the origin.
    AEnd.x -= AStart.x;
    AEnd.y -= AStart.y;
    BStart.x -= AStart.x;
    BStart.y -= AStart.y;
    BEnd.x -= AStart.x;
    BEnd.y -= AStart.y;

    //  Discover the length of segment A-B.
    distAB = sqrt(AEnd.x * AEnd.x + AEnd.y * AEnd.y);

    //  (2) Rotate the system so that point B is on the positive X axis.
    theCos = AEnd.x / distAB;
    theSin = AEnd.y / distAB;
    newX = BStart.x * theCos + BStart.y * theSin;
    BStart.y = BStart.y * theCos - BStart.x * theSin;
    BStart.x = newX;
    newX = BEnd.x * theCos + BEnd.y * theSin;
    BEnd.y = BEnd.y * theCos - BEnd.x * theSin;
    BEnd.x = newX;

    //  Fail if segment C-D doesn't cross line A-B.
    if ((BStart.y < 0. && BEnd.y < 0.) || (BStart.y >= 0. && BEnd.y >= 0.))
    {
        return BMCGPointNotFound;
    }

    //  (3) Discover the position of the intersection point along line A-B.
    ABpos = BEnd.x + (BStart.x - BEnd.x) * BEnd.y / (BEnd.y - BStart.y);

    //  Fail if segment C-D crosses line A-B outside of segment A-B.
    if (ABpos < 0. || ABpos > distAB)
    {
        return BMCGPointNotFound;
    }

    //  (4) Apply the discovered position to line A-B in the original coordinate system.
    //  Success.
    return CGPointMake(AStart.x + ABpos * theCos, AStart.y + ABpos * theSin);
}

@end
