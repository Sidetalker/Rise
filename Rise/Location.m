//
//  Location.m
//  Rise
//
//  Created by Kevin Sullivan on 6/28/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize altitude, longitude, latitude, accuracyH, accuracyV, timestamp;

- (id)init
{
    self = [super init];
    if (self != nil) {
        altitude = 0.0;
        longitude = 0.0;
        latitude = 0.0;
        accuracyH = 0.0;
        accuracyV = 0.0;
        timestamp = 0.0;
    }
    return self;
}

- (id)initWithLocation:(CLLocation*)providedLocation andTime:(double)time
{
    self = [super init];
    if (self != nil) {
        altitude = providedLocation.altitude;
        longitude = providedLocation.coordinate.longitude;
        latitude = providedLocation.coordinate.latitude;
        accuracyH = providedLocation.horizontalAccuracy;
        accuracyV = providedLocation.verticalAccuracy;
        timestamp = time;
    }
    return self;
}

@end