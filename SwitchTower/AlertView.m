//
//  AlertView.m
//  SwitchTower
//
//  Created by bowdidge on 11/18/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [[UIColor blackColor] setFill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, rect);
    
    // TODO(bowdidge): Allow clients to set a vector locating which part of screen needs attention.
    // TODO(bowdidge): Consider animation: have light flash at same time as chirp.
    [[UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1.0] setFill];
    CGRect fakeAlertRect = CGRectMake(rect.size.width * 0.9, rect.origin.y, rect.size.width * 0.1, rect.size.height);
    CGContextFillRect(context, fakeAlertRect);
}

@end
