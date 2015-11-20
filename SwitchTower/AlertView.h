//
//  AlertView.h
//  SwitchTower
//
//  Created by bowdidge on 11/18/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <UIKit/UIKit.h>
// AlertView draws a narrow bar above the layout view to highlight where alerts are needed.
@interface AlertView : UIView
- (void) clearAlerts;
- (void) addAlertAtLocation: (int) loc max: (int) max;

// NSIndexSet should contain some subset of integers between 0 and bucketCount-1,
// each representing a portion of the playing grid where alerts might happen.  Callers should
// set values for places where alerts need to be displayed.
@property(nonatomic, retain) NSMutableIndexSet *alertLocations;
@property(nonatomic) int bucketCount;
@end
