//
//  GraphViewController.h
//  Rise
//
//  Created by Kevin Sullivan on 7/21/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "Helpers.h"
#import "ViewController.h"
#import "SettingsViewController.h"
#import "Settings.h"

@interface GraphViewController : UIViewController <CPTAnimationDelegate, CPTPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate>
{
@private
    Settings *settings;
    
    NSMutableArray *rawData;
    NSMutableArray *plotDataX;
    NSMutableArray *plotDataY;
    NSMutableArray *plotDataAnimation;
    NSMutableArray *plotDataStrength;
    
    CPTGraphHostingView *hostView;
    NSTimer *animationTimer;
    
    int startingOrientation;
    int recordCount;
    float maxX;
    float maxY;
    float minY;
    
    // 0 -> Rise linearly from 0
    // 1 -> Draw from left
    int animationType;
    float animationMod;
    int animationFrames;
}

- (void)loadData:(NSMutableArray*)data;
- (void)initializePlot;
- (void)configureView;
- (void)redrawAxesWithMinX:(float)minX maxX:(float)maxX minY:(float)minY maxY:(float)maxY;

@end
