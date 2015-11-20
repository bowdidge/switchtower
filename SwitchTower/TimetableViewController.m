//
//  TimetableViewController.m
//  SwitchTower2
//
//  Created by bowdidge on 2/25/14.
//  Copyright (c) 2014 bowdidge. All rights reserved.
//

#import "Foundation/Foundation.h"

#import "TimetableViewController.h"

#import "Scenario.h"

@implementation TimetableViewController

// TODO(bowdidge): Rewrite.  Note that this can be called multiple times.
- (void)viewDidLoad {
    [self.timetableView loadHTMLString: [self.scenario timetableHTML] baseURL: nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return NO;
}

- (IBAction)didCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion: nil];
}

@end
