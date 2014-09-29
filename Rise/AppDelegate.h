//
//  AppDelegate.h
//  Rise
//
//  Created by Kevin Sullivan on 6/20/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CorePlot/CorePlot-CocoaTouch.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#import "MyNavigationController.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSDate *launchTime;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

