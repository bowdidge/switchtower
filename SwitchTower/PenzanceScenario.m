//
//  PenzanceSpecification.m
//  SwitchTower
//
//  Created by Robert Bowdidge on 9/12/13.
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

#import "PenzanceScenario.h"

#import"NamedPoint.h"
#import "Label.h"
#import "Signal.h"
#import "Train.h"

@implementation PenzanceScenario

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

//      /-      p   --
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


#define TILE_ROWS 9
#define TILE_COLUMNS 29

// Current track layout to draw.  See above for key of what the letters mean.
static char* cells =
    //  "01234567890123456789012345"
    "-----z                       \n"
    "      \\       Z-z    Z-.     \n"
    "-------p-q-Q-P---p--P--.  Z-.\n"
    "-------qPQ--p------------P--.\n"
    "      / Z-p--                \n"
    "-----v /                     \n"
    "    R-w                      \n"
    ".--v                         \n"
    "--w                          \n";

- (id) init {
    self = [super init];
    NSMutableArray *eps = [NSMutableArray array];
    NamedPoint *ep = [[NamedPoint alloc] init];
    ep.name = @"Up";
    ep.xPosition = 29;
    ep.yPosition = 3;
    [eps addObject: ep];
    
    ep = [[NamedPoint alloc] init];
    ep.name = @"Dn";
    ep.xPosition = 29;
    ep.yPosition = 4;
    [eps addObject: ep];
    [self initLabels];
    [self initTrains];
    [self initSignals];
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

- (Train*) createOutgoingHSRWithName:(NSString*) name withDeparture: (NSDate*) departure {
    Train *hsr = [Train trainWithName: @"HSR Coaches" description: @"Paddington HSR"
                        direction: WestDirection
                            start: [self endpointWithName: @"Coach Yard"] end: [self endpointWithName: @"Pass-2"]];
    [hsr setAppearanceTime: [departure dateByAddingTimeInterval: -50 * 60] departureTime: [departure dateByAddingTimeInterval: -30 * 60] arrivalTime: [departure dateByAddingTimeInterval: -10 * 60]];
    hsr.script = [ChangeEndpoint changeEndpointTo:[self endpointWithName: @"Up"] direction:EastDirection newName:name departureTime:departure minimumWaitTime:10 expectedTime:[departure dateByAddingTimeInterval: 10 * 60] message: @"HSR loading"];
    return hsr;

}

- (ChangeEndpoint*) createGoToCoachYard {
    return [ChangeEndpoint changeEndpointTo: [self endpointWithName: @"Coach Yard"] direction: EastDirection
                                    newName: @"Empty" departureTime: [self scenarioTime: @"08:00"] minimumWaitTime: 0 expectedTime: [self scenarioTime: @"23:59"] message:@"Remove empty coaches"];
}
- (void) initTrains {
    NSMutableArray *allTrains = [NSMutableArray array];
    Train *train2 = [Train trainWithName: @"Truro-u" description:@"Commute"
                               direction: EastDirection
                                   start: [self endpointWithName: @"Pass-1"] end: [self endpointWithName: @"Up"]];
    [train2 setAppearanceTime: [self scenarioTime: @"08:00"] departureTime: [self scenarioTime: @"08:50"] arrivalTime: [self scenarioTime: @"09:00"]];
    [allTrains addObject: train2];
    
 
    [allTrains addObject: [self createOutgoingHSRWithName: @"HSR Padd" withDeparture: [self scenarioTime: @"09:10"]]];

    train2 = [Train trainWithName: @"StErth" description: @""
                        direction: EastDirection
                            start: [self endpointWithName: @"Pass-2"] end: [self endpointWithName: @"Up"]];
    [train2 setAppearanceTime: [self scenarioTime: @"08:00"] departureTime: [self scenarioTime: @"08:10"] arrivalTime: [self scenarioTime: @"08:30"]];

    [allTrains addObject: [self createOutgoingHSRWithName: @"HSR Padd" withDeparture: [self scenarioTime: @"10:20"]]];
    [allTrains addObject: [self createOutgoingHSRWithName: @"HSR Newc" withDeparture: [self scenarioTime: @"10:50"]]];

    train2 = [Train trainWithName: @"Plymouth" description:@"p"
                               direction: EastDirection
                                   start: [self endpointWithName: @"Up"] end: [self endpointWithName: @"Pass-1"]];
    [train2 setAppearanceTime: [self scenarioTime: @"08:10"] departureTime: [self scenarioTime: @"08:30"] arrivalTime: [self scenarioTime: @"08:50"]];
    train2.script = [self createGoToCoachYard];
    [allTrains addObject: train2];

    
    self.all_trains = allTrains;
    
//    
//    if (time == 22) {
//        Train *train2 = [Train train];
//        train2.trainName = @"31";
//        train2.trainDescription = @"Del Monte";
//        train2.xPosition = 0;
//        train2.yPosition = 5;
//        train2.isWestbound = NO;
//        train2.startPoint = [self endpointWithName: @"Pass-2"];
//        train2.expectedEndPoint = [self endpointWithName: @"Down"];
//        [array addObject: train2];
//    }
//    
//    if (time % 40 == 10) {
//        Train *train2 = [Train train];
//        train2.trainName = [NSString  stringWithFormat: @"%d", (130 + time / 40) * 2 + 1];
//        train2.trainDescription = @"Commute";
//        train2.xPosition = 28;
//        train2.yPosition = 2;
//        train2.isWestbound = YES;
//        train2.startPoint = [self endpointWithName: @"Up"];
//        train2.expectedEndPoint = [self endpointWithName: @"Pass-1"];
//        [array addObject: train2];
//    }
//    
//    
//    if (time % 40 == 8) {
//        Train *train2 = [Train train];
//        train2.trainName = @"X2402";
//        train2.trainDescription = @"Engine";
//        train2.xPosition = 23;
//        train2.yPosition = 2;
//        train2.isWestbound = YES;
//        train2.startPoint = [self endpointWithName: @"Engine Terminal"];
//        train2.expectedEndPoint = [self endpointWithName: @"Freight"];
//        [array addObject: train2];
//    }
}

- (void) initLabels {
    self.all_endpoints  = [NSArray arrayWithObjects:
                       [NamedPoint namedPointWithName: @"Pass-1" X: 0 Y: 0],
                       [NamedPoint namedPointWithName: @"Pass-2" X: 0 Y: 2],
                       [NamedPoint namedPointWithName: @"Pass-3" X: 0 Y: 3],
                       [NamedPoint namedPointWithName: @"Pass-4" X: 0 Y: 5],
                       [NamedPoint namedPointWithName: @"Freight" X: 0 Y: 7],
                       [NamedPoint namedPointWithName: @"Up" X: 28 Y: 2],
                       [NamedPoint namedPointWithName: @"Engine Terminal" X: 23 Y: 2],
                       [NamedPoint namedPointWithName: @"Coach Yard" X: 23 Y: 1],
                       [NamedPoint namedPointWithName: @"Down" X: 28 Y: 3], nil];
    
    self.all_labels = [NSMutableArray array];
}

- (void) initSignals {
    self.all_signals = [NSMutableArray arrayWithObjects:
                        [Signal signalControlling: EastDirection X:0 Y:0],
                        [Signal signalControlling: EastDirection X:0 Y:2],
                        [Signal signalControlling: EastDirection X:0 Y:3],
                        [Signal signalControlling: EastDirection X:0 Y:5],
                        [Signal signalControlling: WestDirection X:14 Y:1],
                        [Signal signalControlling: WestDirection X:14 Y:2],
                        [Signal signalControlling: WestDirection X:23 Y:1],
                        [Signal signalControlling: WestDirection X:23 Y:2],
                        [Signal signalControlling: WestDirection X:27 Y:2],
                        [Signal signalControlling: WestDirection X:27 Y:3],
                        nil];
}

- (BOOL) isNamedPoint: (NamedPoint*) a sameAs: (NamedPoint*) b {
    // All Diridon tracks are equivalent.
    if (a == b) return YES;
    // For more realism, freights are allowed to use track 1, but not 2-4.
    if ([a.name hasPrefix: @"Pass-"] && [b.name hasPrefix: @"Pass-"]) return YES;
    return NO;
}


@end
