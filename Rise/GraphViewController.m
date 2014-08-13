//
//  GraphViewControllerCleaned.m
//  Rise
//
//  Created by Kevin Sullivan on 8/12/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()

@end

#pragma mark - Graph Constants

int numXTicks = 5;
int numYTicks = 5;
float yPadding = 0.2f;

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
    
    // Animate the data to the screen
    [self performAnimationWithType:1 framerate:1.0/60.0 duration:3];
}

- (void)performAnimationWithType:(int)type framerate:(float)framerate duration:(float)duration
{
    animationType = type;
    plotDataAnimation = [[NSMutableArray alloc] init];
    
    DDLogVerbose(@"Performing animation %d", type);
    
    switch (type) {
        case 0:
            animationMod = 0.0f;
            animationFrameRate = framerate;
            animationTime = duration;
            animationFrames = ceil(1 / framerate * duration);
            animationCount = 0;
            
            float average = [[plotDataY valueForKeyPath:@"@avg.floatValue"] floatValue];
            
            for (int i = 0; i < plotDataY.count; i++)
            {
                NSMutableArray *curPoints = [[NSMutableArray alloc] init];
                float finisher = [[plotDataY objectAtIndex:i] floatValue];
                float increment = (finisher - average) / animationFrames;
                
                for (int y = 0; y < animationFrames; y++)
                {
                    if (y == 0)
                        [curPoints addObject:[NSNumber numberWithFloat:average]];
                    else
                        [curPoints addObject:[NSNumber numberWithFloat:[[curPoints lastObject] floatValue] + increment]];
                }
                
                [plotDataAnimation addObject:curPoints];
            }
            
            break;
            
        case 1:
            animationFrameRate = duration / recordCount;
            animationMod = 0.0f;
            
            break;
            
        default:
            break;
    }
    
    dataTimer = [NSTimer timerWithTimeInterval:animationFrameRate
                                        target:self
                                      selector:@selector(newData:)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSDefaultRunLoopMode];
}

- (bool)loadData:(NSMutableArray*)data
{
    if ([data count] == 0)
        NO;
    
    plotDataX = [[NSMutableArray alloc] init];
    plotDataY = [[NSMutableArray alloc] init];
    plotDataStrength = [[NSMutableArray alloc] init];
    
    float tMinus = [(Location*)[data objectAtIndex:0] timestampLaunch];
    
    DDLogVerbose(@"Launch time offset calculated");
    
    for (Location *curLoc in data)
    {
        [plotDataX addObject:[NSNumber numberWithFloat:([curLoc timestampLaunch] - tMinus)]];
        [plotDataY addObject:[NSNumber numberWithFloat:[curLoc altitudeApple]]];
    }
    
    // Weight Legend:
    // 0: lightUpA
    // 1: lightUpB
    // 2: lightDownA
    // 3: lightDownB
    // 4: lightUpA + lightDownA
    // 5: lightUpB + lightDownB
    // 6: lightUpA + lightDownB
    // 7: lightUpB + lightDownA
    
    float lastY = 0.0f;
    float curY = 0.0f;
    float nextY = 0.0f;
    long lastStrength = 0;
    int upFlag = 0;
    int downFlag = 0;
    int directionFlag = 0; // 0 up, 1 down
    
    if (plotDataY[0] < plotDataY[1])
    {
        [plotDataStrength addObject:[NSNumber numberWithInt:0]];
    }
    else
    {
        [plotDataStrength addObject:[NSNumber numberWithInt:2]];
        directionFlag = 1;
    }
    
    for (int i = 1; i < plotDataY.count - 1; i++)
    {
        lastY = [[plotDataY objectAtIndex:i - 1] floatValue];
        curY = [[plotDataY objectAtIndex:i] floatValue];
        nextY = [[plotDataY objectAtIndex:i + 1] floatValue];
        lastStrength = [[plotDataStrength lastObject] intValue];
        
        long weight = -1;
        
        if (curY > lastY && curY < nextY)
        {
            weight = upFlag;
            directionFlag = 0;
        }
        else if (curY < lastY && curY > nextY)
        {
            weight = downFlag + 2;
            directionFlag = 1;
        }
        else if (curY == lastY)
        {
            if (curY < nextY)
                weight = upFlag;
            else if (curY > nextY)
                weight = downFlag + 2;
            else
            {
                if (!directionFlag)
                    weight = upFlag;
                else
                    weight = downFlag + 2;
            }
        }
        else
        {
            if (!upFlag && !downFlag)
                weight = 4;
            else if (upFlag && downFlag)
                weight = 5;
            else if (!upFlag && downFlag)
                weight = 6;
            else if (upFlag && !downFlag)
                weight = 7;
            else
                DDLogWarn(@"Warning - unable to apply weight");
            
            directionFlag = !directionFlag;
            
            if (curY != nextY)
            {
                if (curY > lastY)
                    upFlag = !upFlag;
                else
                    downFlag = !downFlag;
            }
        }
        
        [plotDataStrength addObject:[NSNumber numberWithLong:weight]];
    }
    
    [plotDataStrength addObject:[NSNumber numberWithInt:0]];
    
    DDLogVerbose(@"All records added to appropriate arrays");
    
    recordCount = (int)data.count;
    maxX = [[plotDataX lastObject] floatValue];
    minY = [[plotDataY valueForKeyPath:@"@min.floatValue"] floatValue];
    maxY = [[plotDataY valueForKeyPath:@"@max.floatValue"] floatValue];
    
    minY -= (maxY - minY) * yPadding;
    maxY += (maxY - minY) * yPadding;
    
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
    
    DDLogVerbose(@"Current orientation: %d", curOrientation);
    
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
    
    DDLogVerbose(@"Host view added and transformed");
    
    // Start watching for orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    DDLogVerbose(@"Monitoring orientation changes");
}

- (void)deviceOrientationDidChange
{
    DDLogVerbose(@"Received orientation change");
    
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
    
    DDLogVerbose(@"Performed appropriate rotation");
}

#pragma mark - Graph Setup and Configuration

- (void)initializePlot
{
    DDLogVerbose(@"Initializing Graph");
    [self configureGraph];
    DDLogVerbose(@"Graph Initialized Successfully");
    DDLogVerbose(@"Initializing Plots");
    [self configurePlots];
    DDLogVerbose(@"Plots Initialized Successfully");
    DDLogVerbose(@"Initializing Axes");
    [self configureAxes];
    DDLogVerbose(@"Axes Initialized Successfully");
}

- (void)configureGraph
{
    // Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    hostView.hostedGraph = graph;
    
    DDLogVerbose(@"Graph created and added to host view");
    
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
    
    DDLogVerbose(@"Text style created");
    
    // Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:47.0f];
    [graph.plotAreaFrame setPaddingBottom:36.0f];
    [graph.plotAreaFrame setPaddingRight:20.0f];
    [graph.plotAreaFrame setPaddingTop:20.0f];
    [graph.plotAreaFrame setBorderLineStyle:nil];
    
    DDLogVerbose(@"Plot padding and borders configured");
    
    // Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    DDLogVerbose(@"User interactions and delegates configured");
}

- (void)configurePlots
{
    // Get graph and plot space
    CPTGraph *graph = hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    // Create the plots
    CPTScatterPlot *lightUpPlotA = [[CPTScatterPlot alloc] init];
    lightUpPlotA.dataSource = self;
    lightUpPlotA.identifier = @"lightUpA";
    CPTColor *lightUpColorA = [CPTColor redColor];
    [graph addPlot:lightUpPlotA toPlotSpace:plotSpace];
    
    DDLogVerbose(@"lightUpPlotA plot created");
    
    CPTScatterPlot *lightUpPlotB = [[CPTScatterPlot alloc] init];
    lightUpPlotB.dataSource = self;
    lightUpPlotB.identifier = @"lightUpB";
    CPTColor *lightUpColorB = [CPTColor magentaColor];
    [graph addPlot:lightUpPlotB toPlotSpace:plotSpace];
    
    DDLogVerbose(@"lightUpPlotB plot created");
    
    CPTScatterPlot *heavyUpPlot = [[CPTScatterPlot alloc] init];
    heavyUpPlot.dataSource = self;
    heavyUpPlot.identifier = @"heavyUp";
    CPTColor *heavyUpColor = [CPTColor greenColor];
    [graph addPlot:heavyUpPlot toPlotSpace:plotSpace];
    
    DDLogVerbose(@"heavyUpPlot plot created");
    
    CPTScatterPlot *lightDownPlotA = [[CPTScatterPlot alloc] init];
    lightDownPlotA.dataSource = self;
    lightDownPlotA.identifier = @"lightDownA";
    CPTColor *lightDownColorA = [CPTColor blueColor];
    [graph addPlot:lightDownPlotA toPlotSpace:plotSpace];
    
    DDLogVerbose(@"lightDownPlot plot created");
    
    CPTScatterPlot *lightDownPlotB = [[CPTScatterPlot alloc] init];
    lightDownPlotB.dataSource = self;
    lightDownPlotB.identifier = @"lightDownB";
    CPTColor *lightDownColorB = [CPTColor purpleColor];
    [graph addPlot:lightDownPlotB toPlotSpace:plotSpace];
    
    DDLogVerbose(@"lightDownPlot plot created");
    
    CPTScatterPlot *heavyDownPlot = [[CPTScatterPlot alloc] init];
    heavyDownPlot.dataSource = self;
    heavyDownPlot.identifier = @"heavyDown";
    CPTColor *heavyDownColor = [CPTColor purpleColor];
    [graph addPlot:heavyDownPlot toPlotSpace:plotSpace];
    
    DDLogVerbose(@"heavyDownPlot plot created");
    
    // Set up plot view
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    xRange.length = CPTDecimalFromFloat(maxX);
    xRange.location = CPTDecimalFromFloat(0.0f);
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    yRange.length = CPTDecimalFromFloat(maxY - minY);
    yRange.location = CPTDecimalFromFloat(minY);
    plotSpace.yRange = yRange;
    
    DDLogVerbose(@"Plot XY configured");
    
    // Create and apply line styles
    CPTMutableLineStyle *lightUpLineStyleA = [lightUpPlotA.dataLineStyle mutableCopy];
    lightUpLineStyleA.lineWidth = 1.8;
    lightUpLineStyleA.lineColor = lightUpColorA;
    lightUpLineStyleA.lineJoin = kCGLineJoinRound;
    lightUpPlotA.dataLineStyle = lightUpLineStyleA;
    
    CPTMutableLineStyle *lightUpLineStyleB = [lightUpPlotB.dataLineStyle mutableCopy];
    lightUpLineStyleB.lineWidth = 1.8;
    lightUpLineStyleB.lineColor = lightUpColorB;
    lightUpLineStyleB.lineJoin = kCGLineJoinRound;
    lightUpPlotB.dataLineStyle = lightUpLineStyleB;
    
    CPTMutableLineStyle *heavyUpLineStyle = [heavyUpPlot.dataLineStyle mutableCopy];
    heavyUpLineStyle.lineWidth = 0.8;
    heavyUpLineStyle.lineColor = heavyUpColor;
    heavyUpLineStyle.lineJoin = kCGLineJoinRound;
    heavyUpPlot.dataLineStyle = heavyUpLineStyle;
    
    CPTMutableLineStyle *lightDownLineStyleA = [lightDownPlotA.dataLineStyle mutableCopy];
    lightDownLineStyleA.lineWidth = 0.8;
    lightDownLineStyleA.lineColor = lightDownColorA;
    lightDownLineStyleA.lineJoin = kCGLineJoinRound;
    lightDownPlotA.dataLineStyle = lightDownLineStyleA;
    
    CPTMutableLineStyle *lightDownLineStyleB = [lightDownPlotB.dataLineStyle mutableCopy];
    lightDownLineStyleB.lineWidth = 0.8;
    lightDownLineStyleB.lineColor = lightDownColorB;
    lightDownLineStyleB.lineJoin = kCGLineJoinRound;
    lightDownPlotB.dataLineStyle = lightDownLineStyleB;
    
    CPTMutableLineStyle *heavyDownLineStyle = [heavyDownPlot.dataLineStyle mutableCopy];
    heavyDownLineStyle.lineWidth = 0.8;
    heavyDownLineStyle.lineColor = heavyDownColor;
    heavyDownLineStyle.lineJoin = kCGLineJoinRound;
    heavyDownPlot.dataLineStyle = heavyDownLineStyle;
    
    DDLogVerbose(@"Plot line styles configured");
}

-(void)configureAxes
{
    [self redrawAxesWithMinX:0.0f maxX:maxX minY:minY maxY:maxY];
}

- (void)redrawAxesWithMinX:(float)xMin maxX:(float)xMax minY:(float)yMin maxY:(float)yMax
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
    
    DDLogVerbose(@"Axis styles created");
    
    // Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)hostView.hostedGraph.axisSet;
    
    // Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    x.title = @"Time";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 20.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    
    int xTickCount = numXTicks;
    
    if (recordCount < xTickCount)
        xTickCount = recordCount;
    
    float interval = (xMax - xMin) / xTickCount;
    float i = 0;
    
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:xTickCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:xTickCount];
    
    for (i = xMin + interval; i <= xMax - (interval / 2); i += interval)
    {
        NSString *labelText = [NSString stringWithFormat:@"%.2f", i];
        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:x.labelTextStyle];
        label.tickLocation = CPTDecimalFromCGFloat(i);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:i]];
        }
    }
    
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    DDLogVerbose(@"X Axis manual configuration complete");
    
    // Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    y.title = @"Elevation";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 31.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.gridLinesRange = [[CPTPlotRange alloc] initWithLocation:[[NSNumber numberWithFloat:0.0f] decimalValue] length:[[NSNumber numberWithFloat:[[plotDataX lastObject] floatValue]] decimalValue]];
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignNegative;
    
    int yTickCount = numYTicks;
    
    if (recordCount < yTickCount)
        yTickCount = recordCount;
    
    interval = (yMax - yMin) / yTickCount;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yLocations = [NSMutableSet set];
    
    for (i = yMin + interval; i <= yMax - (interval / 2); i += interval)
    {
        NSString *labelText = [NSString stringWithFormat:@"%.1f", i];
        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:y.labelTextStyle];
        label.tickLocation = CPTDecimalFromCGFloat(i);
        label.offset = y.majorTickLength;
        if (label) {
            [yLabels addObject:label];
            [yLocations addObject:[NSNumber numberWithFloat:i]];
        }
    }
    
    y.axisLabels = yLabels;
    y.majorTickLocations = yLocations;
    
    DDLogVerbose(@"Y Axis manual configuration complete");
}

#pragma mark - Graph Delegate Functions

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (animationType == 1)
        return animationMod;
    
    return recordCount;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    long pointStrength = [[plotDataStrength objectAtIndex:index] longValue];
    int offset = 5;
    
    // Weight Legend:
    // 0: lightUpA
    // 1: lightUpB
    // 2: lightDownA
    // 3: lightDownB
    // 4: lightUpA + lightDownA
    // 5: lightUpB + lightDownB
    // 6: lightUpA + lightDownB
    // 7: lightUpB + lightDownA
    
    if ([plot.identifier isEqual: @"lightUpA"])
    {
        if (!(pointStrength == 0 || pointStrength == 4 || pointStrength == 6))
            return nil;
        
        offset = 0;
    }
    else if ([plot.identifier isEqual:@"lightUpB"])
    {
        if (!(pointStrength == 1 || pointStrength == 5 || pointStrength == 7))
            return nil;
        
        offset = 0;
    }
    else if ([plot.identifier isEqual:@"lightDownA"])
    {
        if (!(pointStrength == 2 || pointStrength == 4 || pointStrength == 7))
            return nil;
        
        offset = 0;
    }
    else if ([plot.identifier isEqual:@"lightDownB"])
    {
        if (!(pointStrength == 3 || pointStrength == 5 || pointStrength == 6))
            return nil;
        
        offset = 0;
    }
    else
        return nil;
//    else if (![plot.identifier isEqual:@"heavyUp"])
//        return nil;
    
    if (fieldEnum == CPTScatterPlotFieldX)
        return [plotDataX objectAtIndex:index];
    else
    {
        if (animationType == 0)
            return [NSNumber numberWithFloat:[[[plotDataAnimation objectAtIndex:index] objectAtIndex:animationCount] floatValue] + offset];
        else
            return [NSNumber numberWithFloat:[[plotDataY objectAtIndex:index] floatValue] + offset];
    }
}

// This delegate is used to restrict the user's bounds to the
// the section containing the data plot view
-(CPTPlotRange *)plotSpace:(CPTXYPlotSpace *)space
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
            else if (newRange.locationDouble + newRange.lengthDouble > maxX)
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                
                float newLocation = maxX - newRange.lengthDouble;
                if (newLocation < 0.0f)
                    newLocation = 0.0f;
                float newLength = newRange.lengthDouble;
                if (newLength > maxX)
                    newLength = maxX;
                
                mutableRange.location = CPTDecimalFromFloat(newLocation);
                mutableRange.length = CPTDecimalFromFloat(newLength);
                updatedRange = mutableRange;
            }
            else if (newRange.lengthDouble > maxX)
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.length = CPTDecimalFromFloat(maxX);
                updatedRange = mutableRange;
            }
            else
                updatedRange = newRange;
            
            break;
        case CPTCoordinateY:
            if (newRange.locationDouble < (minY - (maxY - minY) / 3))
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.location = CPTDecimalFromFloat((minY - (maxY - minY) / 3));
                updatedRange = mutableRange;
            }
            else if (newRange.locationDouble + newRange.lengthDouble > (maxY + (maxY - minY) / 3))
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                
                float newLocation = (maxY + (maxY - minY) / 3) - newRange.lengthDouble;
                if (newLocation < 0.0f)
                    newLocation = 0.0f;
                float newLength = newRange.lengthDouble;
                if (newLength > maxY)
                    newLength = maxY;
                
                mutableRange.location = CPTDecimalFromFloat(newLocation);
                mutableRange.length = CPTDecimalFromFloat(newLength);
                updatedRange = mutableRange;
            }
            else if (newRange.lengthDouble > (maxY - minY))
            {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.length = CPTDecimalFromFloat((maxY - minY));
                updatedRange = mutableRange;
            }
            else
                updatedRange = newRange;
            
            break;
        case CPTCoordinateZ:
            updatedRange = newRange;
            
            break;
    }
    
    [self redrawAxesWithMinX:space.xRange.locationDouble maxX:space.xRange.locationDouble + space.xRange.lengthDouble minY:space.yRange.locationDouble maxY:space.yRange.locationDouble + space.yRange.lengthDouble];
    
    return updatedRange;
}

- (BOOL)plotSpace:(CPTXYPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    if (interactionScale < 1.0f)
    {
        if (space.xRange.lengthDouble / interactionScale > maxX)
        {
            CPTMutablePlotRange *xRange = [space.xRange mutableCopy];
            xRange.length = CPTDecimalFromFloat(maxX);
            space.xRange = xRange;
            CPTMutablePlotRange *yRange = [space.yRange mutableCopy];
            yRange.length = CPTDecimalFromFloat(maxY - minY);
            space.yRange = yRange;
            
            return NO;
        }
        else if (space.yRange.lengthDouble / interactionScale > (maxY- minY))
        {
            CPTMutablePlotRange *xRange = [space.xRange mutableCopy];
            xRange.length = CPTDecimalFromFloat(maxX);
            space.xRange = xRange;
            CPTMutablePlotRange *yRange = [space.yRange mutableCopy];
            yRange.length = CPTDecimalFromFloat(maxY - minY);
            space.yRange = yRange;
            
            return NO;
        }
    }
    
    [self redrawAxesWithMinX:space.xRange.locationDouble maxX:space.xRange.locationDouble + space.xRange.lengthDouble minY:space.yRange.locationDouble maxY:space.yRange.locationDouble + space.yRange.lengthDouble];
    
    return YES;
}

#pragma mark - Timer Callback

- (void)newData:(NSTimer *)theTimer
{
    switch (animationType) {
        case 0:
            if (animationCount > animationFrames - 2)
                [dataTimer invalidate];
            else
                animationCount++;
            
            break;
            
        case 1:
            if (animationMod > recordCount - 1)
                [dataTimer invalidate];
            else
                animationMod++;
            
            break;
            
        case 2:
            if (animationMod > 1.0f)
                [dataTimer invalidate];
            else
            {
                animationMod += animationFrameRate / animationTime;
            }
            
            break;
            
        default:
            break;
    }
    
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