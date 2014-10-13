//
//  Settings.m
//  Rise
//
//  Created by Kevin Sullivan on 8/16/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize settings, dataSource, animationType;

- (id)init
{
    self = [super init];
    
    settings = [NSUserDefaults standardUserDefaults];
    
    [self reload];
    
    return self;
}

- (void)reload
{
    dataSource = [settings integerForKey:@"dataSource"];
    animationType = [settings integerForKey:@"animationType"];
}

- (void)setDataSource:(NSInteger)newValue
{
    [settings setInteger:newValue forKey:@"dataSource"];
}

- (void)setAnimationType:(NSInteger)animationType
{
    
    [settings setInteger:animationType forKey:@"animationType"];
}

- (BOOL)save
{
    BOOL success = [settings synchronize];
    
    if (success)
        [self reload];
    else
        return FALSE;
    
    return success;
}

- (void)cancel
{
    [settings setInteger:dataSource forKey:@"dataSource"];
    [settings setInteger:animationType forKey:@"animationType"];
    [self save];
}

@end
