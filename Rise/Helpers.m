//
//  Helpers.m
//  Rise
//
//  Created by Kevin Sullivan on 7/10/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers

+ (NSDictionary*) queryGoogleAltitudes:(NSArray*)locations
{
    // Initial Google Elevation API request
    NSMutableString* query = [NSMutableString stringWithString:@"https://maps.googleapis.com/maps/api/elevation/json?locations="];
    
    // Build out the Google query using the lat/long values
    for (Location* location in locations)
    {
        double curLat = [location latitude];
        double curLong = [location longitude];
        
        [query appendFormat:@"%f,%f|", curLat, curLong];
    }
    
    // Remove the trailing pipe
    [query setString:[query substringToIndex:[query length] - 1]];
    
    // Add the API key
    [query appendString:@"&key=AIzaSyBrvkIMLOzECVHduG7_7fg1RlDe0AHmMls"];
    
    DDLogDebug(@"Google Query String: %@", query);
    
    // Generate the request URL
    NSURL* requestURL = [NSURL URLWithString:[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest* request = [NSURLRequest requestWithURL:requestURL];
    
    // Send the request to Google and receive the response TODO: Make asynchronous
    NSError* dataRequestError = nil;
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&dataRequestError];
    
    if (dataRequestError)
        DDLogError(@"Data Request Error: %@", [dataRequestError localizedDescription]);
    
    // Convert the JSON data response to a dictionary object
    NSError* jsonParsingError = nil;
    NSDictionary *locationResults = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    
    if (jsonParsingError)
        DDLogError(@"JSON Parsing Error: %@", [jsonParsingError localizedDescription]);
    
    DDLogVerbose(@"Google API Dictionary:\n%@", locationResults);
    
    return locationResults;
}

+ (NSTimeInterval) timeSinceLaunch
{
    NSDate *launchTime = [(AppDelegate*)[[UIApplication sharedApplication] delegate] launchTime];
    
    return [[NSDate date] timeIntervalSinceDate:launchTime];
}

@end
