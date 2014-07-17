//
//  Location.h
//  Rise
//
//  Created by Kevin Sullivan on 6/28/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "AppDelegate.h"
#import "Helpers.h"

@interface Location : NSObject

@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) double altitudeApple;
@property (nonatomic) double altitudeGoogle;
@property (nonatomic) double accuracyAppleH;
@property (nonatomic) double accuracyAppleV;
@property (nonatomic) double resolutionGoogle;
@property (nonatomic) bool googleQueried;
@property (nonatomic) NSDate *timestampAbsolute;
@property (nonatomic) NSTimeInterval timestampLaunch;

- (id)initWithLocation:(CLLocation*)location;

- (NSString*)getBasicString;
- (NSString*)getComplexString;

@end