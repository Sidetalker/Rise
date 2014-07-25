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

//- (BOOL)shouldAutorotate
//{
////    id currentViewController = self.topViewController;
//    
//    return YES;
//}

//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    if (self.isLandscapeOK) {
//        // for iPhone, you could also return UIInterfaceOrientationMaskAllButUpsideDown
//        return UIInterfaceOrientationMaskAll;
//    }
//    return UIInterfaceOrientationMaskPortrait;
//}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (!forceLandscape) {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskLandscapeLeft;
}

@end
