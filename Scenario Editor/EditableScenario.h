//
//  EditableScenario.h
//  SwitchTower
//
//  Created by bowdidge on 12/1/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "Scenario.h"

// Scenario object, but with handy editing actions.
@interface EditableScenario : Scenario
// Adds a new blank column in the playing field, and updates all positions accordingly.
- (void) addColumnAfter: (int) column;
// Removes the specified column, and removes all signals, endpoints, and labels on that column.
- (void) removeColumn: (int) column;

// Adds a new blank row in the playing field, and updates all positions accordingly.
- (void) addRowBelow: (int) row;
// Remove the specified row, and removes all signals, endpoints, and labels on that row.
- (void) removeRow: (int) row;

// Change the tile in the game board.
- (void) changeTile: (char) tile atCell: (struct CellPosition) pos;
@end

