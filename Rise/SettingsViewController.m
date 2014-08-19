//
//  SettingsViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 8/16/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize settings;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings = [[Settings alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

// Portrait orientation only - landscape config will be done in a subview
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"settingsTableSegue"])
    {
        SettingsTableViewController *settingsTable = (SettingsTableViewController*)[segue destinationViewController];
        settingsTable.parent = self;
    }
}

- (void)changeSettingWithName:(NSString*)settingName
{
    
}

- (IBAction)btnSaveClicked:(id)sender
{
    [settings save];
    [self presentingViewController] 
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnCancelClicked:(id)sender
{
    [settings cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
