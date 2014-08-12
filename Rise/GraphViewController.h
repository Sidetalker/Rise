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
    NSMutableArray *plotData;
    NSMutableArray *plotDataY;
    NSMutableArray *plotDataX;
    CPTGraphHostingView *hostView;
    NSTimer *dataTimer;
    
    int startingOrientation;
    int recordCount;
    float maxX;
    float maxY;
    float minY;
}

- (bool)loadData:(NSMutableArray*)data;
- (void)initializePlot;
- (void)configureView;
- (void)redrawAxesWithMinX:(float)minX maxX:(float)maxX minY:(float)minY maxY:(float)maxY;

@end
