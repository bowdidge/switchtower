//
//  Cell.h
//  SwitchTower
//
//  Created by bowdidge on 11/17/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#ifndef Cell_h
#define Cell_h

struct CellPosition {
    int x;
    int y;
};

// Returns a CellPosition based on x,y values.
struct CellPosition MakeCellPosition(int x, int y);

// Returns a CellPosition as expected in scenario plists.
NSString* CellPositionAsString(struct CellPosition pos);

#endif /* Cell_h */
