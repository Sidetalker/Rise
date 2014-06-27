//
//  ViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 6/20/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize lblLocationCount, locationManager, currentLocation, parseObject, myTimer;
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the location manager and set its delegate
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    // Obtain the best possible accuracy
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Create the container for locational parse data
    parseObject = [PFObject objectWithClassName:@"Locations"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Retain all resources in an attempt to crash the user's device
}

// Start to record location
- (IBAction)btnStartRecord:(id)sender
{
    NSLog(@"btnStartRecord Pressed");
    
    // Reset and start the timer
    myTimer = [[Timer alloc] init];
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
    
    NSLog(@"Parse Object + Timer Reinitialized");
}

- (void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Received Location Update");
    
    // Update the parse container with the new data
    parseObject[[NSString stringWithFormat:@"%f", [myTimer timeElapsedInMilliseconds]]] = newLocation;
    
    NSLog(@"Updated Parse Object");
    
    // Increment the location counter
    locationCount += 1;
    [lblLocationCount setText:[NSString stringWithFormat:@"%f", [myTimer timeElapsedInMilliseconds]]];
    
    NSLog(@"Incremented Location Count");
}
@end
