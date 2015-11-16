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
    [self.helpTextView loadHTMLString: @"Help text here." baseURL: nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return NO;
}

- (IBAction)didCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion: nil];
}


@end
