//
//  SettingsTableViewController.h
//  Rise
//
//  Created by Kevin Sullivan on 8/16/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface SettingsTableViewController : UITableViewController

@property (strong, nonatomic) SettingsViewController *parent;

@property (strong, nonatomic) IBOutlet UISegmentedControl *dataSource;

- (IBAction)dataSourceChanged:(id)sender;

@end
