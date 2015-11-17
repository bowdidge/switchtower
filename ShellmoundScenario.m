//
//  ShellmoundScenario.m
//  SwitchTower
//
//  Created by bowdidge on 11/14/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <Foundation/Foundation.h>

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

#import "ShellmoundScenario.h"

#import "NamedPoint.h"
#import "Label.h"
#import "Signal.h"
#import "Train.h"

@implementation ShellmoundScenario


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


#define TILE_ROWS 7
#define TILE_COLUMNS 32

// Current track layout to draw.  See above for key of what the letters mean.
static char* cells =
//  "01234567890123456789012345"
"    Z----q-----Q-------Q----z   \n"
" .-P-qQ-Pq------pQ------pqQ--pq.\n"
" .-qP-QpPQ--z   Z-pQ---qP--pqP-.\n"
" .w    W--pz W-w Z--pQP----w    \n"
"            W---w     \\         \n"
"                       W-.      \n"
"                                ";

- (id) init {
    self = [super init];
    NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"Port Costa EB" X: 31 Y: 2]];
    [eps addObject: [NamedPoint namedPointWithName: @"Port Costa WB" X: 31 Y: 1]];
    [eps addObject: [NamedPoint namedPointWithName: @"Oak Pier EB" X: 1 Y: 2]];
    [eps addObject: [NamedPoint namedPointWithName: @"Oak Pier WB" X: 1 Y: 1]];
    [eps addObject: [NamedPoint namedPointWithName: @"Cedar Frt" X: 1 Y: 3]];

    [eps addObject: [NamedPoint namedPointWithName: @"Oak 16th 1" X: 14 Y: 4]];
    [eps addObject: [NamedPoint namedPointWithName: @"Oak 16th 2" X: 14 Y: 3]];
    
    [eps addObject: [NamedPoint namedPointWithName: @"Santa Fe" X: 25 Y: 5]];
    self.all_endpoints = eps;
    [self initTrains];
    [self initLabels];
    
    self.scenarioName = @"Oakland 16th Street Station";
    self.scenarioDescription = @"Handle the trains coming and going from the Oakland Pier in the 1930's. The Oakland Pier was the center for SP passenger operations on the east shore of San Francisco Bay, but all trains needed to stop at Oakland's official 16th Street station.  Freight trains needed to pass around the station, then take a separate line down Cedar Street to access the freight yards.";

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

- (NSDate*) startingTime {
    // TODO(bowdidge): Fix time zone.
    return [self scenarioTime: @"07:20"];
}

- (int) tickLengthInSeconds {
    return 30;
}

// Creates a commute train and the light engine movement before or after its arrival.
// The departure time represents the arrival/departure time at San Jose station; other movements
// are offsets from this.
- (Train *) createPassengerTrainWithName: (NSString*) name desc: (NSString*) desc direction: (enum TimetableDirection) direction
                         departureTime: (NSDate*) departureTime {
    Train *train = nil;
    if (direction == EastDirection) {
        // For an eastbound train, the train should be called at time leaving Oakland Pier,
        // arrive on the simulation within 3 min, and stop at 16th St. Oakland for 2 minutes
        // 7 minutes after departure time.  Should be at Shellmound within 15 min of leaving.
        train = [Train trainWithName: name description: desc
                           direction: direction
                               start: [self endpointWithName: @"Oak Pier EB"] end: [self endpointWithName: @"Oak 16th 1"]];
        [train setAppearanceTime: departureTime departureTime: [departureTime dateByAddingTimeInterval: 3 * 60] arrivalTime: [departureTime dateByAddingTimeInterval: 7 * 60]];
        
        train.script = [ChangeEndpoint changeEndpointTo: [self endpointWithName: @"Port Costa EB"]
                                              direction: EastDirection
                                                newName: name
                                          departureTime: [departureTime dateByAddingTimeInterval: 7 * 60] minimumWaitTime: 2 expectedTime: [departureTime dateByAddingTimeInterval: 15 * 60]
                                                message:
                        [NSString stringWithFormat: @"Train %@ departing 16th St.", name]];
    } else if (direction == WestDirection) {
        // For an westbound train, the train should be called at time leaving Oakland Pier - 15,
        // arrive on the simulation within 5 min, and stop at 16th St. Oakland for 2 minutes
        // 10 minutes after departure time.  Should be at Oak Pier EB within 15 min of leaving.
        train = [Train trainWithName: name description: desc
                           direction: direction
                               start: [self endpointWithName: @"Port Costa WB"] end: [self endpointWithName: @"Oak 16th 2" ]];
        [train setAppearanceTime: [departureTime dateByAddingTimeInterval: -15 * 60]
                   departureTime: [departureTime dateByAddingTimeInterval: -12 * 60]
                     arrivalTime: [departureTime dateByAddingTimeInterval: -10 * 60]];
        
        train.script = [ChangeEndpoint changeEndpointTo: [self endpointWithName: @"Oak Pier WB"]
                                              direction: WestDirection
                                                newName: name
                                          departureTime: [departureTime dateByAddingTimeInterval: -5 * 60] minimumWaitTime: 2 expectedTime: [departureTime dateByAddingTimeInterval: -2 * 60]
                                                message:
                        [NSString stringWithFormat: @"Train %@ departing 16th St.", name]];
    } else {
        return nil;
    }
    train.onTimetable = true;
    return train;
}


// Creates all the trains neeeed in the scenario.
- (void) initTrains {
    NSMutableArray *array = [NSMutableArray array];
    // From Western Division timetable 241, June 2, 1946.
    [array addObject: [self createPassengerTrainWithName: @"224"
                                                    desc: @"Senator"
                                               direction: EastDirection
                                           departureTime: [self scenarioTime: @"07:56"]]];
    [array addObject: [self createPassengerTrainWithName: @"52"
                                                    desc: @"San Joaquin Daylight"
                                               direction: EastDirection
                                           departureTime: [self scenarioTime: @"08:25"]]];
    [array addObject: [self createPassengerTrainWithName: @"56"
                                                    desc: @"Passenger"
                                               direction: EastDirection
                                           departureTime: [self scenarioTime: @"08:25"]]];
    [array addObject: [self createPassengerTrainWithName: @"21"
                                                    desc: @"Pacific Limited"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"07:30"]]];
    [array addObject: [self createPassengerTrainWithName: @"23"
                                                    desc: @"Challenger"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"07:35"]]];
    [array addObject: [self createPassengerTrainWithName: @"19"
                                                    desc: @"Klamath"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"07:40"]]];
    [array addObject: [self createPassengerTrainWithName: @"57"
                                                    desc:@"Owl"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"08:15"]]];
    [array addObject: [self createPassengerTrainWithName: @"101"
                                                    desc: @"City of San Francisco"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"08:40"]]];
    [array addObject: [self createPassengerTrainWithName: @"247"
                                                    desc: @"El Dorado"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"09:23"]]];
    [array addObject: [self createPassengerTrainWithName: @"56"
                                                    desc: @"Passenger"
                                               direction: EastDirection
                                           departureTime: [self scenarioTime: @"10:35"]]];
    [array addObject: [self createPassengerTrainWithName: @"28"
                                                    desc: @"Overland Limited"
                                               direction: EastDirection
                                           departureTime: [self scenarioTime: @"12:01"]]];
    [array addObject: [self createPassengerTrainWithName: @"246"
                                                    desc: @"Statesman"
                                               direction: EastDirection
                                           departureTime: [self scenarioTime: @"14:00"]]];
    [array addObject: [self createPassengerTrainWithName: @"11"
                                                    desc: @"Cascade"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"10:50"]]];
    [array addObject: [self createPassengerTrainWithName: @"13"
                                                    desc: @"Beaver"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"11:10"]]];
    [array addObject: [self createPassengerTrainWithName: @"27"
                                                    desc: @"Overland Limited"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"14:20"]]];
    [array addObject: [self createPassengerTrainWithName: @"465"
                                                    desc: @"Freight"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"14:00"]]];
    [array addObject: [self createPassengerTrainWithName: @"465"
                                                    desc: @"Freight"
                                               direction: WestDirection
                                           departureTime: [self scenarioTime: @"14:00"]]];

   
    Train *sf = [Train trainWithName: @"SF 1" description: @"Super Chief"
                           direction: WestDirection
                               start: [self endpointWithName: @"Santa Fe"]
                                 end: [self endpointWithName: @"Oak Pier WB"]];
    [sf setAppearanceTime: [self scenarioTime: @"08:40" ]
            departureTime: [self scenarioTime: @"08:45"]
              arrivalTime: [self scenarioTime: @"09:00"]];
    sf.onTimetable = true;
    [array addObject: sf];
    
    Train *frt = [Train trainWithName: @"X2765" description: @"Berkeley Switcher"
                            direction: WestDirection
                                start: [self endpointWithName: @"Port Costa WB"]
                                  end: [self endpointWithName: @"Cedar Frt"]];
    [frt setAppearanceTime: [self scenarioTime: @"7:35"] departureTime: [self scenarioTime: @"07:40"] arrivalTime: [self scenarioTime: @"08:20"]];
    [array addObject: frt];
    
    frt = [Train trainWithName: @"464" description: @"Freight"
                            direction: EastDirection
                                start: [self endpointWithName: @"Cedar Frt"]
                                  end: [self endpointWithName: @"Port Costa EB"]];
    [frt setAppearanceTime: [self scenarioTime: @"08:05"] departureTime: [self scenarioTime: @"08:10"] arrivalTime: [self scenarioTime: @"09:00"]];
    [array addObject: frt];

    frt = [Train trainWithName: @"X3921" description: @"Freight"
                     direction: EastDirection
                         start: [self endpointWithName: @"Cedar Frt"]
                           end: [self endpointWithName: @"Port Costa EB"]];
    [frt setAppearanceTime: [self scenarioTime: @"8:45"] departureTime: [self scenarioTime: @"08:55"] arrivalTime: [self scenarioTime: @"09:30"]];
    [array addObject: frt];
    
    frt = [Train trainWithName: @"X2765" description: @"Richmond Switcher"
                            direction: WestDirection
                                start: [self endpointWithName: @"Port Costa WB"]
                                  end: [self endpointWithName: @"Cedar Frt"]];
    [frt setAppearanceTime: [self scenarioTime: @"09:10"] departureTime: [self scenarioTime: @"09:15"] arrivalTime: [self scenarioTime: @"10:00"]];
    [array addObject: frt];

    frt = [Train trainWithName: @"X3225" description: @"Santa Fe interchange"
                            direction: WestDirection
                                start: [self endpointWithName: @"Port Costa WB"]
                                  end: [self endpointWithName: @"Cedar Frt"]];
    [frt setAppearanceTime: [self scenarioTime: @"09:20"] departureTime: [self scenarioTime: @"09:30"] arrivalTime: [self scenarioTime: @"10:00"]];
    [array addObject: frt];

    frt = [Train trainWithName: @"X3221" description: @"Vallejo turn"
                     direction: EastDirection
                         start: [self endpointWithName: @"Port Costa WB"]
                           end: [self endpointWithName: @"Cedar Frt"]];
    [frt setAppearanceTime: [self scenarioTime: @"09:40"] departureTime: [self scenarioTime: @"09:50"] arrivalTime: [self scenarioTime: @"10:30"]];
    [array addObject: frt];

    self.all_trains = array;
    self.all_signals = [NSArray arrayWithObjects:
                        // Port Costa entrance.
                        [Signal signalControlling: WestDirection X: 31 Y: 1],
                        // Oak pier and Cedar Frt.
                        [Signal signalControlling: EastDirection X: 1 Y: 2],
                        [Signal signalControlling: EastDirection X: 1 Y: 3],

                        // Dwarfs for 16th St.
                        [Signal signalControlling: WestDirection X: 14 Y: 3],
                        [Signal signalControlling: EastDirection X: 14 Y: 3],
                        [Signal signalControlling: WestDirection X: 14 Y: 4],
                        [Signal signalControlling: EastDirection X: 14 Y: 4],
                        
                        // Santa Fe.
                        [Signal signalControlling: WestDirection X: 25 Y: 5],

                        // Interlocking at west end.
                        [Signal signalControlling: WestDirection X: 11 Y: 0],
                        [Signal signalControlling: WestDirection X: 11 Y: 1],
                        [Signal signalControlling: WestDirection X: 11 Y: 2],
                        [Signal signalControlling: WestDirection X: 11 Y: 3],
                        [Signal signalControlling: WestDirection X: 8 Y: 3],
                        
                        // Interlocking east end.
                        [Signal signalControlling: EastDirection X: 14 Y: 0],
                        [Signal signalControlling: EastDirection X: 15 Y: 1],
                        [Signal signalControlling: EastDirection X: 15 Y: 1],
nil];
}

- (void) initLabels {
    self.all_labels = [NSMutableArray arrayWithObjects:
                       [Label labelWithString: @"16th St Station" X: 15 Y: 6],
                       [Label labelWithString: @"Oak Pier Tower" X: 1 Y: 5],
                       [Label labelWithString: @"Shellmound Tower" X: 27 Y: 5],
                       nil];
}

- (BOOL) isNamedPoint: (NamedPoint*) a sameAs: (NamedPoint*) b {
    if (a == b) return YES;
    // Any Oakland station track ok.
    if ([a.name hasPrefix: @"Oak 16th"] && [b.name hasPrefix: @"Oak 16th"]) return YES;
    return NO;
}


@end
