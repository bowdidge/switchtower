//
//  TimetableViewController.h
//  SwitchTower2
//
//  Created by bowdidge on 2/25/14.
//  Copyright (c) 2014 bowdidge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayoutViewController.h"

// Controller for screen showing timetable in UIWebView.
@interface TimetableViewController : UIViewController
@property(nonatomic, retain) IBOutlet UIWebView *timetableView;
@property(nonatomic, retain) IBOutlet UIButton *cancelButton;
@end
