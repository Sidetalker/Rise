//
//  SettingsViewController.h
//  Rise
//
//  Created by Kevin Sullivan on 8/16/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Settings.h"

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) Settings *settings;

- (IBAction)btnSaveClicked:(id)sender;
- (IBAction)btnCancelClicked:(id)sender;

- (void)changeSettingWithName:(NSString*)settingName;

@end
