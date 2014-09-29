//
//  Helpers.h
//  Rise
//
//  Created by Kevin Sullivan on 7/10/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "Location.h"

@interface Helpers : NSObject

+ (NSDictionary*) queryGoogleAltitudes:(NSArray*)locations;

+ (CPTGraph *)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;
+ (CPTGraph *)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;

+ (NSTimeInterval) timeSinceLaunch;
+ (NSString*) sanitizeFileNameString:(NSString *)fileName;
+ (NSURL *) applicationDocumentsDirectory;

@end
