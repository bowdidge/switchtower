//
//  TimetableViewController.m
//  SwitchTower2
//
//  Created by bowdidge on 2/25/14.
//  Copyright (c) 2014 bowdidge. All rights reserved.
//

#import "Foundation/Foundation.h"

#import "TimetableViewController.h"

@implementation TimetableViewController

// TODO(bowdidge): Rewrite.  Note that this can be called multiple times.
- (void)viewDidLoad {
    NSLog(@"loaded");
    
    //pull the content from the file into memory
    NSData* data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"timetable" ofType: @"html"]];
    //convert the bytes from the file into a string
    NSString* timetableString = [[[NSString alloc] initWithBytes:[data bytes]
                                                 length:[data length]
                                               encoding:NSUTF8StringEncoding] autorelease];

    
    [self.timetableView loadHTMLString: timetableString baseURL: nil];
     // @"<html><head></head><body><b>Westbound: <ul><li> #75 (Lark) 5:55<li> #129: 6:04 <li>#131 6:25 <li> #133 6:30 <li>  #135 6:35 <li> #137 7:00 #139 7:55 <li> #141 (Del Monte) 8:38 / 8:50 <li> #31 (Santa Cruz) 10:20 <li> #143 10:30 </ul> Eastbound: <ul><li> #108 6:30 <li> #110 7:35 <li> #98 (Coast Daylight) 8:30 <li> #112 8:50 </ul> </body>" baseURL:nil];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return NO;
}

- (IBAction)didCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
