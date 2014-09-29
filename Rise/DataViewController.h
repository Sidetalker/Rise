//
//  DataViewController.h
//  Rise
//
//  Created by Kevin Sullivan on 7/18/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface DataViewController : UIViewController <UIWebViewDelegate>

- (IBAction)btnTextOrCSV:(id)sender;
- (IBAction)btnShare:(id)sender;

- (void)loadText;
- (void)loadCSV;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSURL *currentURL;

@property (nonatomic) bool isLoading;

@end
