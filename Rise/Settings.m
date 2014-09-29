//
//  Settings.m
//  Rise
//
//  Created by Kevin Sullivan on 8/16/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize settings, dataSource;

- (id)init
{
    self = [super init];
    
    settings = [NSUserDefaults standardUserDefaults];
    
    [self reload];
    
    NSLog(@"Settings Initialized (%ld)", [settings integerForKey:@"dataSource"]);
    
    return self;
}

- (void)reload
{
    dataSource = [settings integerForKey:@"dataSource"];
    NSLog(@"Settings Reloaded (%ld)", [settings integerForKey:@"dataSource"]);
    
}

- (void)setDataSource:(NSInteger)newValue
{
    [settings setInteger:newValue forKey:@"dataSource"];
    NSLog(@"Settings Data Source Set (%ld)", newValue);
}

- (BOOL)save
{
    BOOL success = [settings synchronize];
    
    NSLog(@"Settings Synchronized (%ld)", [settings integerForKey:@"dataSource"]);
    
    if (success)
        [self reload];
    else
        return FALSE;
    
    return success;
}

- (void)cancel
{
    [settings setInteger:dataSource forKey:@"dataSource"];
    [self save];
}

@end
