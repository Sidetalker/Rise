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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    // Create the graph host view and add it to our main view
    hostView = [[CPTGraphHostingView alloc] init];
    [self.view addSubview:hostView];
    
    // Create and initialize graph
    graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;

    // Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;

//    // Configure title
//    NSString *title = @"Test";
//    graph.title = title;
//    graph.titleTextStyle = textStyle;
//    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
//    graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
//
//    // Set theme
//    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
//    
    // Create the plot
    plot = [[CPTScatterPlot alloc] init];
    plot.identifier     = @"Altitude Plot";
    plot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [plot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 0.5;
    lineStyle.lineColor              = [CPTColor greenColor];
    plot.dataLineStyle = lineStyle;
    
    plot.dataSource = self;
    [graph addPlot:plot];
    
    // Start adding the data using the timer
    dataTimer = [NSTimer timerWithTimeInterval:1.0 / 60.0
                                        target:self
                                      selector:@selector(newData:)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSRunLoopCommonModes];
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



#pragma mark - Timer Callback

-(void)newData:(NSTimer *)theTimer
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

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{    
//    NSNumber *num = nil;
//    
//    switch ( fieldEnum ) {
//        case CPTScatterPlotFieldX:
//            num = [NSNumber numberWithInt: arc4random() % 50];
//            break;
//            
//        case CPTScatterPlotFieldY:
//            num = [NSNumber numberWithInt: arc4random() % 200];
//            break;
//            
//        default:
//            break;
//    }
//    
//    return num;
    return @(30);
}

#pragma mark - Core Plot Animation Delegates

-(void)animationDidStart:(CPTAnimationOperation *)operation
{
    NSLog(@"animationDidStart: %@", operation);
}

-(void)animationDidFinish:(CPTAnimationOperation *)operation
{
    NSLog(@"animationDidFinish: %@", operation);
}

-(void)animationCancelled:(CPTAnimationOperation *)operation
{
    NSLog(@"animationCancelled: %@", operation);
}

-(void)animationWillUpdate:(CPTAnimationOperation *)operation
{
    NSLog(@"animationWillUpdate:");
}

-(void)animationDidUpdate:(CPTAnimationOperation *)operation
{
    NSLog(@"animationDidUpdate:");
}

@end
