//
//  HelpViewController.m
//  SwitchTower
//
//  Created by bowdidge on 11/16/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController
- (void)viewDidLoad {
    if (self.helpString && [self.helpString length] > 0) {
        [self.helpTextView loadHTMLString: self.helpString baseURL: nil];
    } else {
        [self.helpTextView loadHTMLString: @"No help available." baseURL: nil];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return NO;
}

- (IBAction)didCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion: nil];
}


@end
