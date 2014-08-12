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

@interface GraphViewController : UIViewController <CPTAnimationDelegate, CPTPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate>
{
@private
    NSMutableArray *plotDataY;
    NSMutableArray *plotDataX;
    NSMutableArray *plotDataAnimation;
    CPTGraphHostingView *hostView;
    NSTimer *dataTimer;
    
    int startingOrientation;
    int recordCount;
    float maxX;
    float maxY;
    float minY;
    
    // 0 -> Rise linearly from 0
    // 1 -> Flow in from left
    int animationType;
    float animationMod;
    float animationFrameRate;
    float animationTime;
    int animationFrames;
    int animationCount;
}

- (bool)loadData:(NSMutableArray*)data;
- (void)initializePlot;
- (void)configureView;
- (void)redrawAxesWithMinX:(float)minX maxX:(float)maxX minY:(float)minY maxY:(float)maxY;

@end
