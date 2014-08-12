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
    [self performAnimationWithType:0 framerate:1.0/60.0 duration:1.2];
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
    
    float tMinus = [(Location*)[data objectAtIndex:0] timestampLaunch];
    
    DDLogVerbose(@"Launch time offset calculated");
    
    for (Location *curLoc in data)
    {
        [plotDataX addObject:[NSNumber numberWithFloat:([curLoc timestampLaunch] - tMinus)]];
        [plotDataY addObject:[NSNumber numberWithFloat:([curLoc altitudeApple])]];
    }
    
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
    
    // Create the test plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = @"APPL";
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];
    
    DDLogVerbose(@"Plot created");
    
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
    
    // Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 1.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(4.0f, 4.0f);
    aaplPlot.plotSymbol = aaplSymbol;
    
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
    if (index >= recordCount)
        return 0;
    
    if (fieldEnum == CPTScatterPlotFieldX)
        return [plotDataX objectAtIndex:index];
    else
    {
        if (animationType == 0)
            return [NSNumber numberWithFloat:[[[plotDataAnimation objectAtIndex:index] objectAtIndex:animationCount] floatValue]];
        else
            return [NSNumber numberWithFloat:[[plotDataY objectAtIndex:index] floatValue]];
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
