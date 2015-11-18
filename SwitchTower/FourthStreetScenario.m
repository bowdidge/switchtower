//
//  FourthStreetSpecification.m
//  SwitchTower
//
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

// Sample scenario configuration for the San Jose Market Street station and Fourth
// Street tower.  The small station was on the San Francisco-Los Angeles line,
// and had a sharp curve on the east end and a ton of commute trains on the west end.

#import "FourthStreetScenario.h"

#import"NamedPoint.h"
#import "Train.h"

@implementation FourthStreetScenario
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


#define TILE_ROWS 6
#define TILE_COLUMNS 23

// Current track layout to draw.  See above for key of what the letters mean.
static char* cells =
//  "0123456789012345678901234"
    "   --z                 \n"
    "  --z \\           Z--- \n"
    "-Q--qp-p-Q----=--Y     \n"
    "--pPQ-----pQ--=---r    \n"
    "     \\      W-=----r   \n"
    "      W--           W- ";

- (id) init {
    [super init];
    [self initTrains];
    
    self.scenarioName = @"San Jose Market St. Station";
    self.scenarioDescription = @"Handle the comings and goings of the Southern Pacific's San Francisco->San Jose commute fleet in the early 1920's.  The setting here is SP's long-lost Market Street station, just north of downtown San Jose.  In this simulation, you'll need to thread long-distance trains past the two-track 1880's station.";

    return self;
}

- (int) tileRows {
    return TILE_ROWS;
}

- (int) tileColumns {
    return TILE_COLUMNS;
}

- (const char*) rawTileString {
    return cells;
}


// Should just reverse some trains.
- (Train *) createCommuteTrainWithName: (NSString*) name direction: (enum TimetableDirection) direction
                         departureTime: (NSDate*) departureTime {
    Train *train;
    NamedPoint *toSF = [self endpointWithName: @"To SF"];
    NamedPoint *fromSF = [self endpointWithName: @"From SF"];
    // TODO(bowdidge): Be able to go to any track.
    NamedPoint *station = [self endpointWithName: @"Market-2"];
    NamedPoint *engineService = [self endpointWithName: @"Coach Yard"];
    
    if (direction == EastDirection) {
        train = [Train trainWithName: name description: @"Commute"
                           direction: EastDirection
                               start: fromSF end: station];
        [train setDepartureTime: [departureTime dateByAddingTimeInterval: -15 * 60] arrivalTime: departureTime];
        train.becomesTrains = [NSArray arrayWithObjects:
                               [NSString stringWithFormat: @"cars from %@", name],
                               [NSString stringWithFormat: @"engine from %@", name],
                               nil];
        // Create those trains.

    } else {
        train = [Train trainWithName: @"empty" description: @"Commute"
                           direction: EastDirection
                               start: engineService end: station];
        // have train ready 20 counts before.
        [train setDepartureTime: [departureTime dateByAddingTimeInterval: -25 * 60] arrivalTime: [departureTime dateByAddingTimeInterval: -15 * 60]];
        train.becomesTrains = [NSArray arrayWithObject: name];
        // Create those trains.
    }
    return train;
}

- (Train*) createThroughTrainName: (NSString*) name
                      description: (NSString*) description
                        direction: (enum TimetableDirection) direction
                      arrivalTime: (NSDate*) arrivalTime
                            start: (NamedPoint*) start
                              end: (NamedPoint*) end {
    Train *throughTrain = [Train trainWithName: name description: description direction: direction
                                         start: start
                                           end: [self endpointWithName: @"Market-3"]];
    [throughTrain setDepartureTime: [arrivalTime dateByAddingTimeInterval: -10 * 60]
                       arrivalTime: arrivalTime];
// Need passenger schedule.
    return throughTrain;
}

- (void) initTrains {
    NSMutableArray *array = [NSMutableArray array];
    
    self.all_endpoints = [NSArray arrayWithObjects:
                          [NamedPoint namedPointWithName: @"From SF" X: 0 Y: 3],
                          [NamedPoint namedPointWithName: @"To SF" X: 0 Y: 2],
                          [NamedPoint namedPointWithName: @"Oakland" X: 21 Y: 1],
                          [NamedPoint namedPointWithName: @"LA" X: 21 Y: 5],
                          [NamedPoint namedPointWithName: @"Coach Yard" X: 2 Y: 1],
                          [NamedPoint namedPointWithName: @"Freight Yard" X: 3 Y: 0],
                          [NamedPoint namedPointWithName: @"Santa Cruz" X: 8 Y: 5],
                          [NamedPoint namedPointWithName: @"Market-1" X: 15 Y: 2],
                          [NamedPoint namedPointWithName: @"Market-2" X: 15 Y: 3],
                          [NamedPoint namedPointWithName: @"Market-3" X: 15 Y: 4],
                          nil];
    self.all_signals = [NSArray arrayWithObjects:
                        [Signal signalControlling: WestDirection X: 21 Y: 5],
                        [Signal signalControlling: WestDirection X: 21 Y: 1],

                        [Signal signalControlling: WestDirection X: 15 Y: 2],
                        [Signal signalControlling: WestDirection X: 15 Y: 3],
                        [Signal signalControlling: WestDirection X: 15 Y: 4],
                        [Signal signalControlling: EastDirection X: 15 Y: 2],
                        [Signal signalControlling: EastDirection X: 15 Y: 3],
                        [Signal signalControlling: EastDirection X: 15 Y: 4],

                        [Signal signalControlling: EastDirection X: 0 Y: 3],
                        [Signal signalControlling: WestDirection X: 8 Y: 5],

                        [Signal signalControlling: EastDirection X: 2 Y: 1],
                        [Signal signalControlling: EastDirection X: 3 Y: 0],
                       nil];

    array = [NSMutableArray array];
    [array addObject: [self createThroughTrainName: @"98"
                                       description: @"Morning Daylight"
                                         direction: EastDirection
                                       arrivalTime: [self scenarioTime: @"09:00"]
                                             start: [self endpointWithName: @"From SF"]
                                               end: [self endpointWithName: @"LA"]]];
    [array addObject: [self createThroughTrainName: @"75" description: @"Lark" direction: WestDirection arrivalTime: [self scenarioTime: @"09:00"]
                                              start: [self endpointWithName: @"LA"] end: [self endpointWithName: @"To SF"]]];
     [array addObject: [self createThroughTrainName: @"77" description: @"Sunset Limited" direction: WestDirection arrivalTime: [self scenarioTime: @"07:00"]
                                              start: [self endpointWithName: @"LA"] end: [self endpointWithName: @"To SF"]]];


    [array addObject: [self createCommuteTrainWithName: @"111" direction:WestDirection departureTime:[self scenarioTime: @"06:15"]]];
    [array addObject: [self createCommuteTrainWithName: @"115" direction:WestDirection departureTime:[self scenarioTime: @"06:30"]]];
    [array addObject: [self createCommuteTrainWithName: @"117" direction:WestDirection departureTime:[self scenarioTime: @"06:40"]]];
    [array addObject: [self createCommuteTrainWithName: @"121" direction:WestDirection departureTime:[self scenarioTime: @"07:10"]]];
    [array addObject: [self createCommuteTrainWithName: @"129" direction:WestDirection departureTime:[self scenarioTime: @"07:15"]]];
    [array addObject: [self createCommuteTrainWithName: @"131" direction:WestDirection departureTime:[self scenarioTime: @"07:30"]]];
    [array addObject: [self createCommuteTrainWithName: @"133" direction:WestDirection departureTime:[self scenarioTime: @"07:58"]]];
    [array addObject: [self createCommuteTrainWithName: @"135" direction:WestDirection departureTime:[self scenarioTime: @"08:40"]]];

    [array addObject: [self createCommuteTrainWithName: @"108" direction:EastDirection departureTime:[self scenarioTime: @"07:45"]]];
    [array addObject: [self createCommuteTrainWithName: @"110" direction:EastDirection departureTime:[self scenarioTime: @"08:30"]]];
    [array addObject: [self createCommuteTrainWithName: @"112" direction:EastDirection departureTime:[self scenarioTime: @"11:00"]]];

    self.all_trains = array;
    

}

- (NSDate*) startingTime {
    // Assume all scenarios start at 6:00 am.
    // TODO(bowdidge): Fix time zone.
    return [self scenarioTime: @"06:02"];
}

- (int) tickLengthInSeconds {
    return 20;
}


- (BOOL) isNamedPoint: (NamedPoint*) a sameAs: (NamedPoint*) b {
    // All Market Street station tracks are equivalent.
    if (a == b) return YES;
    // For more realism, freights are allowed to use track 1, but not 2-4.
    if ([a.name hasPrefix: @"Market-"] && [b.name hasPrefix: @"Market-"]) return YES;
    return NO;
}


@end
