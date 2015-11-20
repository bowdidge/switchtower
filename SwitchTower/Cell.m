//
//  Cell.m
//  SwitchTower
//
//  Created by bowdidge on 11/18/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Cell.h"

struct CellPosition MakeCellPosition(int x, int y) {
    struct CellPosition p;
    p.x = x; p.y = y;
    return p;
}