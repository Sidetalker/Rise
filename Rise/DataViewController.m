//
//  DataViewController.m
//  Rise
//
//  Created by Kevin Sullivan on 7/18/14.
//  Copyright (c) 2014 com.sideapps.rise. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController

@synthesize webView, currentURL, isLoading;

#pragma mark - Initialization Functions

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
    
    // Load the most recent data
    [webView setDelegate:self];
    [self loadText];
    isLoading = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebView Control

- (void)loadText
{
    // Load the most recent text data
    NSURL* nsUrl = [NSURL URLWithString:@"http://sideapps.com/rise/recentText.php"];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    [webView loadRequest:request];
}

- (void)loadCSV
{
    // Load the most CSV data
    NSURL* nsUrl = [NSURL URLWithString:@"http://sideapps.com/rise/recentCSV.php"];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    [webView loadRequest:request];
}

- (IBAction)btnTextOrCSV:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *segmentTitle = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    isLoading = YES;
    
    // Load the appropriate data
    if ([segmentTitle isEqualToString:@"Text"])
    {
        [self loadText];
        DDLogVerbose(@"Loading Text Data View");
    }
    else if ([segmentTitle isEqualToString:@"CSV"])
    {
        [self loadCSV];
        DDLogVerbose(@"Loading CSV Data View");
    }
}

#pragma mark - WebView Delegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DDLogVerbose(@"Finished Loading Webview")
    
    isLoading = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // Display an error with the appropriate message
    NSString *errorText = [error localizedDescription];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Loading Data"
                                                    message:errorText
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    DDLogVerbose(@"Error Loading Data: %@", errorText);
}

@end
