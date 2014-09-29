//
//  Location.m
//  Rise
//
//  Created by Kevin Sullivan on 6/28/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize longitude, latitude, altitudeApple, altitudeGoogle,
accuracyAppleH, accuracyAppleV, resolutionGoogle,
timestampAbsolute, timestampLaunch, googleQueried;

- (id)init
{
    self = [super init];
    
    // Initialize all variables to 0.0
    if (self != nil) {
        longitude = 0.0;
        latitude = 0.0;
        altitudeApple = 0.0;
        altitudeGoogle = 0.0;
        accuracyAppleH = 0.0;
        accuracyAppleV = 0.0;
        resolutionGoogle = 0.0;
        googleQueried = false;
        timestampAbsolute = [NSDate date];
        timestampLaunch = 0.0;
    }
    
    return self;
}

- (id)initWithLocation:(CLLocation*)location
{
    self = [super init];
    
    if (self != nil) {
        longitude = location.coordinate.longitude;
        latitude = location.coordinate.latitude;
        altitudeApple = location.altitude;
        accuracyAppleH = location.horizontalAccuracy;
        accuracyAppleV = location.verticalAccuracy;
        timestampAbsolute = location.timestamp;
        timestampLaunch = [Helpers timeSinceLaunch];
        
        altitudeGoogle = 0.0;
        resolutionGoogle = 0.0;
        googleQueried = false;
    }
    
    return self;
}

- (NSString*)getBasicString
{
    // Return a string with a timestamp and Apple's altitude calculation
    return [NSString stringWithFormat:@"%f: %f meters", timestampLaunch, altitudeApple];
}

- (NSString*)getComplexString
{
    NSMutableString *complex = [NSMutableString stringWithFormat:@"%f:\n\t", timestampLaunch];
    
    [complex appendFormat:@"Long/Lat: %f/%f\n\t\tAccuracy: %f\n\t", longitude, latitude, accuracyAppleH];
    [complex appendFormat:@"Apple Altitude: %f\n\t\tAccuracy: %f\n\t", altitudeApple, accuracyAppleV];
    [complex appendFormat:@"Google Altitude: %f\n\t\tResolution: %f", altitudeGoogle, resolutionGoogle];
    
    // Return a string with lat/long and altitude data along with reported accuracies
    return complex;
}

@end