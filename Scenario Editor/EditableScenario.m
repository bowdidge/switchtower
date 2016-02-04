//
//  EditableScenario.m
//  SwitchTower
//
//  Created by bowdidge on 12/1/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "EditableScenario.h"

#import "Label.h"
#import "NamedPoint.h"
#import "Signal.h"

@implementation EditableScenario

- (void)adjustPositionsAfter:(int)column offset: (int) offset {
    // Find all Labels after that column.
    for (Label *l in self.all_labels) {
        if (l.position.x > column) {
            l.position = MakeCellPosition(l.position.x + offset, l.position.y);
        }
    }
    
    // Find all Endpoints after that column.
    for (NamedPoint *pt in self.all_endpoints) {
        if (pt.position.x > column) {
            pt.position = MakeCellPosition(pt.position.x + offset, pt.position.y);
        }
    }
    
    // Find all Endpoints after that column.
    for (Signal *sig in self.all_signals) {
        if (sig.position.x > column) {
            sig.position = MakeCellPosition(sig.position.x + offset, sig.position.y);
        }
    }
}

- (void) addColumnAfter: (int) column {
    NSLog(@"Adding column at %d", column);
    // Add space in appropriate column.
    NSMutableArray *newTileStrings = [NSMutableArray array];
    for (NSString *row in self.tileStrings) {
        [newTileStrings addObject: [NSString stringWithFormat: @"%@ %@", [row substringToIndex: column + 1], [row substringFromIndex: column + 1]]];
    }
    self.tileStrings = newTileStrings;
    self.tileColumns += 1;
    
    [self.cellLengths insertObject: [NSNumber numberWithInt: 1] atIndex:column+1];
    
    [self adjustPositionsAfter:column offset: 1];
}

- (void) removeColumn: (int) column {
    NSLog(@"Removing column at %d", column);
    // Add space in appropriate column.
    NSMutableArray *newTileStrings = [NSMutableArray array];
    
    for (NSString *row in self.tileStrings) {
        [newTileStrings addObject: [NSString stringWithFormat: @"%@%@", [row substringToIndex: column], [row substringFromIndex: column + 1]]];
    }

    self.tileStrings = newTileStrings;
    self.tileColumns -= 1;

    NSMutableArray *newLabelArray = [NSMutableArray arrayWithArray: self.all_labels];
    for (Label *l in self.all_labels) {
        if (l.position.x == column) {
            [newLabelArray removeObject: l];
        }
    }
    self.all_labels = newLabelArray;
 
    NSMutableArray *newSignalArray = [NSMutableArray arrayWithArray: self.all_signals];
    for (Signal *s in self.all_signals) {
        if (s.position.x == column) {
            [newSignalArray removeObject: s];
        }
    }
    self.all_signals = newSignalArray;

    NSMutableArray *newEndpointArray = [NSMutableArray arrayWithArray: self.all_endpoints];
    for (NamedPoint *p in self.all_endpoints) {
        if (p.position.x == column) {
            [newEndpointArray removeObject: p];
        }
    }
    self.all_endpoints = newEndpointArray;

    [self.cellLengths removeObjectAtIndex: column];
    
    [self adjustPositionsAfter:column-1 offset: -1];
}


- (void) addRowBelow:(int)row {
    NSLog(@"Adding row at %d", row);
    // Add space in appropriate column.
    NSMutableArray *newTileStrings = [NSMutableArray arrayWithArray: self.tileStrings];
    NSString *blankRow = [@"" stringByPaddingToLength: self.tileColumns withString: @" " startingAtIndex: 0];
    if (row > newTileStrings.count) {
        row = (int) newTileStrings.count;
    }
    [newTileStrings insertObject: blankRow atIndex: row];
    self.tileStrings = newTileStrings;
    self.tileRows += 1;
    

    // Find all Labels after that column.
    for (Label *l in self.all_labels) {
        if (l.position.y > row) {
            l.position = MakeCellPosition(l.position.x, l.position.y + 1);
        }
    }
    
    // Find all Endpoints after that column.
    for (NamedPoint *pt in self.all_endpoints) {
        if (pt.position.y > row) {
            pt.position = MakeCellPosition(pt.position.x, pt.position.y + 1);
        }
    }
    
    // Find all Endpoints after that column.
    for (Signal *sig in self.all_signals) {
        if (sig.position.y > row) {
            sig.position = MakeCellPosition(sig.position.x, sig.position.y + 1);
        }
    }
}

- (void) removeRow: (int) row {
    // TODO(bowdidge): Implement.
}

// Change the tile in the game board.
- (void) changeTile: (char) tile atCell: (struct CellPosition) pos {
    NSLog(@"Changing tile %c at %d, %d", tile, pos.x, pos.y);
    NSMutableArray *newTileStrings = [NSMutableArray arrayWithArray: self.tileStrings];
    NSMutableString *row = [[NSMutableString alloc] initWithString: [newTileStrings objectAtIndex: pos.y]];
    [row replaceCharactersInRange: NSMakeRange(pos.x, 1) withString: [NSString stringWithFormat: @"%c", tile]];
    [newTileStrings replaceObjectAtIndex:pos.y withObject:row];
    self.tileStrings = newTileStrings;
}

@end
