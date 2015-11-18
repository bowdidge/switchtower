//
//  TestScenario.m
//  SwitchTower
//
//  Created by bowdidge on 11/15/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "TestScenario.h"

#import "Cell.h"
#import "NamedPoint.h"

@implementation TestScenario
- (id) init {
    self = [super init];
    self.tileStrings = [NSArray arrayWithObjects: @"--q--", @"-/   ", nil];
    self.tileRows = 2;
    self.tileColumns = 5;
    NSMutableArray *eps = [NSMutableArray array];
    struct CellPosition left = {0,0};
    struct CellPosition right = {4,0};
    struct CellPosition left_bot = {1,0};
    [eps addObject: [NamedPoint namedPointWithName: @"LeftTop" position: left]];
    [eps addObject: [NamedPoint namedPointWithName: @"LeftBottom" position: left_bot]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" position: right]];
    self.all_endpoints = eps;
    return self;
}

@end

@implementation InvalidScenario
- (id) init {
    self = [super init];
    self.tileStrings = [NSArray arrayWithObject: @"--//-"];
    self.tileRows = 1;
    self.tileColumns = 5;
    struct CellPosition left = {0,0};
    struct CellPosition right = {4,0};
   NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"Left" position: left]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" position: right]];
    self.all_endpoints = eps;
    return self;
}
@end

@implementation StraightScenario
- (id) init {
    self = [super init];
    self.tileStrings = [NSArray arrayWithObject: @"-----"];
    self.tileRows = 1;
    self.tileColumns = 5;
    struct CellPosition left = {0,0};
    struct CellPosition right = {4,0};
    NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"Left" position: left]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" position: right]];
    self.all_endpoints = eps;
    return self;
}
@end