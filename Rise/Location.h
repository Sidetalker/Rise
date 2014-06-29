//
//  Location.h
//  Rise
//
//  Created by Kevin Sullivan on 6/28/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject

@property (nonatomic) double altitude;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) double accuracyH;
@property (nonatomic) double accuracyV;
@property (nonatomic) double timestamp;

- (id)initWithLocation:(CLLocation*)providedLocation andTime:(double)time;

@end







//// Get lat/long and altitude
//NSNumber *currentAltitude = [NSNumber numberWithDouble:currentLocation.altitude];
//NSNumber *currentLat = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
//NSNumber *currentLong = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
//NSNumber *accuracyH = [NSNumber numberWithDouble:currentLocation.horizontalAccuracy];
//NSNumber *accuracyV = [NSNumber numberWithDouble:currentLocation.verticalAccuracy];
//
//// Save data to dictionary
//
//
//// Add data to the parse object
//parseObject[[NSString stringWithFormat:@"Time: %f", floor([myTimer timeElapsedInMilliseconds])]] = [NSArray arrayWithObjects:currentAltitude, currentLat, currentLong, accuracyH, accuracyV, nil];
//
//
////
////  Timer.h
////  Rise
////
////  Created by Kevin Sullivan on 6/26/14.
////  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//
//@interface Timer : NSObject {
//    NSDate *start;
//    NSDate *end;
//}
//
//- (void) startTimer;
//- (void) stopTimer;
//- (double) timeElapsedInSeconds;
//- (double) timeElapsedInMilliseconds;
//- (double) timeElapsedInMinutes;
//