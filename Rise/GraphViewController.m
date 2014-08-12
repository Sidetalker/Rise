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

#pragma mark - Graph Constants

int numXTicks = 5;
int numYTicks = 5;

@implementation GraphViewController

#pragma mark - Load and Dismiss View

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view so we can do the whole landscape in portrait shebang
    [self configureView];
    
    // Make the beautiful plot
    [self initializePlot];
    
    // Create the exit button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    // Set up an event handler for the exit button
    [button setTitle:@"EXIT" forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget: self
               action: @selector(buttonClicked:)
     forControlEvents: UIControlEventTouchUpInside];
    
    // Position and rotate the button properly
    button.center = CGPointMake(button.bounds.size.width / 2 + 10, hostView.bounds.size.height - 15);
    button.transform =  CGAffineTransformMakeRotation(-M_PI_2);
    button.transform = CGAffineTransformMakeScale(1, -1);
    
    // Add the button to the subview we just created
    [hostView addSubview:button];
    
    dataTimer = [NSTimer timerWithTimeInterval:1.0 / 120
                                        target:self
                                      selector:@selector(newData:)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSDefaultRunLoopMode];

    // TODO set an image instead of stupid text
    //    UIImage *btnImage = [UIImage imageNamed:@"image.png"];
    //    [btnTwo setImage:btnImage forState:UIControlStateNormal];
}

- (bool)loadData:(NSMutableArray*)data
{
    if ([data count] == 0)
        NO;
    
    plotDataX = [[NSMutableArray alloc] init];
    plotDataY = [[NSMutableArray alloc] init];
    
    float tMinus = [(Location*)[data objectAtIndex:0] timestampLaunch];
    
    DDLogCVerbose(@"Launch time offset calculated");
    
    for (Location *curLoc in data)
    {
        [plotDataX addObject:[NSNumber numberWithFloat:([curLoc timestampLaunch] - tMinus)]];
        [plotDataY addObject:[NSNumber numberWithFloat:([curLoc altitudeApple])]];
    }
    
    DDLogCVerbose(@"All records added to appropriate arrays");
    
    recordCount = (int)data.count;
    
    return YES;
}

- (IBAction)buttonClicked:(id)sender
{
    [dataTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation Configuration

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// Portrait orientation only - landscape config will be done in a subview
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)configureView
{
    // Get the current orientation and configure the view layout
    int curOrientation = [[UIDevice currentDevice] orientation];
    double myRotation = 0;
    
    DDLogCVerbose(@"Current orientation: %d", curOrientation);
    
    if (curOrientation == UIDeviceOrientationLandscapeLeft || curOrientation == UIDeviceOrientationPortraitUpsideDown)
        myRotation = M_PI_2;
    else
        myRotation = -M_PI_2;
    
    // Create a graph subview that we can do whatever we want with
    hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    hostView.allowPinchScaling = YES;
    
    // Rotate the view either landscape left or right
    CGAffineTransform transform = CGAffineTransformMakeRotation(myRotation);
    
    // Set the bounds to be landscape and make the frame transformation
    hostView.bounds = CGRectMake(0,0, self.view.frame.size.height, self.view.frame.size.width);
    hostView.transform = transform;
    
    // Allow dem pinches and add the subview
    hostView.allowPinchScaling = YES;
    [self.view addSubview:hostView];
    
    DDLogCVerbose(@"Host view added and transformed");
    
    // Start watching for orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    DDLogCVerbose(@"Monitoring orientation changes");
}

- (void)deviceOrientationDidChange
{
    DDLogCVerbose(@"Received orientation change");
    
    // Get the current orientation
    int curOrientation = [[UIDevice currentDevice] orientation];
    double myRotation = 0;
    
    // Create a rotation only if the device orientation is landscape
    if (curOrientation == UIDeviceOrientationLandscapeLeft)
        myRotation = M_PI_2;
    else if (curOrientation == UIDeviceOrientationLandscapeRight)
        myRotation = -M_PI_2;
    else
        return;
    
    // Perform the rotation if we made it this far
    hostView.transform = CGAffineTransformMakeRotation(myRotation);
    
    DDLogCVerbose(@"Performed appropriate rotation");
}

#pragma mark - Graph Setup and Configuration

- (void)initializePlot
{
    DDLogCVerbose(@"Initializing Graph");
    [self configureGraph];
    DDLogCVerbose(@"Graph Initialized Successfully");
    DDLogCVerbose(@"Initializing Plots");
    [self configurePlots];
    DDLogCVerbose(@"Plots Initialized Successfully");
    DDLogCVerbose(@"Initializing Axes");
    [self configureAxes];
    DDLogCVerbose(@"Axes Initialized Successfully");
}

- (void)configureGraph
{
    // Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    hostView.hostedGraph = graph;
    
    DDLogCVerbose(@"Graph created and added to host view");
    
    // Set graph title
    NSString *title = @"Elevation Data";
    graph.title = title;
    
    // Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    DDLogCVerbose(@"Text style created");
    
    // Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:40.0f];
    [graph.plotAreaFrame setPaddingBottom:40.0f];
    [graph.plotAreaFrame setPaddingRight:20.0f];
    [graph.plotAreaFrame setPaddingTop:20.0f];
    [graph.plotAreaFrame setBorderLineStyle:nil];
    
    DDLogCVerbose(@"Plot padding and borders configured");
    
    // Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    DDLogCVerbose(@"User interactions and delegates configured");
}

- (void)configurePlots
{
    // Get graph and plot space
    CPTGraph *graph = hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    // Create the test plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = @"APPL";
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];
    
    DDLogCVerbose(@"Plot created");
    
//    CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];
//    googPlot.dataSource = self;
//    googPlot.identifier = @"GOOG";
//    CPTColor *googColor = [CPTColor greenColor];
//    [graph addPlot:googPlot toPlotSpace:plotSpace];
//    
//    CPTScatterPlot *msftPlot = [[CPTScatterPlot alloc] init];
//    msftPlot.dataSource = self;
//    msftPlot.identifier = @"MSFT";
//    CPTColor *msftColor = [CPTColor blueColor];
//    [graph addPlot:msftPlot toPlotSpace:plotSpace];
    
    // Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    xRange.length = CPTDecimalFromFloat(recordCount);
    plotSpace.xRange = xRange;
    
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    yRange.length = CPTDecimalFromFloat(recordCount*recordCount);
    plotSpace.yRange = yRange;
    
    DDLogCVerbose(@"Plot XY configured");
    
    // Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 1.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol plotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(2.0f, 2.0f);
    aaplPlot.plotSymbol = aaplSymbol;
    
    DDLogCVerbose(@"Plot line styles configured");
    
//    CPTMutableLineStyle *googLineStyle = [googPlot.dataLineStyle mutableCopy];
//    googLineStyle.lineWidth = 1.0;
//    googLineStyle.lineColor = googColor;
//    googPlot.dataLineStyle = googLineStyle;
//    
//    CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    googSymbolLineStyle.lineColor = googColor;
//    
//    CPTPlotSymbol *googSymbol = [CPTPlotSymbol starPlotSymbol];
//    googSymbol.fill = [CPTFill fillWithColor:googColor];
//    googSymbol.lineStyle = googSymbolLineStyle;
//    googSymbol.size = CGSizeMake(6.0f, 6.0f);
//    googPlot.plotSymbol = googSymbol;
//    
//    CPTMutableLineStyle *msftLineStyle = [msftPlot.dataLineStyle mutableCopy];
//    msftLineStyle.lineWidth = 2.0;
//    msftLineStyle.lineColor = msftColor;
//    msftPlot.dataLineStyle = msftLineStyle;
//    
//    CPTMutableLineStyle *msftSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    msftSymbolLineStyle.lineColor = msftColor;
//    
//    CPTPlotSymbol *msftSymbol = [CPTPlotSymbol diamondPlotSymbol];
//    msftSymbol.fill = [CPTFill fillWithColor:msftColor];
//    msftSymbol.lineStyle = msftSymbolLineStyle;
//    msftSymbol.size = CGSizeMake(6.0f, 6.0f);
//    msftPlot.plotSymbol = msftSymbol;
}

-(void)configureAxes
{
    // Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor grayColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor grayColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor grayColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor grayColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor grayColor];
    gridLineStyle.lineWidth = 0.3f;
    
    DDLogCVerbose(@"Axis styles created");
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)hostView.hostedGraph.axisSet;
    
    // 3 - Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    x.title = @"Data Point";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 20.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    float maxTime = [[plotDataX lastObject] floatValue];
    int xTickCount = numXTicks;
    
    if (recordCount < xTickCount)
        xTickCount = recordCount;
    
    float interval = maxTime / xTickCount;
    
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:xTickCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:xTickCount];
    NSInteger i = 0;

    for (i = 0; i <= xTickCount; i++)
    {
        NSString *labelText = [NSString stringWithFormat:@"%f", i*interval];
        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:x.labelTextStyle];
        label.tickLocation = CPTDecimalFromCGFloat(i*interval);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:i*interval]];
        }
    }
    
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    DDLogCVerbose(@"X Axis manual configuration complete");
    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    y.title = @"Elevation";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 20.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.gridLinesRange = [[CPTPlotRange alloc] initWithLocation:[[NSNumber numberWithFloat:0.0f] decimalValue] length:[[NSNumber numberWithFloat:recordCount] decimalValue]];
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 20.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignNegative;
    
    float maxHeight = [[plotDataY lastObject] floatValue];
    int yTickCount = numYTicks;
    
    if (recordCount < yTickCount)
        yTickCount = recordCount;
    
    interval = maxHeight / yTickCount;
    
    NSInteger majorIncrement = interval;
    NSInteger minorIncrement = interval / 2;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    
    for (i = minorIncrement; i <= maxHeight; i += minorIncrement)
    {
        NSUInteger mod = i % majorIncrement;
        
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)i] textStyle:y.labelTextStyle];
            label.tickLocation = CPTDecimalFromCGFloat(i);
            label.offset = y.majorTickLength;
            
            if (label)
            {
                [yLabels addObject:label];
                [yMajorLocations addObject:[NSNumber numberWithFloat:i]];
            }
        }
        else
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(i)]];
    }
    
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
    
    DDLogCVerbose(@"Y Axis manual configuration complete");
}

#pragma mark - Graph Delegate Functions

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return recordCount;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    if (index >= recordCount)
        return 0;
    
    if (fieldEnum == CPTScatterPlotFieldX)
        return [plotDataX objectAtIndex:index];
//        return [NSNumber numberWithInteger:index];
    else
        return [plotDataY objectAtIndex:index];
//        return [NSNumber numberWithDouble:(index*index) - (index*index*testMod)];
}

// This delegate is used to restrict the user's bounds to the
// the section containing the data plot view
-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space
     willChangePlotRangeTo:(CPTPlotRange *)newRange
             forCoordinate:(CPTCoordinate)coordinate
{
    CPTPlotRange *updatedRange = nil;
    
    switch (coordinate) {
        case CPTCoordinateX:
            // Don't allow negative x locations
            if (newRange.locationDouble < 0.0f) {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.location = CPTDecimalFromFloat(0.0f);
                updatedRange = mutableRange;
            }
            // Don't allow the range to extend past the requested x range
            else if (newRange.locationDouble + newRange.lengthDouble > recordCount)
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                
                float newLocation = recordCount - newRange.lengthDouble;
                if (newLocation < 0.0f)
                    newLocation = 0.0f;
                float newLength = newRange.lengthDouble;
                if (newLength > recordCount)
                    newLength = recordCount;
                
                mutableRange.location = CPTDecimalFromFloat(newLocation);
                mutableRange.length = CPTDecimalFromFloat(newLength);
                updatedRange = mutableRange;
            }
            else if (newRange.lengthDouble > recordCount)
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.length = CPTDecimalFromFloat(recordCount);
                updatedRange = mutableRange;
            }
            else {
                updatedRange = newRange;
            }
            break;
        case CPTCoordinateY:
            if (newRange.locationDouble < 0.0f) {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.location = CPTDecimalFromFloat(0.0f);
                updatedRange = mutableRange;
            }
            else if (newRange.locationDouble + newRange.lengthDouble > recordCount*recordCount)
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                
                float newLocation = recordCount*recordCount - newRange.lengthDouble;
                if (newLocation < 0.0f)
                    newLocation = 0.0f;
                float newLength = newRange.lengthDouble;
                if (newLength > recordCount*recordCount)
                    newLength = recordCount*recordCount;
                
                mutableRange.location = CPTDecimalFromFloat(newLocation);
                mutableRange.length = CPTDecimalFromFloat(newLength);
                updatedRange = mutableRange;
            }
            else if (newRange.lengthDouble > recordCount*recordCount)
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.length = CPTDecimalFromFloat(recordCount*recordCount);
                updatedRange = mutableRange;
            }
            else {
                updatedRange = newRange;
            }
            break;
        case CPTCoordinateZ:
            updatedRange = ((CPTXYPlotSpace *)space).yRange;
    }
    return updatedRange;
}

- (BOOL)plotSpace:(CPTXYPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    if (interactionScale < 1.0f)
    {
        if (space.xRange.lengthDouble / interactionScale > recordCount + 1)
        {
            CPTMutablePlotRange *xRange = [space.xRange mutableCopy];
            xRange.length = CPTDecimalFromFloat(recordCount);
            space.xRange = xRange;
            CPTMutablePlotRange *yRange = [space.yRange mutableCopy];
            yRange.length = CPTDecimalFromFloat(recordCount*recordCount);
            space.yRange = yRange;
            
            return NO;
        }
        else if (space.yRange.lengthDouble / interactionScale > recordCount*recordCount + 1)
        {
            CPTMutablePlotRange *xRange = [space.xRange mutableCopy];
            xRange.length = CPTDecimalFromFloat(recordCount);
            space.xRange = xRange;
            CPTMutablePlotRange *yRange = [space.yRange mutableCopy];
            yRange.length = CPTDecimalFromFloat(recordCount*recordCount);
            space.yRange = yRange;
            
            return NO;
        }
    }

    return YES;
}

#pragma mark - Timer Callback

- (void)newData:(NSTimer *)theTimer
{
    DDLogVerbose(@"Data Update");
    
    if (testMod <= 0.0f)
        testFlag = NO;
    else if (testMod >= 1.0f)
        testFlag = YES;
    
    if (testFlag)
        testMod -= 0.01f;
    else
        testMod += 0.01f;
    
    [hostView.hostedGraph reloadData];
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
