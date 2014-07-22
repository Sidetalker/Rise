//
//  GraphViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 7/21/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()

@end

@implementation GraphViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}







//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
//    hostView.allowPinchScaling = YES;
//    
//    graph = [[CPTXYGraph alloc] initWithFrame: hostView.bounds];
//    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
//    hostView.hostedGraph = graph;
//    graph.paddingLeft = 20.0;
//    graph.paddingTop = 20.0;
//    graph.paddingRight = 20.0;
//    graph.paddingBottom = 20.0;
//    
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
//    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-6)
//                                                   length:CPTDecimalFromFloat(12)];
//    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-5)
//                                                   length:CPTDecimalFromFloat(30)];
//    
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
//    
//    CPTMutableLineStyle *lineStyle = [CPTLineStyle lineStyle];
//    lineStyle.lineColor = [CPTColor blackColor];
//    lineStyle.lineWidth = 2.0f;
//    
////    axisSet.xAxis.majorIntervalLength = @"5";
//    axisSet.xAxis.minorTicksPerInterval = 4;
//    axisSet.xAxis.majorTickLineStyle = lineStyle;
//    axisSet.xAxis.minorTickLineStyle = lineStyle;
//    axisSet.xAxis.axisLineStyle = lineStyle;
//    axisSet.xAxis.minorTickLength = 5.0f;
//    axisSet.xAxis.majorTickLength = 7.0f;
//    
////    axisSet.yAxis.majorIntervalLength = [NSDecimalNumber init:@"5"];
//    axisSet.yAxis.minorTicksPerInterval = 4;
//    axisSet.yAxis.majorTickLineStyle = lineStyle;
//    axisSet.yAxis.minorTickLineStyle = lineStyle;
//    axisSet.yAxis.axisLineStyle = lineStyle;
//    axisSet.yAxis.minorTickLength = 5.0f;
//    axisSet.yAxis.majorTickLength = 7.0f;
//    
//    CPTScatterPlot *xSquaredPlot = [[CPTScatterPlot alloc]
//                                    initWithFrame:graph.bounds];
//    xSquaredPlot.identifier = @"X Squared Plot";
//    CPTMutableLineStyle *styleA = [[CPTMutableLineStyle alloc] init];
//    styleA.lineWidth = 1.0f;
//    styleA.lineColor = [CPTColor redColor];
//    xSquaredPlot.dataLineStyle = styleA;
////    xSquaredPlot.dataLineStyle.lineWidth = 1.0f;
////    xSquaredPlot.dataLineStyle.lineColor = [CPTColor redColor];
//    xSquaredPlot.dataSource = self;
//    [graph addPlot:xSquaredPlot];
//    
//    CPTPlotSymbol *greenCirclePlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    greenCirclePlotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
//    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
//    xSquaredPlot.plotSymbol = greenCirclePlotSymbol;
//    
//    CPTScatterPlot *xInversePlot = [[CPTScatterPlot alloc]
//                                    initWithFrame:graph.bounds];
//    xInversePlot.identifier = @"X Inverse Plot";
////    xInversePlot.dataLineStyle.lineWidth = 1.0f;
////    xInversePlot.dataLineStyle.lineColor = [CPColor blueColor];
//    xInversePlot.dataSource = self;
//    [graph addPlot:xInversePlot];
//    [self.view addSubview:hostView];
//}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 51;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    double val = (index/5.0)-5;
    if(fieldEnum == CPTScatterPlotFieldX)
    { return [NSNumber numberWithDouble:val]; }
    else
    { 
        if([plot.identifier  isEqual: @"APPL"])
        { return [NSNumber numberWithDouble:val*val]; }
        else
        { return [NSNumber numberWithDouble:1/val]; }
    }
}





- (IBAction) buttonClicked: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(BOOL)prefersStatusBarHidden { return YES; }


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializePlot];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button];
    [button setTitle:@"Press Me" forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget: self
              action: @selector(buttonClicked:)
    forControlEvents: UIControlEventTouchUpInside];
    
    
    // Do any additional setup after loading the view.

//    // 1 - Set up view frame
//    CGRect parentRect = self.view.bounds;
//    CGSize toolbarSize = self.toolbar.bounds.size;
//    parentRect = CGRectMake(parentRect.origin.x,
//                            (parentRect.origin.y + toolbarSize.height),
//                            parentRect.size.width,
//                            (parentRect.size.height - toolbarSize.height));
//    // 2 - Create host view
//    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
//    self.hostView.allowPinchScaling = NO;
//    [self.view addSubview:self.hostView];
    
//    // Create the graph host view and add it to our main view
//    hostView = [[CPTGraphHostingView alloc] init];
//    [self.view addSubview:hostView];
//    
//    // Create and initialize graph
//    graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
//    hostView.hostedGraph = graph;
//    graph.paddingLeft = 0.0f;
//    graph.paddingTop = 0.0f;
//    graph.paddingRight = 0.0f;
//    graph.paddingBottom = 0.0f;
//    graph.axisSet = nil;
//
//    // Set up text style
//    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
//    textStyle.color = [CPTColor grayColor];
//    textStyle.fontName = @"Helvetica-Bold";
//    textStyle.fontSize = 16.0f;
//
////    // Configure title
////    NSString *title = @"Test";
////    graph.title = title;
////    graph.titleTextStyle = textStyle;
////    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
////    graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
////
////    // Set theme
////    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
////    
//    // Create the plot
//    plot = [[CPTScatterPlot alloc] init];
//    plot.identifier     = @"Altitude Plot";
//    plot.cachePrecision = CPTPlotCachePrecisionDouble;
//    
//    CPTMutableLineStyle *lineStyle = [plot.dataLineStyle mutableCopy];
//    lineStyle.lineWidth              = 0.5;
//    lineStyle.lineColor              = [CPTColor greenColor];
//    plot.dataLineStyle = lineStyle;
//    
//    plot.dataSource = self;
//    [graph addPlot:plot];
//    
//    // Start adding the data using the timer
//    dataTimer = [NSTimer timerWithTimeInterval:1.0 / 60.0
//                                        target:self
//                                      selector:@selector(newData:)
//                                      userInfo:nil
//                                       repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

- (void)initializePlot
{
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    hostView.allowPinchScaling = YES;
    [self.view addSubview:hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Portfolio Prices: April 2012";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = @"APPL";
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];
    CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];
    googPlot.dataSource = self;
    googPlot.identifier = @"GOOG";
    CPTColor *googColor = [CPTColor greenColor];
    [graph addPlot:googPlot toPlotSpace:plotSpace];
    CPTScatterPlot *msftPlot = [[CPTScatterPlot alloc] init];
    msftPlot.dataSource = self;
    msftPlot.identifier = @"MSFT";
    CPTColor *msftColor = [CPTColor blueColor];
    [graph addPlot:msftPlot toPlotSpace:plotSpace];
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, googPlot, msftPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 2.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
    aaplPlot.plotSymbol = aaplSymbol;
    CPTMutableLineStyle *googLineStyle = [googPlot.dataLineStyle mutableCopy];
    googLineStyle.lineWidth = 1.0;
    googLineStyle.lineColor = googColor;
    googPlot.dataLineStyle = googLineStyle;
    CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    googSymbolLineStyle.lineColor = googColor;
    CPTPlotSymbol *googSymbol = [CPTPlotSymbol starPlotSymbol];
    googSymbol.fill = [CPTFill fillWithColor:googColor];
    googSymbol.lineStyle = googSymbolLineStyle;
    googSymbol.size = CGSizeMake(6.0f, 6.0f);
    googPlot.plotSymbol = googSymbol;
    CPTMutableLineStyle *msftLineStyle = [msftPlot.dataLineStyle mutableCopy];
    msftLineStyle.lineWidth = 2.0;
    msftLineStyle.lineColor = msftColor;
    msftPlot.dataLineStyle = msftLineStyle;
    CPTMutableLineStyle *msftSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    msftSymbolLineStyle.lineColor = msftColor;
    CPTPlotSymbol *msftSymbol = [CPTPlotSymbol diamondPlotSymbol];
    msftSymbol.fill = [CPTFill fillWithColor:msftColor];
    msftSymbol.lineStyle = msftSymbolLineStyle;
    msftSymbol.size = CGSizeMake(6.0f, 6.0f);
    msftPlot.plotSymbol = msftSymbol;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Day of Month";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = 30;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    for (NSString *date in [NSArray arrayWithObjects:
                            @"2",
                            @"3",
                            @"4",
                            @"5",
                            @"9",
                            @"10",
                            @"11",
                            @"12",
                            @"13",
                            @"16",
                            @"17",
                            @"18",
                            @"19",
                            @"20",
                            @"23",
                            @"24", 
                            @"25",
                            @"26", 
                            @"27",
                            @"30",                   
                            nil]) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Price";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 100;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j); 
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations; 
}

#pragma mark - Timer Callback

- (void)newData:(NSTimer *)theTimer
{
//    [plot insertDataAtIndex:0 numberOfRecords:50];
//    if ( [graph plotWithIdentifier:@"Altitude Plot"] ) {
//        if ( plotData.count >= kMaxDataPoints ) {
//            [plotData removeObjectAtIndex:0];
//            [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
//        }
//        
//        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
//        NSUInteger location       = (currentIndex >= kMaxDataPoints ? currentIndex - kMaxDataPoints + 2 : 0);
//        
//        CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger( (location > 0) ? (location - 1) : 0 )
//                                                              length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
//        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
//                                                              length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
//        
//        [CPTAnimation animate:plotSpace
//                     property:@"xRange"
//                fromPlotRange:oldRange
//                  toPlotRange:newRange
//                     duration:CPTFloat(1.0 / 60.0)];
//        
//        currentIndex++;
//        [plotData addObject:@( rand() / (double)RAND_MAX )];
//        [thePlot insertDataAtIndex:plotData.count - 1 numberOfRecords:1];
//    }
}

#pragma mark - Plot Data Delegates

//- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
//{
//    return [plotData count];
//}
//
//- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
//{    
////    NSNumber *num = nil;
////    
////    switch ( fieldEnum ) {
////        case CPTScatterPlotFieldX:
////            num = [NSNumber numberWithInt: arc4random() % 50];
////            break;
////            
////        case CPTScatterPlotFieldY:
////            num = [NSNumber numberWithInt: arc4random() % 200];
////            break;
////            
////        default:
////            break;
////    }
////    
////    return num;
//    return @(30);
//}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Core Plot Animation Delegates

- (void)animationDidStart:(CPTAnimationOperation *)operation
{
    NSLog(@"animationDidStart: %@", operation);
}

- (void)animationDidFinish:(CPTAnimationOperation *)operation
{
    NSLog(@"animationDidFinish: %@", operation);
}

- (void)animationCancelled:(CPTAnimationOperation *)operation
{
    NSLog(@"animationCancelled: %@", operation);
}

- (void)animationWillUpdate:(CPTAnimationOperation *)operation
{
    NSLog(@"animationWillUpdate:");
}

- (void)animationDidUpdate:(CPTAnimationOperation *)operation
{
    NSLog(@"animationDidUpdate:");
}

@end
