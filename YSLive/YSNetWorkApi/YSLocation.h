//
//  YSLocation.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOCATION_BEIJING @"北京"

NS_ASSUME_NONNULL_BEGIN

@interface YSLocation : NSObject

+ (void)setGPSLoaction:(CLLocation *)gps;
+ (CLLocation *)GPSLoaction;
+ (CLLocationDegrees)userLocationLongitude;
+ (CLLocationDegrees)userLocationLatitude;

+ (double)distanceToLocationLa:(double)la Lo:(double)lo;
+ (double)distanceToLocation:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
