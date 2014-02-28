//
//  LayoutSpecification.m
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

#import "Scenario.h"

#import "NamedPoint.h"
#import "Signal.h"
#import "Train.h"

@implementation Scenario

//
//  -  ---
//
//  = Platform / town
//
//      /       \
//  /  /     \   \
//    /           \
//
//       /       \
//  P  ---   p   ---
//
//
//  Q  ---   q   ---
//       \       /
//
//      /       \
//  R  /-    r  -\
//    /           \
//
//    \           /
//  V  \-    v  -/
//      \       /
//
//      /      \
//  Y --     y  --
//      \      /
//

//  /-      p   --
//     /           /
//
//       /          \
//   ---      V   ---
//

//       /          \
//  Q  ---      q   ---
//
//
//
//  Z  --      z    --
//    /               \
//
//     \              /
//  W   --     w    --
//
//  T  |--     t   --|


#define TILE_ROWS 1
#define TILE_COLUMNS 1
// Current track layout to draw.  See above for key of what the letters mean.
static char* cells[TILE_ROWS] = {
    " ",
};


- (id) init {
    self = [super init];
    return self;
}

- (int) tileRows {
    return TILE_ROWS;
}

- (int) tileColumns {
    return TILE_COLUMNS;
}

- (char) cellAtTileX: (int) x Y: (int) y {
    return cells[y][x];
}

- (NamedPoint*) endpointWithName: (NSString*) name {
    for (NamedPoint *ep in self.all_endpoints) {
        if ([ep.name isEqualToString: name]) {
            return ep;
        }
    }
    return nil;
    
}

- (NamedPoint*) endpointAtTileX: (int) x Y: (int) y {
    for (NamedPoint *ep in self.all_endpoints) {
        if (ep.xPosition == x && ep.yPosition == y) {
            return ep;
        }
    }
    return nil;
    
}

- (NSDate*) zeroDate {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter dateFromString: @"00:00"];
}

- (NSDate*) startingTime {
    // Assume all scenarios start at 6:00 am.
    // TODO(bowdidge): Fix time zone.
    return [self scenarioTime: @"05:30"];
}

- (int) tickLengthInSeconds {
    return 60;
}

- (NSDate*) scenarioTime: (NSString*) timeString {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];

    NSDate* zeroDate = [dateFormatter dateFromString: @"00:00"];
    NSDate* date = [dateFormatter dateFromString: timeString];
    NSTimeInterval offset = [date timeIntervalSinceDate: zeroDate];
    NSDate *returnValue = [[self zeroDate] dateByAddingTimeInterval: offset];
    return returnValue;
}


- (BOOL) isNamedPoint: (NamedPoint*) a sameAs: (NamedPoint*) b {
    return (a == b);
}


@synthesize all_endpoints;
@end
