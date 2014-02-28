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

#import "Scenario.h"
#import "Signal.h"
#import "Train.h"

@implementation LayoutModel

- (id) init {
    [super init];
    self.trains = [NSMutableArray array];
    self.switchPositionDictionary = [NSMutableDictionary dictionary];
    routeCount = 0;
    return self;
}

// Register a new train to display.
- (void) addTrain: (Train*) train {
    [self.trains addObject: train];
}

- (void) clearRoute {
    routeCount = 0;
    int rows = [self.currentSpecification tileRows];
    int columns = [self.currentSpecification tileColumns];
    for (int x=0; x<columns; x++) {
        for (int y = 0; y < rows; y++) {
            routeSelection[x][y] = 0;
        }
    }
}

- (int) routeForCellX: (int) x Y: (int) y {
    return routeSelection[x][y];
}

- (BOOL) selectRouteAtX: (int) x Y:(int) y direction: (enum TimetableDirection) direction {
    int currentRoute = routeSelection[x][y];
    if (currentRoute == 0) {
        currentRoute = ++routeCount;
    }
    int origX = x;
    int origY = y;
    
    while (1) {
        Signal *theSignal = [self signalAtX: x Y: y direction: direction];
        if (theSignal && theSignal.trafficDirection == direction && !theSignal.isGreen) break;

        int newX = x, newY = y;
        if (direction == EastDirection) {
            if (![self nextCellEastX: x Y:y returnsX:&newX Y: &newY]) return NO;
        } else {
            if (![self nextCellWestX: x Y:y returnsX:&newX Y: &newY]) return NO;
        }
        if (newX == x && newY == y) break;
        // Don'tset route yet.
        x = newX;
        y = newY;
    }
    
    // Now, do again and set route.
    x = origX;
    y = origY;

    // TODO(bowdidge): Remove duplicated code.
    while (1) {
        Signal *theSignal = [self signalAtX: x Y: y direction: direction];
        if (theSignal && theSignal.trafficDirection == direction && !theSignal.isGreen) break;
        
        int newX = x, newY = y;
        if (direction == EastDirection) {
            [self nextCellEastX: x Y:y returnsX:&newX Y: &newY];
        } else {
            [self nextCellWestX: x Y:y returnsX:&newX Y: &newY];
        }
        if (newX == x && newY == y) break;
        routeSelection[newX][newY] = currentRoute;
        x = newX;
        y = newY;
    }
    return YES;
}

- (Signal*) signalAtX: (int) x Y: (int) y direction: (enum TimetableDirection) dir{
    for (Signal* signal in self.currentSpecification.all_signals) {
        if (signal.x == x && signal.y == y && signal.trafficDirection == dir) {
            return signal;
        }
    }
    return NULL;
}

- (TrackDirection) pointsDirectionForCellX: (int) cellX Y: (int) cellY {
    char cell = [self.currentSpecification cellAtTileX: cellX Y: cellY];
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

- (BOOL) isEndPointX: (int) x Y: (int) y {
    // Consider T to be stopping but not endpoint.
    return [self.currentSpecification cellAtTileX: x Y: y] == '.';
}


// Returns true if the cell is a known starting or ending space for trains.
- (NamedPoint*) isNamedPointX: (int) x Y: (int) y {
    for (NamedPoint *ep in [self.currentSpecification all_endpoints]) {
        if ([ep xPosition] == x && [ep yPosition] == y) {
            return ep;
        }
    }
    return nil;
}

// Returns true if the switch is in the normal position.
// TODO(bowdidge): Need better data structure.
// Currently, a dictionary is used to note the cells where switches are reversed.  Nonexistence of a
// switch in the dictionary means it's normal, or it's not a switch.
- (BOOL) isSwitchNormalX: (int) cellX Y: (int) cellY {
    NSArray *pos = [NSArray arrayWithObjects: [NSNumber numberWithInt: cellX],
                    [NSNumber numberWithInt: cellY], nil];
    if ([self.switchPositionDictionary objectForKey: pos]) {
        return NO;
    }
    return YES;
}

- (TrackDirection) normalDirectionForCellX: (int) cellX Y: (int) cellY {
    char cell = [self.currentSpecification cellAtTileX: cellX Y: cellY];
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
- (Train*) occupyingTrainAtX: (int) cellX Y: (int) cellY {
    for (Train *train in self.trains) {
        int x = train.xPosition;
        int y = train.yPosition;
        if ((cellX ==x) && (cellY == y)) {
            return train;
        }
    }
    return nil;
}

- (TrackDirection) incomingDirectionWhenMovingFromX: (int) startX Y: (int) startY toX: (int) endX Y: (int) endY {
    if (startX < endX) {
        if (startY < endY) {
            return Northwest;
        } else if (startY == endY) {
            return West;
        } else {
            return Southwest;
        }
    } else if (startX == endX) {
        if (startY < endY) {
            return North;
        } else if (startY == endY) {
            return Center;
        } else {
            return South;
        }
    } else {
        if (startY < endY) {
            return Northeast;
        } else if (startY == endY) {
            return East;
        } else {
            return Southeast;
        }
    }
    return Center;
}

// Returns true if the cell at (cellX, cellY) is a switch icon and routes the
// train in multiple directions.
- (BOOL) cellIsSwitchX: (int) cellX Y: (int) cellY {
    if (cellX < 0 || cellX >= self.currentSpecification.tileColumns || cellY < 0 || cellY >= self.currentSpecification.tileRows) {
        return NO;
    }
    char cell = [self.currentSpecification cellAtTileX: cellX Y: cellY];
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
- (BOOL) setSwitchPositionX: (int) cellX Y: (int) cellY isNormal: (BOOL) isNormal {
    if (routeSelection[cellX][cellY] != 0) {
        return NO;
    }
    NSArray *pos = [NSArray arrayWithObjects: [NSNumber numberWithInt: cellX],
                    [NSNumber numberWithInt: cellY], nil];
    if (isNormal) {
        [self.switchPositionDictionary removeObjectForKey: pos];
    } else {
        [self.switchPositionDictionary setObject: [NSNumber numberWithInt: 0] forKey: pos];
    }
    return YES;
}


- (BOOL) allowedToTravelFromX: (int) fromX Y: (int) fromY toX: (int) toX Y: (int) toY {
    
    TrackDirection incoming = [self incomingDirectionWhenMovingFromX: fromX Y: fromY toX: toX Y: toY];
    if ([self pointsDirectionForCellX: toX Y: toY] == incoming) {
        return YES;
    } else if ([self normalDirectionForCellX: toX Y: toY] == incoming) {
        return [self isSwitchNormalX: toX Y: toY];
    } else {
        return ![self isSwitchNormalX: toX Y: toY];
    }
    return NO;
}


- (BOOL) nextCellWestX: (int) cellX Y: (int) cellY returnsX: (int*) newCellX Y: (int*) newCellY {
    int oldCellX = cellX;
    int oldCellY = cellY;

    Signal *theSignal = [self signalAtX: cellX Y: cellY direction: WestDirection];
    if (theSignal && theSignal.trafficDirection == WestDirection && !theSignal.isGreen) return NO;
    
    
    switch ([self.currentSpecification cellAtTileX: cellX Y: cellY]) {
        case 'q':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX--;
            } else {
                cellX--;
                cellY++;
            }
            break;
        case 'p':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX--;
            } else {
                cellX--;
                cellY--;
            }
            break;
        case 'y':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX--;
                cellY--;
            } else {
                cellX--;
                cellY++;
            }
            break;
        case 'v':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX--;
                cellY++;
            } else {
                cellX--;
            }
            break;
        case 'r':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX--;
                cellY--;
            } else {
                cellX--;
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
            cellX --;
            break;
        case '/':
        case 'Z':
        case 'R':
            cellX--;
            cellY++;
            break;
        case '\\':
        case 'W':
            cellX--;
            cellY--;
            break;
        case ' ':
            // NSLog(@"Eeek: unknown location!");
            break;
        case 'T':
        default:
            // no idea.
            break;
    }
    
    if ([self cellIsSwitchX: cellX Y: cellY]) {
        // is it against us?
        if ([self allowedToTravelFromX: oldCellX Y: oldCellY
                                   toX: cellX Y: cellY] == NO) {
            // Don't allow the move.
            return NO;
        }
    }
    
    if ([self occupyingTrainAtX: cellX Y: cellY]) {
        // Something's there.
        return NO;
    }

    *newCellX = cellX;
    *newCellY = cellY;
    return YES;
}
// Advances the specified train one step west (left).
- (BOOL) moveTrainWest: (Train*) train {
    int cellX = train.xPosition;
    int cellY = train.yPosition;
    
   
    // For 4th Street only, I think.
    if (cellX == 0 && cellY == 9) {
        [train setXPosition: 23];
        [train setYPosition: 1];
        return YES;
    }
    if (cellX == 0 && cellY == 11) {
        [train setXPosition: 23];
        [train setYPosition: 3];
        return YES;
    }
    
    int newCellX = cellX, newCellY = cellY;
    
    if ([self nextCellWestX: cellX Y:cellY returnsX:&newCellX Y:&newCellY] == NO) return NO;

    // Passing signal? Invalidate.
    Signal *theSignal = [self signalAtX: cellX Y: cellY direction: WestDirection];
    if (theSignal && !theSignal.isGreen) return NO;
    
    theSignal.isGreen = NO;
    
    routeSelection[newCellX][newCellY] = 0;
    train.xPosition = newCellX;
    train.yPosition = newCellY;
    return YES;
}

- (BOOL) nextCellEastX: (int) cellX Y: (int) cellY returnsX: (int*) newCellX Y: (int*) newCellY {
    int oldCellX = cellX;
    int oldCellY = cellY;

    // Signal?  Don't pass.
    Signal *theSignal = [self signalAtX: cellX Y: cellY direction: EastDirection];
    if (theSignal && !theSignal.isGreen) return NO;
    

    switch ([self.currentSpecification cellAtTileX: cellX Y: cellY]) {
        case 'Q':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX++;
            } else {
                cellX++;
                cellY++;
            }
            break;
        case 'P':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX++;
            } else {
                cellX++;
                cellY--;
            }
            break;
        case 'Y':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX++;
                cellY--;
            } else {
                cellX++;
                cellY++;
            }
            break;
        case 'V':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX++;
                cellY++;
            } else {
                cellX++;
            }
            break;
        case 'R':
            if ([self isSwitchNormalX:cellX Y: cellY]) {
                cellX++;
                cellY--;
            } else {
                cellX++;
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
            cellX ++;
            break;
        case '\\':
        case 'z':
        case 'r':
            cellX++;
            cellY++;
            break;
        case '/':
        case 'v':
        case 'w':
            cellX++;
            cellY--;
            break;
        case ' ':
        case 't':
        default:
            // no idea.
            NSLog(@"Eeek: unknown location!");
            break;
    }
    
    if ([self cellIsSwitchX: cellX Y: cellY]) {
        // is it against us?
        if ([self allowedToTravelFromX: oldCellX Y: oldCellY
                                   toX: cellX Y: cellY] == NO) {
            // Don't allow the move.
            return NO;
        }
    }
    
    if ([self occupyingTrainAtX: cellX Y: cellY]) {
        // Something's there.
        return NO;
    }
    
    *newCellX = cellX;
    *newCellY = cellY;
    return YES;
}

// Advances the specified train one step west (left).
- (BOOL) moveTrainEast: (Train*) train {
    int cellX = train.xPosition;
    int cellY = train.yPosition;
    
    int newCellX=cellX, newCellY=cellY;;
    if ([self nextCellEastX: cellX Y: cellY returnsX:&newCellX Y:&newCellY] == NO) return NO;
    
    Signal *theSignal = [self signalAtX: cellX Y: cellY direction: EastDirection];
    if (theSignal && theSignal.trafficDirection == EastDirection && !theSignal.isGreen) return NO;
    theSignal.isGreen = NO;
  
    routeSelection[newCellX][newCellY] = 0;
    train.xPosition = newCellX;
    train.yPosition = newCellY;
    return YES;
}

@synthesize trains;
@synthesize switchPositionDictionary;

@end
