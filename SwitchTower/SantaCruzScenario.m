//
//  SantaCruzScenario.m
//  SwitchTower
//
//  Created by bowdidge on 11/15/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SantaCruzScenario.h"

#import "NamedPoint.h"
#import "Label.h"
#import "Signal.h"
#import "Train.h"

@implementation SantaCruzScenario

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


#define TILE_ROWS 4
#define TILE_COLUMNS 46

// Current track layout to draw.  See above for key of what the letters mean.
static char* cells =
//  "01234567890123456789012345"

"                                               \n"
" --q-Q---q-Q-----q-Q---q-Q---q-Q---q--Q---q--- \n"
" -w   W-w   W- -w   W-w   W-w   W-w    W-w     \n"
"                                               \n";

- (id) init {
    self = [super init];
    NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"San Jose WB" X: 1 Y: 1]];
    [eps addObject: [NamedPoint namedPointWithName: @"San Jose EB" X: 1 Y: 2]];
    [eps addObject: [NamedPoint namedPointWithName: @"Santa Cruz" X: 45 Y: 1]];
    self.all_endpoints = eps;
    [self initTrains];
    [self initLabels];
    self.scenarioName = @"SP Santa Cruz branch";
    self.scenarioDescription = @"Run trains across the Santa Cruz mountains.";
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
    // Assume all scenarios start at 6:00 am.
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
                               start: [self endpointWithName: @"San Jose EB"] end: [self endpointWithName: @"Santa Cruz"]];
        [train setAppearanceTime: departureTime departureTime: [departureTime dateByAddingTimeInterval: 3 * 60] arrivalTime: [departureTime dateByAddingTimeInterval: 7 * 60]];
    } else if (direction == WestDirection) {
        // For an westbound train, the train should be called at time leaving Oakland Pier - 15,
        // arrive on the simulation within 5 min, and stop at 16th St. Oakland for 2 minutes
        // 10 minutes after departure time.  Should be at Oak Pier EB within 15 min of leaving.
        train = [Train trainWithName: name description: desc
                           direction: direction
                               start: [self endpointWithName: @"Santa Cruz"] end: [self endpointWithName: @"San Jose WB" ]];
        [train setAppearanceTime: [departureTime dateByAddingTimeInterval: -15 * 60]
                   departureTime: [departureTime dateByAddingTimeInterval: -12 * 60]
                     arrivalTime: [departureTime dateByAddingTimeInterval: -10 * 60]];
    } else {
        return nil;
    }
    return train;
}


- (void) initTrains {
    NSMutableArray *array = [NSMutableArray array];
    // From Western Division timetable 241, June 2, 1946.
    [array addObject: [self createPassengerTrainWithName: @"31"
                                                    desc: @"Santa Cruz Passenger"
                                               direction: EastDirection
                                           departureTime: [self scenarioTime: @"07:20"]]];

    Train *frt = [Train trainWithName: @"X2765" description: @"Vasona Turn"
                            direction: WestDirection
                                start: [self endpointWithName: @"San Jose EB"]
                                  end: [self endpointWithName: @"Santa Cruz"]];
    [frt setAppearanceTime: [self scenarioTime: @"07:05"] departureTime: [self scenarioTime: @"07:10"] arrivalTime: [self scenarioTime: @"08:00"]];
    [array addObject: frt];
    
    self.all_trains = array;
    self.all_signals = [NSArray arrayWithObjects:
                        // Port Costa entrance.
                        [Signal signalControlling: WestDirection X: 45 Y: 1],
                        // Oak pier and Cedar Frt.
                        [Signal signalControlling: EastDirection X: 1 Y: 2],

                        [Signal signalControlling: WestDirection X: 7 Y: 1],
                        [Signal signalControlling: EastDirection X: 7 Y: 1],
                        [Signal signalControlling: WestDirection X: 7 Y: 2],
                        [Signal signalControlling: EastDirection X: 7 Y: 2],

                        [Signal signalControlling: WestDirection X: 13 Y: 1],
                        [Signal signalControlling: WestDirection X: 13 Y: 2],
                        [Signal signalControlling: EastDirection X: 15 Y: 1],
                        [Signal signalControlling: EastDirection X: 15 Y: 2],
                        
                        [Signal signalControlling: WestDirection X: 21 Y: 1],
                        [Signal signalControlling: EastDirection X: 21 Y: 1],
                        [Signal signalControlling: WestDirection X: 21 Y: 2],
                        [Signal signalControlling: EastDirection X: 21 Y: 2],
nil];
}

- (void) initLabels {
    self.all_labels = [NSMutableArray arrayWithObjects:
                       [Label labelWithString: @"Campbell" X: 4 Y: 3],
                       [Label labelWithString: @"Vasona Junction" X: 14 Y: 3],
                       [Label labelWithString: @"Los Gatos" X: 21 Y: 3],
                       [Label labelWithString: @"Alma" X: 27 Y: 3],
                       [Label labelWithString: @"Glenwood" X: 33 Y: 3],
                       [Label labelWithString: @"Felton" X: 40 Y: 3],
                       nil];
}

@end