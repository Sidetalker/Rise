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

@synthesize parent, dataSource, animationType;

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidLoad];
    
    [[parent settings] reload];
    [dataSource setSelectedSegmentIndex:[parent settings].dataSource];
    [animationType setSelectedSegmentIndex:[parent settings].animationType];
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
    
    [[parent settings] setDataSource:dataSource.selectedSegmentIndex];
}

- (IBAction)animationTypeChanged:(id)sender {
    NSString *newSource;
    
    switch (animationType.selectedSegmentIndex) {
        case 0:
            newSource = @"Rise";
            break;
            
        case 1:
            newSource = @"Draw";
            break;
            
        case 2:
            newSource = @"None";
        default:
            break;
    }
    
    [[parent settings] setAnimationType:animationType.selectedSegmentIndex];
}
@end
