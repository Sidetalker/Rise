//
//  ViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 6/20/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize lblLocationCount, locationManager, currentLocation, locationHistory, parseObject, myTimer;
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Loaded");
    NSLog(@"Location Services Enabled: %d", [CLLocationManager locationServicesEnabled]);
    
    // Create the container for locational parse data
    parseObject = [PFObject objectWithClassName:@"Locations"];
    
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
                NSLog(@"Success: authorized to use location services at any time");
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                NSLog(@"Success: authorized to use location services when the app is in use");
                break;
            case kCLAuthorizationStatusDenied:
                NSLog(@"Error: permission to use location services has been denied");
                break;
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"Error: permission to use location services has not yet been provided");
                break;
            case kCLAuthorizationStatusRestricted:
                NSLog(@"Error: permission to use location services has been restricted (parental controls?)");
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

// Start to record location
- (IBAction)btnStartRecord:(id)sender
{
    [locationManager.delegate locationManager:locationManager didUpdateLocations:[[NSArray alloc] init]];
    
    NSLog(@"btnStartRecord Pressed");
    
    // Start the timer
    [myTimer startTimer];
    
    // Start recording locations
    [locationManager startUpdatingLocation];
    
    NSLog(@"Started Recording Location");
}

// Stop recording location
- (IBAction)btnStopRecord:(id)sender
{
    NSLog(@"btnStopRecord Pressed");
    
    // Stop the timer
    [myTimer stopTimer];
    
    // Upload the data to the Parse cloud
    [parseObject saveInBackground];
    
    // Stop recording the location
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Stopped Recording Location");
}

- (IBAction)btnClearRecord:(id)sender
{
    NSLog(@"btnClearRecord Pressed");
    
    // Reinitialize the timer
    myTimer = [[Timer alloc] init];
    
    // Reinitialize the parse object
    parseObject = [PFObject objectWithClassName:@"Locations"];
    
    // Reset location count + update label
    locationCount = 0;
    [lblLocationCount setText:@"Logged Locations: 0"];
    
    NSLog(@"Parse Object + Timer Reinitialized");
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Received Location Update");
    
    // Get the latest location
    currentLocation = [locations lastObject];
    
    // Update the parse container with any new data
    if (currentLocation)
    {
        Location *location = [[Location alloc] initWithLocation:currentLocation andTime:[myTimer timeElapsedInMilliseconds]];
        
        NSLog(@"Created Location Object");
        
        [locationHistory addObject:location];
        
        NSLog(@"Added Location Object to History Array");
         
//        parseObject[[NSString stringWithFormat:@"%d", locationCount]] = location;
//        
//        NSLog(@"Updated Parse Object");
        
        locationCount += 1;
        [lblLocationCount setText:[NSString stringWithFormat:@"Logged Locations: %d", locationCount]];
        
        NSLog(@"Incremented Location Count");
    }
    else
        NSLog(@"No Location Data in Update");
}

- (void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    NSLog(@"Location Manager Error: %@", [error localizedDescription]);
}

@end
