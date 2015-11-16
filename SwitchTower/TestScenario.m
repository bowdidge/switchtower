//
//  TestScenario.m
//  SwitchTower
//
//  Created by bowdidge on 11/15/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "TestScenario.h"

#import "NamedPoint.h"

@implementation TestScenario
- (id) init {
    self = [super init];
    NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"LeftTop" X: 0 Y: 0]];
    [eps addObject: [NamedPoint namedPointWithName: @"LeftBottom" X: 1 Y: 0]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" X: 4 Y: 0]];
    self.all_endpoints = eps;
    return self;
}

- (int) tileRows {
    return 2;
}

- (int) tileColumns {
    return 5;
}

- (const char*) rawTileString {
    return "--q--\n"
    "-/   ";
}

@end

@implementation InvalidScenario
- (id) init {
    self = [super init];
    NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"Left" X: 0 Y: 0]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" X: 4 Y: 0]];
    self.all_endpoints = eps;
    return self;
}

- (int) tileRows {
    return 1;
}

- (int) tileColumns {
    return 5;
}

- (const char*) rawTileString {
    return "--//-";
}

@end

@implementation StraightScenario
- (id) init {
    self = [super init];
    NSMutableArray *eps = [NSMutableArray array];
    [eps addObject: [NamedPoint namedPointWithName: @"Left" X: 0 Y: 0]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" X: 4 Y: 0]];
    self.all_endpoints = eps;
    return self;
}

- (int) tileRows {
    return 1;
}

- (int) tileColumns {
    return 5;
}

- (const char*) rawTileString {
    return "-----";
}

@end