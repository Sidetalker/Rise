//
//  SettingsTableViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 8/16/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

@synthesize parent, dataSource;

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidLoad];
    
    [dataSource setSelectedSegmentIndex:[parent settings].dataSource];
    DDLogVerbose(@"Setting segment to %ld", [parent settings].dataSource);
    DDLogVerbose(@"Settings says %ld", [[parent settings].settings integerForKey:@"dataSource"]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Orientation Configuration

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (IBAction)dataSourceChanged:(id)sender
{
    NSString *newSource;
    
    switch (dataSource.selectedSegmentIndex) {
        case 0:
            newSource = @"Apple";
            break;
            
        case 1:
            newSource = @"Google";
            break;
            
        case 2:
            newSource = @"Both";
        default:
            break;
    }
    
    DDLogVerbose(@"Changing data source to %@", newSource);
    
    [[parent settings] setDataSource:dataSource.selectedSegmentIndex];
    
    DDLogVerbose(@"Settings dataSource is now %ld", [parent settings].dataSource);
}
@end
