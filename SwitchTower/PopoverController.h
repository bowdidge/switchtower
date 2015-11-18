//
//  PopoverController.h
//  SwitchTower
//
//  Created by bowdidge on 11/13/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <UIKit/UIKit.h>

// DetailPopoverController provides a popover window to show information about a location on the screen.
@interface DetailPopoverController : UIViewController
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) NSString* message;
@end
