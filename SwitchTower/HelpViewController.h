//
//  HelpViewController.h
//  SwitchTower
//
//  Created by bowdidge on 11/16/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController
@property(nonatomic, retain) IBOutlet UIWebView *helpTextView;
// HTML text to display in the help pane.
@property(nonatomic, retain) NSString *helpString;
@property(nonatomic, retain) IBOutlet UIButton *cancelButton;
@end
