//
//  Settings.h
//  Rise
//
//  Created by Kevin Sullivan on 8/16/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (nonatomic, strong) NSUserDefaults *settings;
@property (nonatomic) NSInteger dataSource;
@property (nonatomic) NSInteger animationType;

- (BOOL)save;
- (void)cancel;
- (void)reload;

@end
