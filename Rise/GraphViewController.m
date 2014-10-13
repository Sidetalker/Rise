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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initalize our settings
    settings = [[Settings alloc] init];
    
    // Configure the view so we can do the whole landscape in portrait shebang
    [self configureView];
    
    // Make the beautiful plot
    [self initializePlot];
    
    // Create the exit button
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    // Set up an event handler for the exit button
    [btnExit setTitle:@"EXIT" forState:UIControlStateNormal];
    [btnExit sizeToFit];
    [btnExit addTarget: self
               action: @selector(exitClicked:)
     forControlEvents: UIControlEventTouchUpInside];
    
    // Position and rotate the button properly
    btnExit.center = CGPointMake(btnExit.bounds.size.width / 2 + 10, hostView.bounds.size.height - 15);
    btnExit.transform =  CGAffineTransformMakeRotation(-M_PI_2);
    btnExit.transform = CGAffineTransformMakeScale(1, -1);
    
    // Add the button to the subview we just created
    [hostView addSubview:btnExit];
    
    // Create the settings button
    UIButton *btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Set up an event handler for the settings button
    [btnSettings setContentMode:UIViewContentModeCenter];
    [btnSettings addTarget: self
                action: @selector(settingsClicked:)
      forControlEvents: UIControlEventTouchUpInside];
    
    // Set proper images and size
    UIImage *cogUp = [UIImage imageNamed:@"cogUp.png"];
    UIImage *cogUpScaled = [UIImage imageWithCGImage:[cogUp CGImage]
                                               scale:(cogUp.scale * 4.2)
                                         orientation:(cogUp.imageOrientation)];
    
    UIImage *cogDown = [UIImage imageNamed:@"cogDown.png"];
    UIImage *cogDownScaled = [UIImage imageWithCGImage:[cogDown CGImage]
                                               scale:(cogDown.scale * 4.2)
                                         orientation:(cogDown.imageOrientation)];
    
    [btnSettings setFrame:CGRectMake(hostView.frame.size.height - 38, hostView.frame.size.width - 38, cogUpScaled.size.width + 15, cogUpScaled.size.height + 15)];
    [btnSettings setContentMode:UIViewContentModeCenter];
    [btnSettings setImage:cogUpScaled forState:UIControlStateNormal];
    [btnSettings setImage:cogDownScaled forState:UIControlStateSelected];
    
    // Add the button to to our graphs superview
    [hostView addSubview:btnSettings];
    
    // Animate the incoming data
    [self performAnimationWithType:((int)[settings animationType]) framerate:1.0/60.0 duration:1.2];
}

#pragma mark - Graph Data Functions

- (void)reloadData
{
    [self loadData:rawData];
}

- (void)performAnimationWithType:(int)type framerate:(float)framerate duration:(float)duration
{
    animationType = type;
    plotDataAnimation = [[NSMutableArray alloc] init];
    
    float animationFrameRate = framerate;
    
    DDLogVerbose(@"Performing Animation %d", type);
    
    switch (type) {
        // Points appear centered along Y axis mean and
        // rise or fall linearlly to their appropriate positions
        case 0:
            animationMod = 0.0f;
            animationFrames = ceil(1 / framerate * duration);
            
            // Get the average value of all Y data
            float average = [[plotDataY valueForKeyPath:@"@avg.floatValue"] floatValue];
            
            // For each data point...
            for (int i = 0; i < plotDataY.count; i++)
            {
                // Determine the ending value and the appropriate increment
                NSMutableArray *curPoints = [[NSMutableArray alloc] init];
                float finisher = [[plotDataY objectAtIndex:i] floatValue];
                float increment = (finisher - average) / animationFrames;
                
                // Generate a point value for each frame of the animation
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
        
        // Points are drawn in, left to right
        case 1:
            animationFrameRate = duration / recordCount;
            animationMod = 0.0f;
            
            break;
            
        case 2:
            animationFrameRate = 1;
            animationMod = 0;
        default:
            break;
    }
    
    // Start the animation timer
    [animationTimer invalidate];
    animationTimer = [NSTimer timerWithTimeInterval:animationFrameRate
                                        target:self
                                      selector:@selector(newData:)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
}

- (void)loadData:(NSMutableArray*)data
{
    DDLogVerbose(@"Beginning to load data");
    
    // Initialize data arrays
    rawData = data;
    plotDataX = [[NSMutableArray alloc] init];
    plotDataY = [[NSMutableArray alloc] init];
    plotDataStrength = [[NSMutableArray alloc] init];
    
    // Scale times for 0 (this will probably be distance in the future)
    float tMinus = [(Location*)[data objectAtIndex:0] timestampLaunch];
    
    // Populate data arrays with provided location data
    for (Location *curLoc in data)
    {
        [plotDataX addObject:[NSNumber numberWithFloat:([curLoc timestampLaunch] - tMinus)]];
        
        if ([settings dataSource] == 0)
            [plotDataY addObject:[NSNumber numberWithFloat:[curLoc altitudeApple]]];
        else if ([settings dataSource] == 1)
            [plotDataY addObject:[NSNumber numberWithFloat:[curLoc altitudeGoogle]]];
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
    int upFlag = 0;
    int downFlag = 0;
    int directionFlag = 0; // 0 up, 1 down
    
    // Assign data points plot designations for slope based shading
    if ([plotDataY[0] floatValue] < [plotDataY[1] floatValue])
    {
        [plotDataStrength addObject:[NSNumber numberWithInt:0]];
        directionFlag = 1;
    }
    else
    {
        [plotDataStrength addObject:[NSNumber numberWithInt:2]];
    }
    
    for (int i = 1; i < plotDataY.count - 1; i++)
    {
        lastY = [[plotDataY objectAtIndex:i - 1] floatValue];
        curY = [[plotDataY objectAtIndex:i] floatValue];
        nextY = [[plotDataY objectAtIndex:i + 1] floatValue];
        
        long weight = -1;
        
        // Midpoint on a positively sloped line
        if (curY > lastY && curY < nextY && i > 1)
        {
            weight = upFlag;
            directionFlag = 0;
        }
        // Midpoint on a negatively sloped line
        else if (curY < lastY && curY > nextY && i > 1)
        {
            weight = downFlag + 2;
            directionFlag = 1;
        }
        // Left node of a straight line
        else if (curY == nextY)
        {
            // If we travelled up to get here
            if (curY > lastY)
            {
                directionFlag = 1;
                weight = upFlag;
            }
            // If we travelled down to get here
            else if (curY < lastY)
            {
                weight = downFlag + 2;
                directionFlag = 0;
            }
            // If this is a straight line midpoint
            else
            {
                if (directionFlag)
                    weight = upFlag;
                else
                    weight = downFlag + 2;
            }
        }
        // Peak or valley
        else
        {
            // Assign appropriate value for the peak plot combo
            if (!upFlag && !downFlag)
                weight = 4;
            else if (upFlag && downFlag)
                weight = 5;
            else if (!upFlag && downFlag)
                weight = 6;
            else if (upFlag && !downFlag)
                weight = 7;
            
            // Change either up or down plots depending on peak/valley
            if (curY > nextY)
            {
                upFlag = !upFlag;
                directionFlag = 0;
            }
            else
            {
                downFlag = !downFlag;
                directionFlag = 1;
            }
            
        }
        
        [plotDataStrength addObject:[NSNumber numberWithLong:weight]];
    }
    
    // Add the final point
    if (directionFlag)
        [plotDataStrength addObject:[NSNumber numberWithLong:upFlag]];
    else
        [plotDataStrength addObject:[NSNumber numberWithLong:downFlag + 2]];
    
    // Calculate mins and maxes
    recordCount = (int)data.count;
    maxX = [[plotDataX lastObject] floatValue];
    minY = [[plotDataY valueForKeyPath:@"@min.floatValue"] floatValue];
    maxY = [[plotDataY valueForKeyPath:@"@max.floatValue"] floatValue];
    
    minY -= (maxY - minY) * yPadding;
    maxY += (maxY - minY) * yPadding;
    
    DDLogVerbose(@"Finished loading data");
}

#pragma mark - View/Segue Management

- (IBAction)exitClicked:(id)sender
{
    [animationTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingsClicked:(id)sender
{
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
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
    
    // Perform the rotation in an animation
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void) {
                         hostView.transform = CGAffineTransformMakeRotation(myRotation);
                     }
                     completion:nil];
    
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
    
    // Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:47.0f];
    [graph.plotAreaFrame setPaddingBottom:36.0f];
    [graph.plotAreaFrame setPaddingRight:20.0f];
    [graph.plotAreaFrame setPaddingTop:32.0f];
    [graph.plotAreaFrame setBorderLineStyle:nil];
    
    // Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
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
    
    CPTScatterPlot *lightUpPlotB = [[CPTScatterPlot alloc] init];
    lightUpPlotB.dataSource = self;
    lightUpPlotB.identifier = @"lightUpB";
    CPTColor *lightUpColorB = [CPTColor redColor];
    [graph addPlot:lightUpPlotB toPlotSpace:plotSpace];
    
    CPTScatterPlot *heavyUpPlot = [[CPTScatterPlot alloc] init];
    heavyUpPlot.dataSource = self;
    heavyUpPlot.identifier = @"heavyUp";
    CPTColor *heavyUpColor = [CPTColor greenColor];
    [graph addPlot:heavyUpPlot toPlotSpace:plotSpace];
    
    CPTScatterPlot *lightDownPlotA = [[CPTScatterPlot alloc] init];
    lightDownPlotA.dataSource = self;
    lightDownPlotA.identifier = @"lightDownA";
    CPTColor *lightDownColorA = [CPTColor blueColor];
    [graph addPlot:lightDownPlotA toPlotSpace:plotSpace];
    
    CPTScatterPlot *lightDownPlotB = [[CPTScatterPlot alloc] init];
    lightDownPlotB.dataSource = self;
    lightDownPlotB.identifier = @"lightDownB";
    CPTColor *lightDownColorB = [CPTColor blueColor];
    [graph addPlot:lightDownPlotB toPlotSpace:plotSpace];
    
    CPTScatterPlot *heavyDownPlot = [[CPTScatterPlot alloc] init];
    heavyDownPlot.dataSource = self;
    heavyDownPlot.identifier = @"heavyDown";
    CPTColor *heavyDownColor = [CPTColor purpleColor];
    [graph addPlot:heavyDownPlot toPlotSpace:plotSpace];
    
    // Set up initial plot view
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    xRange.length = CPTDecimalFromFloat(maxX);
    xRange.location = CPTDecimalFromFloat(0.0f);
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    yRange.length = CPTDecimalFromFloat(maxY - minY);
    yRange.location = CPTDecimalFromFloat(minY);
    plotSpace.yRange = yRange;
    
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
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor grayColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor grayColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor grayColor];
    tickLineStyle.lineWidth = 1.5f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor grayColor];
    gridLineStyle.lineWidth = 0.3f;
    
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
    
    // Determine spacing between ticks
    float interval = (xMax - xMin) / xTickCount;
    float i = 0;
    
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:xTickCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:xTickCount];
    
    // Create all ticks between the first and the last and add them to the sets
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
    
    // Apply the changes to the x axis
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    // Configure y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    y.title = @"Elevation";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 31.0f;
    y.axisLineStyle = nil;
    y.majorGridLineStyle = gridLineStyle;
    y.gridLinesRange = [[CPTPlotRange alloc] initWithLocation:[[NSNumber numberWithFloat:0.0f] decimalValue] length:[[NSNumber numberWithFloat:[[plotDataX lastObject] floatValue]] decimalValue]];
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.majorTickLineStyle = gridLineStyle;
    y.majorTickLength = 0.0f;
    y.tickDirection = CPTSignNegative;
    
    int yTickCount = numYTicks;
    
    if (recordCount < yTickCount)
        yTickCount = recordCount;
    
    // Determine spacing between ticks
    interval = (yMax - yMin) / yTickCount;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yLocations = [NSMutableSet set];
    
    // Same as before for y axis
    if (interval > 0)
    {
        
    
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
    }
    else
    {
        NSString *labelText = [NSString stringWithFormat:@"0"];
        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:y.labelTextStyle];
        label.tickLocation = CPTDecimalFromCGFloat(0);
        label.offset = y.majorTickLength;
        if (label) {
            [yLabels addObject:label];
            [yLocations addObject:[NSNumber numberWithFloat:i]];
        }
    }
    
    // Apply changes
    y.axisLabels = yLabels;
    y.majorTickLocations = yLocations;
}

#pragma mark - Graph Delegate Functions

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    // If we're doing the drawing animation don't return the actual record count
    if (animationType == 1)
        return animationMod;
    
    return recordCount;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    // X indices are easy
    if (fieldEnum == CPTScatterPlotFieldX)
        return [plotDataX objectAtIndex:index];
    
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
    
    // The above weight legend is used to determine what points are added to what plots
    
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
    
    // For the grow animation access the multidimensional array
    if (animationType == 0)
        return [NSNumber numberWithFloat:[[[plotDataAnimation objectAtIndex:index] objectAtIndex:animationMod] floatValue] + offset];
    // Otherwise, just return the value including the debug offset
    else
        return [NSNumber numberWithFloat:[[plotDataY objectAtIndex:index] floatValue] + offset];
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
            // Otherwise accept the passed value
            else
                updatedRange = newRange;
            
            break;
            
        // Handled similiarly to the x axis but moving up and down within a range is acceptable
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
            
        // Not sure how the Z coord comes into play
        case CPTCoordinateZ:
            updatedRange = newRange;
            
            break;
        
        // Also don't know how this delegate could get called without a coordinate
        case CPTCoordinateNone:
            updatedRange = newRange;
            
            break;
    }
    
    // Update our axes
    [self redrawAxesWithMinX:space.xRange.locationDouble maxX:space.xRange.locationDouble + space.xRange.lengthDouble minY:space.yRange.locationDouble maxY:space.yRange.locationDouble + space.yRange.lengthDouble];
    
    return updatedRange;
}

- (BOOL)plotSpace:(CPTXYPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    // If we're zooming out, make sure we stay within legal bounds
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
        // The x range will always (I think) be the one that we need to worry about
        // but I'll leave this here for prudence's sake
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
    
    // Update the axes if we're allowing the zoom
    [self redrawAxesWithMinX:space.xRange.locationDouble maxX:space.xRange.locationDouble + space.xRange.lengthDouble minY:space.yRange.locationDouble maxY:space.yRange.locationDouble + space.yRange.lengthDouble];
    
    return YES;
}

#pragma mark - Timer Callback

- (void)newData:(NSTimer *)theTimer
{
    // Handle frame updates for different animation types
    // Animations are explained in detail in the performAnimationWithType function
    switch (animationType) {
        case 0:
            if (animationMod > animationFrames - 2)
            {
                [animationTimer invalidate];
                DDLogVerbose(@"Animation 0 Completed");
            }
            else
                animationMod++;
            
            break;
            
        case 1:
            if (animationMod > recordCount - 1)
            {
                [animationTimer invalidate];
                DDLogVerbose(@"Animation 1 Completed");
            }
            else
                animationMod++;
            
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