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
// Add a blank column, and move all positions.
- (void) addColumnAfter: (int) column;
@end
