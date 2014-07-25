//
//  MyNavigationController.m
//  Rise
//
//  Created by Kevin Sullivan on 7/24/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

@synthesize forceLandscape;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
//    DDLogVerbose(@"Presented View Controller: %@", [self.presentedViewController class]);
    
    if (self.presentedViewController)
        return [self.presentedViewController shouldAutorotate];
    else
        return [self.topViewController shouldAutorotate];
}
//
- (NSUInteger)supportedInterfaceOrientations
{
    if (self.presentedViewController)
        return [self.presentedViewController supportedInterfaceOrientations];
    else
        return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
