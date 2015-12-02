//
//  TestScenario.m
//  SwitchTower
//
// Copyright (c) 2015, Robert Bowdidge
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
    [eps addObject: [NamedPoint namedPointWithName: @"LeftTop" cell: left]];
    [eps addObject: [NamedPoint namedPointWithName: @"LeftBottom" cell: left_bot]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" cell: right]];
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
    [eps addObject: [NamedPoint namedPointWithName: @"Left" cell: left]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" cell: right]];
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
    [eps addObject: [NamedPoint namedPointWithName: @"Left" cell: left]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" cell: right]];
    self.all_endpoints = eps;
    return self;
}
@end

@implementation TestScenarioWithDistances
- (id) init {
    self = [super init];
    self.tileStrings = [NSArray arrayWithObjects: @"-----", @"-/   ", nil];
    self.tileRows = 1;
    self.tileColumns = 5;
    NSMutableArray *eps = [NSMutableArray array];
    struct CellPosition left = {0,0};
    struct CellPosition right = {4,0};
    [eps addObject: [NamedPoint namedPointWithName: @"Left" cell: left]];
    [eps addObject: [NamedPoint namedPointWithName: @"Right" cell: right]];
    self.cellLengths = [NSArray arrayWithObjects: [NSNumber numberWithInt: 500], [NSNumber numberWithInt: 1000], [NSNumber numberWithInt: 500], [NSNumber numberWithInt: 2500], [NSNumber numberWithInt: 500], nil];
    self.all_endpoints = eps;
    return self;
}
@end
