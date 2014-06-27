//
//  ViewController.h
//  Rise
//
//  Created by Kevin Sullivan on 6/20/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "AppDelegate.h"
#import "Timer.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController < CLLocationManagerDelegate >

- (IBAction)btnStartRecord:(id)sender;
- (IBAction)btnStopRecord:(id)sender;
- (IBAction)btnClearRecord:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *lblLocationCount;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) PFObject *parseObject;
@property (strong, nonatomic) Timer *myTimer;

@end

double locationCount;