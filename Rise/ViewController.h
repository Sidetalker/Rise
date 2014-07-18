//
//  ViewController.h
//  Rise
//
//  Created by Kevin Sullivan on 6/20/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "AppDelegate.h"
#import "Location.h"
#import "Helpers.h"
#import "GRRequestsManager.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, GRRequestsManagerDelegate, UIAlertViewDelegate>

- (IBAction)btnStartRecord:(id)sender;
- (IBAction)btnStopRecord:(id)sender;
- (IBAction)btnClearRecord:(id)sender;
- (IBAction)btnGoogleQuery:(id)sender;
- (IBAction)btnUploadData:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *lblLocationCount;
@property (strong, nonatomic) IBOutlet UITextView *lblLocationData;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (strong, nonatomic) UIAlertView *uploadAlert;
@property (strong, nonatomic) NSString *uploadFilename;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSMutableArray *locationHistory;
@property (strong, nonatomic) PFObject *parseObject;
@property (strong, nonatomic) GRRequestsManager *FTPRequestManager;

@property (nonatomic) int locationCount;
@property (nonatomic) int queryCount;
@property (nonatomic) bool progressUploading;

@end