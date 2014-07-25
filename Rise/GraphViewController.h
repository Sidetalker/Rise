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

@interface GraphViewController : UIViewController <CPTAnimationDelegate, CPTPlotDataSource, CPTScatterPlotDelegate> {
@private
    NSMutableArray *plotData;
    CPTGraphHostingView *hostView;
//    CPTGraph *graph;
//    CPTScatterPlot *plot;
    NSTimer *dataTimer;
}

//- (void)initializePlot;

@end
