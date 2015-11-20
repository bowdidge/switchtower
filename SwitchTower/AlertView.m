//
//  AlertView.m
//  SwitchTower
//
//  Created by bowdidge on 11/18/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView
- (void) awakeFromNib {
    self.alertLocations = [[NSMutableIndexSet alloc] init];
    self.bucketCount = 10;
}

- (void) clearAlerts {
    [self.alertLocations removeAllIndexes];
}

- (void) addAlertAtLocation: (int) loc max: (int) max {
    [self.alertLocations addIndex: loc * self.bucketCount / max];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [[UIColor blackColor] setFill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, rect);
    
    float bucketFraction = 1.0 / self.bucketCount;

    for (int i=0; i < self.bucketCount; i++) {
        if ([self.alertLocations containsIndex: i]) {
            // TODO(bowdidge): Animate.
            CGRect fakeAlertRect = CGRectMake(rect.size.width *  i * bucketFraction, rect.origin.y, rect.size.width * bucketFraction, rect.size.    height);

            CGContextRef context = UIGraphicsGetCurrentContext();
            [[UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1.0] setFill];
            CGContextFillRect(context, fakeAlertRect);
        }
    }
        
}

@end
