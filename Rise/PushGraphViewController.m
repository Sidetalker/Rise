//
//  PushGraphViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 7/29/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "PushGraphViewController.h"

@interface PushGraphViewController ()

@end

@implementation PushGraphViewController

@synthesize startingOrientation;

- (void)viewWillAppear:(BOOL) animated
{
    //    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(receivedRotate:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    //    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    
    self.startingOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    DDLogDebug(@"orientation: %d", self.startingOrientation);
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    
//    if ((startingOrientation == UIInterfaceOrientationPortrait) ||
//        (startingOrientation == UIInterfaceOrientationLandscapeLeft))
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
//    else if ((startingOrientation == UIInterfaceOrientationPortraitUpsideDown) ||
//             (startingOrientation == UIInterfaceOrientationLandscapeRight))
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];

//    [self initializePlot];
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [self.view addSubview:button];
//    [button setTitle:@"Press Me" forState:UIControlStateNormal];
//    [button sizeToFit];
//    [button addTarget: self
//               action: @selector(buttonClicked:)
//     forControlEvents: UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
}

@end
