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

#import "Cell.h"
#import "NamedPoint.h"

@implementation Train
+ (id) train {
    return [[[Train alloc] init] autorelease];
}

- (id) init {
    self = [super init];
    self.trainNumber = @"";
    self.trainName = @"";
    self.position = MakeCellPosition(-1, -1);
    self.currentLayout = nil;
    self.direction = WestDirection;
    self.expectedEndPoints = nil;
    self.currentState = Inactive;
    return self;
}

+ (id) trainWithNumber: (NSString*) trainNumber name: (NSString*) trainName
           direction: (enum TimetableDirection) dir
               start: (NamedPoint*) start ends: (NSArray*) ends {
    Train *train = [[[Train alloc] init] autorelease];
    train.trainNumber = trainNumber;
    train.trainName = trainName;
    train.trainDescription = @"";
    train.direction = dir;
    train.startPoint = start;
    train.expectedEndPoints = ends;
    return train;
}

- (void) setDepartureTime: (NSDate*) departureTime arrivalTime: (NSDate*) arrivalTime {
    self.departureTime = departureTime;
    self.arrivalTime = arrivalTime;
}


- (BOOL) isAtStartPosition {
    return self.position.x == self.startPoint.position.x && self.position.y == self.startPoint.position.y;
}

- (BOOL) isAtEndPosition {
    for (NamedPoint *end in self.expectedEndPoints) {
        if (self.position.x == end.position.x && self.position.y == end.position.y) {
            return true;
        }
    }
    return false;
}

// Helper routine for nicely printing out all the possible exit points for train.
- (NSString*) endPointsAsText {
    NSMutableArray *endNames = [NSMutableArray array];
    for (NamedPoint* end in self.expectedEndPoints) {
        [endNames addObject: end.name];
    }
    return [endNames componentsJoinedByString: @", "];
}

- (NSString*) description {
    return [NSString stringWithFormat: @"<Train: %@ %@ first end=%@ state=%d>", self.trainNumber, self.trainName, [[self.expectedEndPoints objectAtIndex: 0] name], self.currentState];
}

// Compare two trains by departure time.
- (NSComparisonResult) compareByTime: (Train*) tr {
    return [self.departureTime compare: tr.departureTime];
}


@synthesize trainNumber;
@synthesize trainName;
@synthesize position;
@synthesize direction;
@synthesize expectedEndPoints;
@synthesize onTimetable;
@synthesize startPoint;
@end


