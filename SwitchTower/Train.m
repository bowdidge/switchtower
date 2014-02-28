//
//  Train.m
//  SwitchTower
//
//  Created by Robert Bowdidge on 12/22/12.
// Copyright (c) 2013, Robert Bowdidge
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//

#import "Train.h"

#import "NamedPoint.h"

@implementation Train
+ (id) train {
    return [[[Train alloc] init] autorelease];
}

- (id) init {
    self = [super init];
    self.trainName = @"";
    self.trainDescription = @"";
    self.xPosition = -1;
    self.yPosition = -1;
    self.currentLayout = nil;
    self.direction = WestDirection;
    self.expectedEndPoint = nil;
    self.currentState = Inactive;
    return self;
}

+ (id) trainWithName: (NSString*) name description: (NSString*) description
           direction: (enum TimetableDirection) dir
               start: (NamedPoint*) start end: (NamedPoint*) end {
    Train *train = [[[Train alloc] init] autorelease];
    train.trainName = name;
    train.trainDescription = description;
    train.direction = dir;
    train.startPoint = start;
    train.expectedEndPoint = end;
    return train;
}

- (void) setAppearanceTime: (NSDate*) appearanceTime departureTime: (NSDate*) departureTime arrivalTime: (NSDate*) arrivalTime {
    self.appearanceTime = appearanceTime;
    self.departureTime = departureTime;
    self.arrivalTime = arrivalTime;
}


- (void) setLocationX: (int) x Y: (int) y {
    if ((self.xPosition == x) && (self.yPosition == y)) {
        return;
    }
    self.xPosition = x;
    self.yPosition = y;
}

- (BOOL) isAtStartPosition {
    return self.xPosition == self.startPoint.xPosition && self.yPosition == self.startPoint.yPosition;
}

- (NSString*) description {
    return [NSString stringWithFormat: @"<Train: %@ %@ state=%d>", self.trainName, self.trainDescription, self.currentState];
}


@synthesize trainName;
@synthesize trainDescription;
@synthesize xPosition;
@synthesize yPosition;
@synthesize direction;
@synthesize expectedEndPoint;
@end


// Object representing a manipulation of a train.
@implementation TrainScript
- (BOOL) execute: (Train*) train context: (NSDictionary*) context {
    NSLog(@"Execute not implemented.");
    return NO;
}
@synthesize message;
@end

@implementation ChangeEndpoint

+ (ChangeEndpoint*) changeEndpointTo: (NamedPoint*) ep direction: (enum TimetableDirection) direction
                             newName: (NSString*) name
                       departureTime: (NSDate*) departureTime minimumWaitTime: (int) minimumWaitTime
                        expectedTime: (NSDate*) expectedTime message: (NSString*) message {
    ChangeEndpoint *change = [[[ChangeEndpoint alloc] init] autorelease];
    change.expectedEndPoint = ep;
    change.name = name;
    change.direction = direction;
    change.departureTime = departureTime;
    change.minimumWaitTime = minimumWaitTime;
    change.expectedTime = expectedTime;
    change.message = message;
    return change;
}


- (BOOL) execute: (Train*) train context: (NSDictionary*) context {
    train.trainName = self.name;
    train.startPoint = train.expectedEndPoint;
    train.expectedEndPoint = expectedEndPoint;
    train.direction = self.direction;
    train.currentState = Waiting;
    NSDate* currentTime = [context objectForKey: @"currentTime"];
    train.appearanceTime = currentTime;
    train.arrivalTime = self.expectedTime;
    train.currentState = Waiting;
    if ([currentTime compare: [train.departureTime dateByAddingTimeInterval: -1 * self.minimumWaitTime]] == NSOrderedAscending) {
        train.departureTime = [currentTime dateByAddingTimeInterval: self.minimumWaitTime];
    } else {
        train.departureTime = self.departureTime;
    }
    
    return YES;
}

@synthesize name;
@synthesize direction;
@synthesize departureTime;
@synthesize expectedEndPoint;
@end