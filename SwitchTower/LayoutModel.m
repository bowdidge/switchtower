//
//  LayoutModel.m
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

#import "LayoutModel.h"

#import "NamedPoint.h"
#import "Scenario.h"
#import "Signal.h"
#import "Train.h"

@implementation LayoutModel

- (id) initWithScenario: (Scenario*) s{
    [super init];
    self.activeTrains = [NSMutableArray array];
    self.switchPositionDictionary = [NSMutableDictionary dictionary];
    routeCount = 0;
    self.scenario = s;
    return self;
}

// Register a new train to display.
- (void) addActiveTrain: (Train*) train {
    [self.activeTrains addObject: train];
}

- (void) clearRoute {
    routeCount = 0;
    int rows = self.scenario.tileRows;
    int columns = self.scenario.tileColumns;
    for (int x=0; x<columns; x++) {
        for (int y = 0; y < rows; y++) {
            routeSelection[x][y] = 0;
        }
    }
}

- (int) routeForCell: (struct CellPosition) pos {
    return routeSelection[pos.x][pos.y];
}

- (BOOL) selectRouteAtCell: (struct CellPosition) pos direction: (enum TimetableDirection) direction {
    int currentRoute = routeSelection[pos.x][pos.y];
    if (currentRoute == 0) {
        currentRoute = ++routeCount;
    }
    struct CellPosition origPos = pos;
    
    while (1) {
        Signal *theSignal = [self signalAtCell: pos direction: direction];
        if (theSignal && theSignal.trafficDirection == direction && !theSignal.isGreen) break;

        struct CellPosition newPos = pos;
        if (direction == EastDirection) {
            if (![self nextCellEast: pos returns: &newPos]) break;
        } else {
            if (![self nextCellWest: pos returns: &newPos]) break;
        }
        if (newPos.x == pos.x && newPos.y == pos.y) break;
        // Don't set route yet.
        pos = newPos;
    }
    
    // Now, do again and set route.
    pos = origPos;

    // TODO(bowdidge): Remove duplicated code.
    while (1) {
        Signal *theSignal = [self signalAtCell: pos direction: direction];
        if (theSignal && theSignal.trafficDirection == direction && !theSignal.isGreen) break;
        
        struct CellPosition newPos = pos;
        if (direction == EastDirection) {
            [self nextCellEast: pos returns: &newPos];
        } else {
            [self nextCellWest: pos returns: &newPos];
        }
        if (newPos.x == pos.x && newPos.y == pos.y) break;
        routeSelection[newPos.x][newPos.y] = currentRoute;
        pos = newPos;
    }
    return YES;
}

- (Signal*) signalAtCell: (struct CellPosition) pos direction: (enum TimetableDirection) dir{
    for (Signal* signal in self.scenario.all_signals) {
        if (signal.position.x == pos.x && signal.position.y == pos.y && signal.trafficDirection == dir) {
            return signal;
        }
    }
    return NULL;
}

- (TrackDirection) pointsDirectionForCell: (struct CellPosition) pos {
    char cell = [self.scenario tileAtCell: pos];
    switch (cell) {
        case 'P':
            return West;
        case 'p':
            return East;
        case 'Q':
            return West;
        case 'q':
            return East;
        case 'R':
            return Southwest;
        case 'r':
            return Southeast;
        case 'V':
            return Northwest;
        case 'v':
            return Northeast;
        case 'Y':
            return West;
        case 'y':
            return East;
    }
    return Center;
}

- (BOOL) isEndPoint: (struct CellPosition) pos {
    // Consider T to be stopping but not endpoint.
    return [self.scenario tileAtCell: pos] == '.';
}


// Returns true if the cell is a known starting or ending space for trains.
- (NamedPoint*) isNamedPoint: (struct CellPosition) pos {
    for (NamedPoint *ep in [self.scenario all_endpoints]) {
        if (ep.position.x == pos.x && ep.position.y == pos.y) {
            return ep;
        }
    }
    return nil;
}

// Returns true if the switch is in the normal position.
// TODO(bowdidge): Need better data structure.
// Currently, a dictionary is used to note the cells where switches are reversed.  Nonexistence of a
// switch in the dictionary means it's normal, or it's not a switch.
- (BOOL) isSwitchNormal: (struct CellPosition) pos {
    NSArray *posArray = [NSArray arrayWithObjects: [NSNumber numberWithInt: pos.x],
                    [NSNumber numberWithInt: pos.y], nil];
    if ([self.switchPositionDictionary objectForKey: posArray]) {
        return NO;
    }
    return YES;
}

- (TrackDirection) normalDirectionForCell: (struct CellPosition) pos {
    char cell = [self.scenario tileAtCell: pos];
    switch (cell) {
        case 'P':
            return East;
        case 'p':
            return West;
        case 'Q':
            return East;
        case 'q':
            return West;
        case 'R':
            return Northeast;
        case 'r':
            return Northwest;
        case 'V':
            return Southeast;
        case 'v':
            return Southwest;
        case 'Y':
            return Northeast;
        case 'y':
            return Northwest;
    }
    return Center;
}

// Returns the train currently occupying the named cell, or nil if none exists.
- (Train*) occupyingTrainAtCell: (struct CellPosition) pos {
    for (Train *train in self.activeTrains) {
        if (pos.x == train.position.x && pos.y == train.position.y) {
            return train;
        }
    }
    return nil;
}

- (TrackDirection) incomingDirectionWhenMovingFrom: (struct CellPosition) start to: (struct CellPosition) end {
    if (start.x < end.x) {
        if (start.y < end.y) {
            return Northwest;
        } else if (start.y == end.y) {
            return West;
        } else {
            return Southwest;
        }
    } else if (start.x == end.x) {
        if (start.y < end.y) {
            return North;
        } else if (start.y == end.y) {
            return Center;
        } else {
            return South;
        }
    } else {
        if (start.y < end.y) {
            return Northeast;
        } else if (start.y == end.y) {
            return East;
        } else {
            return Southeast;
        }
    }
    return Center;
}

// Returns true if the cell at (cellX, cellY) is a switch icon and routes the
// train in multiple directions.
- (BOOL) cellIsSwitch: (struct CellPosition) pos {
    if (pos.x < 0 || pos.x >= self.scenario.tileColumns || pos.y < 0 || pos.y >= self.scenario.tileRows) {
        return NO;
    }
    char cell = [self.scenario tileAtCell: pos];
    switch (cell) {
        case 'P':
        case 'p':
        case 'Q':
        case 'q':
        case 'R':
        case 'r':
        case 'y':
        case 'Y':
        case 'V':
        case 'v':
            return YES;
    }
    return NO;
}


// Changes the switch's memorized location.
- (BOOL) setSwitchPosition: (struct CellPosition) pos isNormal: (BOOL) isNormal {
    if (routeSelection[pos.x][pos.y] != 0) {
        return NO;
    }
    NSArray *posArray = [NSArray arrayWithObjects: [NSNumber numberWithInt: pos.x],
                    [NSNumber numberWithInt: pos.y], nil];
    if (isNormal) {
        [self.switchPositionDictionary removeObjectForKey: posArray];
    } else {
        [self.switchPositionDictionary setObject: [NSNumber numberWithInt: 0] forKey: posArray];
    }
    return YES;
}


- (BOOL) allowedToTravelFrom: (struct CellPosition) fromPos to: (struct CellPosition) toPos {
    
    TrackDirection incoming = [self incomingDirectionWhenMovingFrom: fromPos to: toPos];
    if ([self pointsDirectionForCell: toPos] == incoming) {
        return YES;
    } else if ([self normalDirectionForCell: toPos] == incoming) {
        return [self isSwitchNormal: toPos];
    } else {
        return ![self isSwitchNormal: toPos];
    }
    return NO;
}


- (BOOL) nextCellWest: (struct CellPosition) fromPos returns: (struct CellPosition*) toPos {
    struct CellPosition oldPos = fromPos;

    Signal *theSignal = [self signalAtCell: fromPos direction: WestDirection];
    if (theSignal && theSignal.trafficDirection == WestDirection && !theSignal.isGreen) return NO;
    
    switch ([self.scenario tileAtCell: fromPos]) {
        case 'q':
            if ([self isSwitchNormal: fromPos]) {
                fromPos.x--;
            } else {
                fromPos.x--;
                fromPos.y++;
            }
            break;
        case 'p':
            if ([self isSwitchNormal: fromPos]) {
                fromPos.x--;
            } else {
                fromPos.x--;
                fromPos.y--;
            }
            break;
        case 'y':
            if ([self isSwitchNormal: fromPos]) {
                fromPos.x--;
                fromPos.y--;
            } else {
                fromPos.x--;
                fromPos.y++;
            }
            break;
        case 'v':
            if ([self isSwitchNormal: fromPos]) {
                fromPos.x--;
                fromPos.y++;
            } else {
                fromPos.x--;
            }
            break;
        case 'r':
            if ([self isSwitchNormal: fromPos]) {
                fromPos.x--;
                fromPos.y--;
            } else {
                fromPos.x--;
            }
            break;
        case '-':
        case '.':
        case '=':
        case 'z':
        case 'w':
        case 'P':
        case 'Q':
        case 't':
        case 'Y':
            fromPos.x--;
            break;
        case '/':
        case 'Z':
        case 'R':
            fromPos.x--;
            fromPos.y++;
            break;
        case '\\':
        case 'W':
            fromPos.x--;
            fromPos.y--;
            break;
        case ' ':
            // NSLog(@"Eeek: unknown location!");
            break;
        case 'T':
        default:
            // no idea.
            break;
    }
    
    if ([self cellIsSwitch: fromPos]) {
        // is it against us?
        if ([self allowedToTravelFrom: oldPos
                                   to: fromPos] == NO) {
            // Don't allow the move.
            return NO;
        }
    }
    
    if ([self occupyingTrainAtCell: fromPos]) {
        // Something's there.
        return NO;
    }
    
    // Validate the new cell is in the game board.
    if ((fromPos.x < 0 || fromPos.x >= self.scenario.tileColumns) || (fromPos.y < 0 || fromPos.y >= self.scenario.tileRows)) {
        return NO;
    }

    *toPos = fromPos;
    return YES;
}
// Advances the specified train one step west (left).
- (BOOL) moveTrainWest: (Train*) train {
    struct CellPosition pos = train.position;
    struct CellPosition newPos = pos;
   
    if ([self nextCellWest: pos returns: &newPos] == NO) return NO;

    // Passing signal? Invalidate.
    Signal *theSignal = [self signalAtCell: pos direction: WestDirection];
    if (theSignal && !theSignal.isGreen) return NO;
    
    theSignal.isGreen = NO;
    
    routeSelection[pos.x][pos.y] = 0;
    train.position = newPos;
    return YES;
}

- (BOOL) nextCellEast: (struct CellPosition) pos returns: (struct CellPosition*) newPos {
    struct CellPosition oldPos = pos;

    // Signal?  Don't pass.
    Signal *theSignal = [self signalAtCell: pos direction: EastDirection];
    if (theSignal && !theSignal.isGreen) return NO;
    

    switch ([self.scenario tileAtCell: pos]) {
        case 'Q':
            if ([self isSwitchNormal: pos]) {
                pos.x++;
            } else {
                pos.x++;
                pos.y++;
            }
            break;
        case 'P':
            if ([self isSwitchNormal: pos]) {
                pos.x++;
            } else {
                pos.x++;
                pos.y--;
            }
            break;
        case 'Y':
            if ([self isSwitchNormal: pos]) {
                pos.x++;
                pos.y--;
            } else {
                pos.x++;
                pos.y++;
            }
            break;
        case 'V':
            if ([self isSwitchNormal: pos]) {
                pos.x++;
                pos.y++;
            } else {
                pos.y++;
            }
            break;
        case 'R':
            if ([self isSwitchNormal: pos]) {
                pos.x++;
                pos.y--;
            } else {
                pos.x++;
            }
            break;
        case '-':
        case '.':
        case '=':
        case 'Z':
        case 'W':
        case 'p':
        case 'q':
        case 'T':
        case 'y':
            pos.x++;
            break;
        case '\\':
        case 'z':
        case 'r':
            pos.x++;
            pos.y++;
            break;
        case '/':
        case 'v':
        case 'w':
            pos.x++;
            pos.y--;
            break;
        case ' ':
        case 't':
        default:
            // no idea.
            NSLog(@"Eeek: unknown location!");
            break;
    }
    
    if ([self cellIsSwitch: pos]) {
        // is it against us?
        if ([self allowedToTravelFrom: oldPos
                                   to: pos] == NO) {
            // Don't allow the move.
            return NO;
        }
    }
    
    if ([self occupyingTrainAtCell: pos]) {
        // Something's there.
        return NO;
    }
    
    // Validate the new cell is in the game board.
    if ((pos.x < 0 || pos.x >= self.scenario.tileColumns) || (pos.y < 0 || pos.y >= self.scenario.tileRows)) {
        return NO;
    }
    *newPos = pos;
    return YES;
}

// Advances the specified train one step west (left).
- (BOOL) moveTrainEast: (Train*) train {
    struct CellPosition pos = train.position;
    struct CellPosition newPos = pos;

    if ([self nextCellEast: pos returns: &newPos] == NO) return NO;
    
    Signal *theSignal = [self signalAtCell: pos direction: EastDirection];
    if (theSignal && theSignal.trafficDirection == EastDirection && !theSignal.isGreen) return NO;
    theSignal.isGreen = NO;
  
    routeSelection[newPos.x][newPos.y] = 0;
    train.position = newPos;
    return YES;
}

@synthesize activeTrains;
@synthesize switchPositionDictionary;

@end
