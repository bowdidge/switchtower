//
//  LayoutModel.h
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

// Holds knowledge of the current state of the railroad - switch position, current routes set, and train locations.
// Provides functions for moving specific trains under the control of the ViewController.

#import <Foundation/Foundation.h>

#import "Signal.h"

@class NamedPoint;
@class Scenario;
@class Train;

typedef enum {
    North,
    Northeast,
    East,
    Southeast,
    South,
    Southwest,
    West,
    Northwest,
    Center
} TrackDirection;

// Class that encapsulates the current state of the scenario.
@interface LayoutModel : NSObject {
    // Array indicating for each row and cell which route uses that cell.
    // Routes are integers; cells on the same route with the same route id should
    // be colored identically.
    // TODO(bowdidge): Replace with dynamically allocated array.
    int routeSelection[50][50];
    int routeCount;
}
// Only used for occupying.
@property(nonatomic, retain) NSMutableArray *activeTrains;

// Doesn't need to be public.
@property(nonatomic, retain) NSMutableDictionary *switchPositionDictionary;
@property(nonatomic, retain) Scenario *scenario;

- (id) initWithScenario: (Scenario*) s;

// Register a new train to display that will be active on the layout.
- (void) addActiveTrain: (Train*) train;

// Returns true if the cell is a known starting or ending space for trains.
- (BOOL) isEndPoint: (struct CellPosition) pos;

// Returns named point object if location is named.
- (NamedPoint*) isNamedPoint: (struct CellPosition) pos;

// Returns the signal at the specified cell, or nil if none exists.
- (Signal*)signalAtCell: (struct CellPosition) pos direction: (enum TimetableDirection) dir;
- (BOOL) cellIsSwitch: (struct CellPosition) pos;


// Returns the train at the named cell, or nil if none exists.
- (Train*)occupyingTrainAtCell: (struct CellPosition) pos;

// Returns the direction for one end of the track at the specified cell.
// For switches, returns the points-end (not the diverging end.
// TODO(bowdidge): Why do signal objects have state, but switches have state stored here?
- (BOOL)isSwitchNormal: (struct CellPosition) pos;
- (TrackDirection)pointsDirectionForCell: (struct CellPosition) pos;
- (TrackDirection)normalDirectionForCell: (struct CellPosition) pos;

// False if switch can't be changed.
- (BOOL) setSwitchPosition: (struct CellPosition) pos isNormal: (BOOL) isNormal;

- (void)clearRoute;
- (BOOL)selectRouteAtCell: (struct CellPosition) pos direction: (enum TimetableDirection)direction;
- (int) routeForCell: (struct CellPosition) pos;

// Returns false if train couldn't move.
- (BOOL) moveTrainWest: (Train*) name;
- (BOOL) moveTrainEast: (Train*) name;


@end
