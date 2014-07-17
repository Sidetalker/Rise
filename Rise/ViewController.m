//
//  ViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 6/20/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize lblLocationCount, lblLocationData, locationManager, locationHistory,
locationCount, queryCount, currentLocation, parseObject, FTPRequestManager;

#pragma mark - UIView Handlers
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DDLogVerbose(@"Loaded");
    DDLogVerbose(@"Location Services Enabled: %d", [CLLocationManager locationServicesEnabled]);
    
    // Configure our FTP interface
    FTPRequestManager = [[GRRequestsManager alloc] initWithHostname:@"ftp.sideapps.com"
                                                               user:@"rise@sideapps.com"
                                                           password:@"DlFLA?MxeK+t"];
    
    // Allocate space for our location history
    locationHistory = [[NSMutableArray alloc] init];
    
    // Initialize the location manager and set its delegate
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    // Configure the location manager
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDesiredAccuracy:kCLDistanceFilterNone];
    
    // Prompt user for location data authorization (including background use)
    [locationManager requestAlwaysAuthorization];
    
    // Log the authorization status
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways:
                DDLogVerbose(@"Success: authorized to use location services at any time");
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                DDLogVerbose(@"Success: authorized to use location services when the app is in use");
                break;
            case kCLAuthorizationStatusDenied:
                DDLogVerbose(@"Error: permission to use location services has been denied");
                break;
            case kCLAuthorizationStatusNotDetermined:
                DDLogVerbose(@"Error: permission to use location services has not yet been provided");
                break;
            case kCLAuthorizationStatusRestricted:
                DDLogVerbose(@"Error: permission to use location services has been restricted (parental controls?)");
                break;
                
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Retain all resources in an attempt to crash the user's device
}

#pragma mark - Button Handlers

// Start to record location
- (IBAction)btnStartRecord:(id)sender
{
    [locationManager.delegate locationManager:locationManager didUpdateLocations:[[NSArray alloc] init]];
    
    DDLogVerbose(@"btnStartRecord Pressed");
    
    // Start recording locations
    [locationManager startUpdatingLocation];
    
    DDLogVerbose(@"Started Recording Location");
}

// Stop recording location
- (IBAction)btnStopRecord:(id)sender
{
    DDLogVerbose(@"btnStopRecord Pressed");
    
    // Upload the data to the Parse cloud
    [parseObject saveInBackground];
    
    // Stop recording the location
    [locationManager stopUpdatingLocation];
    
    DDLogVerbose(@"Stopped Recording Location");
}

- (IBAction)btnClearRecord:(id)sender
{
    DDLogVerbose(@"btnClearRecord Pressed");
    
    // Reinitialize the parse object
    parseObject = [PFObject objectWithClassName:@"Locations"];
    
    // Reset location data
    locationCount = 0;
    queryCount = 0;
    [lblLocationCount setText:@"Logged Locations: 0"];
    [lblLocationData setText:@""];
    [locationHistory removeAllObjects];
    
    DDLogVerbose(@"Location Data Cleared");
}

- (IBAction)btnGoogleQuery:(id)sender
{
    // Created a subarray with the latest location data
    NSArray* latestLocations = [locationHistory subarrayWithRange:NSMakeRange(locationCount - queryCount, queryCount)];
    
    queryCount = 0;
    
    DDLogVerbose(@"Total Location Count: %lu", (unsigned long)[locationHistory count]);
    DDLogVerbose(@"Google Query Count: %lu", (unsigned long)[latestLocations count]);
    
    // Grab the Google elevation data when requested
    NSDictionary* googleAltitudes = [Helpers queryGoogleAltitudes:latestLocations];
    
    int curLocation = 0;
    
    // Loop through the dictionary and update locations with Google's data
    for (id key in googleAltitudes[@"results"])
    {
        [(Location*)latestLocations[curLocation] setAltitudeGoogle:[key[@"elevation"] floatValue]];
        [(Location*)latestLocations[curLocation] setResolutionGoogle:[key[@"resolution"] floatValue]];
        
        curLocation++;
    }
}

- (IBAction)btnUploadData:(id)sender
{
    // If there are no data points, do nothing
    if ([locationHistory count] == 0)
    {
        DDLogError(@"Upload Data Failed: No data points to upload");
        return;
    }
    
    // Build the string for the text file to be created
    NSMutableString *allData = [[NSMutableString alloc] init];
    
    for (Location *curLoc in locationHistory)
    {
        // Add detailed data for each data point
        [allData appendFormat:@"%@\n\n", [curLoc getComplexString]];
        
        DDLogVerbose([curLoc getComplexString]);
    }
    
    // Generate a text file from the NSString and store it temporarily
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [((Location*)[locationHistory lastObject]).timestampAbsolute description];
    NSString *fullPath = [NSString stringWithFormat:@"%@/temp/%@.txt", documentsDirectory, fileName];
    
    // Write the file to memory
    NSError *writeError = nil;
    [allData writeToFile:fullPath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&writeError];
    
    // Check for an error
    if (writeError)
    {
        DDLogError(@"File Write Error: Unable to write location data to temporary file\n\t%@", [writeError localizedDescription]);
        return;
    }
    
    // Upload to SideApps to use for algorithm design
    [FTPRequestManager addRequestForUploadFileAtLocalPath:fullPath toRemotePath:fileName];
    [FTPRequestManager startProcessingRequests];
    
}

#pragma mark - CLLocationManager Delegate Functions

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    DDLogVerbose(@"Received Location Update");
    
    // Get the latest location
    currentLocation = [locations lastObject];
    
    // Store the location and display it in the scrolling textBox
    if (currentLocation)
    {
        // Initialize a Location object with the latest location
        Location *location = [[Location alloc] initWithLocation:currentLocation];
        
        DDLogVerbose(@"Created Location Object");
        
        // Add the Location object to the history array
        [locationHistory addObject:location];
        
        DDLogVerbose(@"Added Location Object to History Array");
        DDLogVerbose(@"Total Location Count is now %lu", [locationHistory count]);
        
        // Increment counters
        locationCount += 1;
        queryCount += 1;
        
        // Update the textBox and scroll to the bottom
        [lblLocationCount setText:[NSString stringWithFormat:@"Logged Locations: %d", locationCount]];
        [lblLocationData setText:[NSString stringWithFormat:@"%@\n%@", [lblLocationData text], [location getBasicString]]];
        [lblLocationData scrollRangeToVisible:NSMakeRange([lblLocationData.text length], 0)];
        
        DDLogVerbose(@"Updated Labels and Counts");
    }
    else
        DDLogVerbose(@"No Location Data in Update");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DDLogError(@"Location Manager Error: %@", [error localizedDescription]);
}

#pragma mark - GRRequestsManager Delegate Functions

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didScheduleRequest:(id<GRRequestProtocol>)request
{
    DDLogVerbose(@"requestsManager:didScheduleRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing
{
    DDLogVerbose(@"requestsManager:didCompleteListingRequest:listing: \n%@", listing);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteCreateDirectoryRequest:(id<GRRequestProtocol>)request
{
    DDLogVerbose(@"requestsManager:didCompleteCreateDirectoryRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDeleteRequest:(id<GRRequestProtocol>)request
{
    DDLogVerbose(@"requestsManager:didCompleteDeleteRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompletePercent:(float)percent forRequest:(id<GRRequestProtocol>)request
{
    DDLogVerbose(@"requestsManager:didCompletePercent:forRequest: %f", percent);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    DDLogVerbose(@"requestsManager:didCompleteUploadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    DDLogVerbose(@"requestsManager:didCompleteDownloadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailWritingFileAtPath:(NSString *)path forRequest:(id<GRDataExchangeRequestProtocol>)request error:(NSError *)error
{
    DDLogVerbose(@"requestsManager:didFailWritingFileAtPath:forRequest:error: \n %@", error);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    DDLogVerbose(@"requestsManager:didFailRequest:withError: \n %@", error);
}

@end
