//
//  DiridonSpecification.m
//  SwitchTower
//
//  Created by Robert Bowdidge on 12/23/12.
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

#import "DiridonScenario.h"

#import "NamedPoint.h"
#import "Label.h"
#import "Signal.h"
#import "Train.h"

@implementation DiridonScenario


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


#define TILE_ROWS 8
#define TILE_COLUMNS 36

// Current track layout to draw.  See above for key of what the letters mean.
static char* cells[TILE_ROWS] = {
//  "01234567890123456789012345"
    "                  Z--.             ",
    "          .z     R---z      \\      ",
    ".z       T-z\\   R---z WQ-----pQ---.",
    "  \\        ZppQP-----pQ-pqQ----p--.",
    ".-qpQ---q-P----pQ-----qpPQQp------.",
    ".w   W-w         W---w    \\\\          ",
    "                           \\W.        ",
    "                            W.          "
};

- (id) init {
    self = [super init];
    NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"From SF" X: 34 Y: 3]];
    [eps addObject: [NamedPoint namedPointWithName: @"From SF Frt" X: 34 Y: 2]];
    [eps addObject: [NamedPoint namedPointWithName: @"To SF" X: 34 Y: 4]];
    [eps addObject: [NamedPoint namedPointWithName: @"To LA" X: 0 Y: 4]];
    [eps addObject: [NamedPoint namedPointWithName: @"From LA" X: 0 Y: 5]];
    
    [eps addObject: [NamedPoint namedPointWithName: @"Vasona Branch" X: 10 Y: 1]];
    [eps addObject: [NamedPoint namedPointWithName: @"Hillsdale Branch" X: 0 Y: 2]];
    
    [eps addObject: [NamedPoint namedPointWithName: @"Eng Service" X: 29 Y: 6]];
    [eps addObject: [NamedPoint namedPointWithName: @"Diridon-4" X: 19 Y: 2]];
    [eps addObject: [NamedPoint namedPointWithName: @"Diridon-3" X: 19 Y: 3]];
    [eps addObject: [NamedPoint namedPointWithName: @"Diridon-2" X: 19 Y: 4]];
    [eps addObject: [NamedPoint namedPointWithName: @"Diridon-1" X: 19 Y: 5]];
 
    [eps addObject: [NamedPoint namedPointWithName: @"Mulford" X: 29 Y: 7]];
    [eps addObject: [NamedPoint namedPointWithName: @"Coach Yard" X: 21 Y: 0]];
    [eps addObject: [NamedPoint namedPointWithName: @"Lead" X: 13 Y: 3]];

    self.all_endpoints = eps;
    [self initTrains];
    [self initLabels];
    return self;
}

- (int) tileRows {
    return TILE_ROWS;
}

- (int) tileColumns {
    return TILE_COLUMNS;
}

- (char) cellAtTileX: (int) x Y: (int) y {
    if ((y > TILE_ROWS) || (x > TILE_COLUMNS) || (y < 0) || (x < 0)) {
        return ' ';
    }
    return cells[y][x];
}

// Creates a commute train and the light engine movement before or after its arrival.
// The departure time represents the arrival/departure time at San Jose station; other movements
// are offsets from this.
- (Train *) createCommuteTrainWithName: (NSString*) name direction: (enum TimetableDirection) direction
                         departureTime: (NSDate*) departureTime {
    Train *train = nil;
    NamedPoint *toSF = [self endpointWithName: @"To SF"];
    NamedPoint *fromSF = [self endpointWithName: @"From SF"];
    // TODO(bowdidge): Be able to go to any track.
    NamedPoint *diridon = [self endpointWithName: @"Diridon-2"];
    NamedPoint *engineService = [self endpointWithName: @"Eng Service"];
   
    if (direction == WestDirection) {
        // For a westbound commute train (to left on screen), train should appear 16 min before arrival time, and arrive at arrival time.  It should have light engine available 10 min later.
        train = [Train trainWithName: name description: @"Commute"
                           direction: direction
                               start: fromSF end: diridon];
        [train setAppearanceTime: [departureTime dateByAddingTimeInterval: -21 * 60] departureTime: [departureTime dateByAddingTimeInterval: -16 * 60] arrivalTime: departureTime];

        train.script = [ChangeEndpoint changeEndpointTo: engineService direction: EastDirection
                                                newName: @"light engine"
                                          departureTime: [departureTime dateByAddingTimeInterval: 10 * 60] minimumWaitTime: 10 expectedTime: [departureTime dateByAddingTimeInterval: 26 * 60]
                                                message:
                        [NSString stringWithFormat: @"Engine for %@ needs to be serviced.", name]];
    } else if (direction == EastDirection) {
        // For a eastbound commute train (to right on screen): light engine should appear 35 min before, leave 30 min before, and arrive 10m before departure.  It takes 16 steps to go from station to end.
        train = [Train trainWithName: @"Light Eng" description: @"Commute"
                           direction: WestDirection
                               start: engineService end: diridon];
        // have train ready 20 counts before.
        [train setAppearanceTime: [departureTime dateByAddingTimeInterval: -35*60] departureTime: [departureTime dateByAddingTimeInterval: -30 * 60] arrivalTime: [departureTime dateByAddingTimeInterval: -10 * 60]];
        train.script = [ChangeEndpoint changeEndpointTo: toSF direction: EastDirection
                                                newName: name
                                          departureTime: departureTime minimumWaitTime: 10 expectedTime: [departureTime dateByAddingTimeInterval: 16 * 60]
                                                message: name];
    } else {
        return nil;
    }
    return train;
}

- (NSDate*) startingTime {
    // Assume all scenarios start at 6:00 am.
    // TODO(bowdidge): Fix time zone.
    return [self scenarioTime: @"05:30"];
}

- (int) tickLengthInSeconds {
    return 30;
}

- (void) initTrains {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject: [self createCommuteTrainWithName: @"129" direction: EastDirection departureTime: [self scenarioTime: @"06:04"]]];
    [array addObject: [self createCommuteTrainWithName: @"131" direction: EastDirection departureTime: [self scenarioTime: @"06:25"]]];
    [array addObject: [self createCommuteTrainWithName: @"133" direction: EastDirection departureTime: [self scenarioTime: @"06:30"]]];
    [array addObject: [self createCommuteTrainWithName: @"135" direction: EastDirection departureTime: [self scenarioTime: @"06:35"]]];
    [array addObject: [self createCommuteTrainWithName: @"137" direction: EastDirection departureTime: [self scenarioTime: @"07:00"]]];
    [array addObject: [self createCommuteTrainWithName: @"139" direction: EastDirection departureTime: [self scenarioTime: @"07:55"]]];
    [array addObject: [self createCommuteTrainWithName: @"143" direction: EastDirection departureTime: [self scenarioTime: @"10:30"]]];

    [array addObject: [self createCommuteTrainWithName: @"108" direction: WestDirection departureTime: [self scenarioTime: @"06:30"]]];
    [array addObject: [self createCommuteTrainWithName: @"110" direction: WestDirection departureTime: [self scenarioTime: @"07:35"]]];
    [array addObject: [self createCommuteTrainWithName: @"112" direction: WestDirection departureTime: [self scenarioTime: @"08:50"]]];

    Train* passengerTrain;
    
    passengerTrain = [Train trainWithName: @"141" description: @"Del Monte"
                        direction: EastDirection
                            start:[self endpointWithName: @"From LA"]
                              end: [self endpointWithName: @"Diridon-1"]];
    [passengerTrain setAppearanceTime: [self scenarioTime: @"08:10"] departureTime: [self scenarioTime: @"08:20"] arrivalTime: [self scenarioTime: @"08:38"]];
    [array addObject: passengerTrain];
    
    // Train goes to Diridon, then continues.
    passengerTrain.script = [ChangeEndpoint changeEndpointTo:[self endpointWithName: @"To SF"] direction: EastDirection
                                             newName: @"141"
                                       departureTime: [self scenarioTime: @"08:50"] minimumWaitTime: 5 expectedTime: [self scenarioTime: @"09:10"]
                                             message: @"141 Ready to depart San Jose"];

    passengerTrain = [Train trainWithName: @"98" description: @"Coast Daylight"
                                 direction: WestDirection
                                    start: [self endpointWithName: @"From SF"] end: [self endpointWithName: @"Diridon-1"]];
    [passengerTrain setAppearanceTime: [self scenarioTime: @"07:45"] departureTime: [self scenarioTime: @"07:53" ] arrivalTime: [self scenarioTime: @"08:16"]];
    [array addObject: passengerTrain];
    passengerTrain.script = [ChangeEndpoint changeEndpointTo:[self endpointWithName: @"To LA"] direction: WestDirection
                                                     newName: @"98"
                                               departureTime: [self scenarioTime: @"08:16"] minimumWaitTime: 5 expectedTime: [self scenarioTime: @"08:30"]
                                                     message: @"98 Ready to depart San Jose"];
    
    passengerTrain = [Train trainWithName: @"75" description: @"Lark"
                                direction: EastDirection
                                    start:[self endpointWithName: @"From LA"]
                                      end: [self endpointWithName: @"Diridon-1"]];
    [passengerTrain setAppearanceTime: [self scenarioTime: @"05:35"] departureTime: [self scenarioTime: @"05:40"] arrivalTime: [self scenarioTime: @"05:55"]];
    [array addObject: passengerTrain];
    
    // Train goes to Diridon, then continues.
    passengerTrain.script = [ChangeEndpoint changeEndpointTo:[self endpointWithName: @"To SF"] direction: EastDirection
                                                     newName: @"75"
                                               departureTime: [self scenarioTime: @"06:13"] minimumWaitTime: 5 expectedTime: [self scenarioTime: @"06:35"]
                                                     message: @"75 Ready to depart San Jose"];
    
    
    Train* train2 = [Train trainWithName: @"X3274" description: @"freight"
                        direction: WestDirection
                            start: [self endpointWithName: @"From SF"]
                              end: [self endpointWithName: @"Hillsdale Branch"]];
    [train2 setAppearanceTime: [self scenarioTime: @"08:20"] departureTime: [self scenarioTime: @"08:30"] arrivalTime: [self scenarioTime: @"10:00"]];
    [array addObject: train2];
    
    train2 = [Train trainWithName: @"X3105" description: @"Permanente Turn"
                        direction: WestDirection
                            start: [self endpointWithName: @"From SF Frt"]
                              end: [self endpointWithName: @"Vasona Branch"]];
    [train2 setAppearanceTime: [self scenarioTime: @"10:00"] departureTime: [self scenarioTime: @"10:10"] arrivalTime: [self scenarioTime: @"11:00"]];
    [array addObject: train2];
    
    train2 = [Train trainWithName: @"31" description: @"Santa Cruz"
                        direction: EastDirection
                            start:[self endpointWithName: @"Vasona Branch"]
                              end: [self endpointWithName: @"Diridon-3"]];
    [train2 setAppearanceTime: [self scenarioTime: @"09:30"] departureTime: [self scenarioTime: @"09:40"] arrivalTime: [self scenarioTime: @"10:00"]];
    [array addObject: train2];
    
    // Train goes to Diridon, then continues.
    train2.script = [ChangeEndpoint changeEndpointTo: [self endpointWithName: @"Mulford"] direction: EastDirection
                                             newName: @"31"
                                       departureTime: [self scenarioTime: @"10:05"] minimumWaitTime: 5 expectedTime: [self scenarioTime: @"10:20"]
                                             message: @"31 Ready to depart San Jose"];

    train2 = [Train trainWithName: @"Perm" description: @"Permanente Local"
                        direction: EastDirection
                            start: [self endpointWithName: @"Vasona Branch"]
                              end: [self endpointWithName: @"To SF"]];
    [train2 setAppearanceTime: [self scenarioTime: @"10:15"] departureTime: [self scenarioTime: @"10:25"] arrivalTime: [self scenarioTime: @"11:00"]];
    [array addObject: train2];
    
    train2 = [Train trainWithName: @"933" description: @"Coast Merchandise"
                        direction: EastDirection
                            start: [self endpointWithName: @"From LA"]
                              end: [self endpointWithName: @"To SF"]];
    [train2 setAppearanceTime: [self scenarioTime: @"10:00"] departureTime: [self scenarioTime: @"10:10"] arrivalTime: [self scenarioTime: @"11:00"]];
    [array addObject: train2];
    

    
    self.all_trains = array;
    self.all_signals = [NSArray arrayWithObjects:
                               // station tracks east
                               [Signal signalControlling: EastDirection X: 19 Y: 2],
                               [Signal signalControlling: EastDirection X: 19 Y: 3],
                               [Signal signalControlling: EastDirection X: 19 Y: 4],
                               [Signal signalControlling: EastDirection X: 19 Y: 5],
                               // station tracks west
                               [Signal signalControlling: WestDirection X: 19 Y: 2],
                               [Signal signalControlling: WestDirection X: 19 Y: 3],
                               [Signal signalControlling: WestDirection X: 19 Y: 4],
                               [Signal signalControlling: WestDirection X: 19 Y: 5],
                               
                               [Signal signalControlling: EastDirection X: 10 Y: 1],
                               [Signal signalControlling: EastDirection X: 0 Y: 5],
                            // Hillsdale
                        [Signal signalControlling: EastDirection X: 0 Y: 2],

                               [Signal signalControlling: WestDirection X: 33 Y: 2],
                               [Signal signalControlling: WestDirection X: 33 Y: 3],

                               [Signal signalControlling: WestDirection X: 11 Y: 3],
                               [Signal signalControlling: WestDirection X: 11 Y: 4],
                               
                               [Signal signalControlling: WestDirection X: 6 Y: 4],
                               [Signal signalControlling: WestDirection X: 6 Y: 5],
                               [Signal signalControlling: EastDirection X: 6 Y: 4],
                               [Signal signalControlling: EastDirection X: 6 Y: 5],
 
                               [Signal signalControlling: WestDirection X: 24 Y: 2],
                               [Signal signalControlling: WestDirection X: 29 Y: 6],
                               nil];
}

- (void) initLabels {
    self.all_labels = [NSMutableArray arrayWithObjects:
                       [Label labelWithString: @"Cahill St. Station" X: 19 Y: 8],
                       [Label labelWithString: @"Valbrick" X: 6 Y: 7],
                       [Label labelWithString: @"Hillsdale" X: 1 Y: 7],
                       [Label labelWithString: @"San Jose" X: 19 Y: 7],
                       [Label labelWithString: @"Ice House" X: 30 Y: 6],
                       nil];
}

- (BOOL) isNamedPoint: (NamedPoint*) a sameAs: (NamedPoint*) b {
    // All Diridon tracks are equivalent.
    if (a == b) return YES;
    // For more realism, freights are allowed to use track 1, but not 2-4.
    if ([a.name hasPrefix: @"Diridon-"] && [b.name hasPrefix: @"Diridon-"]) return YES;
    return NO;
}


@end
