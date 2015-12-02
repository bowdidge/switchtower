 //
//  LayoutModelTest.m
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

#import <XCTest/XCTest.h>

#import "Cell.h"
#import "LayoutModel.h"
#import "Scenario.h"
#import "Signal.h"
#import "TestScenario.h"
#import "Train.h"

@interface LayoutModelTest : XCTestCase

@end

@implementation LayoutModelTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    TestScenario *s = [[TestScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"101"
                                 name: @"streamliner"
                            direction: EastDirection
                                start: [s endpointWithName: @"LeftBottom"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"Right"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(0, 1)];

    XCTAssertEqual(0, t.position.x, @"");
    XCTAssertEqual(1, t.position.y, @"");

    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");

    XCTAssertEqual(1, t.position.x, @"");
    XCTAssertEqual(1, t.position.y, @"");
    
    XCTAssertTrue([m isSwitchNormal: MakeCellPosition(2,0)], @"Switch not normal.");
    
    XCTAssertFalse([m moveTrainEast: t brokeRule: &rule], @"should not have moved.");

    XCTAssertTrue([m setSwitchPosition: MakeCellPosition(2,0) isNormal: false], @"couldn't throw switch.");

    XCTAssertTrue([m moveTrainEast: t  brokeRule: &rule], @"didn't move.");
    
    XCTAssertEqual(2, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");

    XCTAssertTrue([m moveTrainEast: t  brokeRule: &rule], @"didn't move.");
    XCTAssertEqual(3, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");

    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"didn't move.");
    XCTAssertEqual(4, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    // TODO(bowdidge): Avoid moving outside the game board.
    XCTAssertFalse([m moveTrainEast: t brokeRule: &rule], @"should not have moved.");
    XCTAssertEqual(4, t.position.x, @"Should have stayed at last cell.");
    XCTAssertEqual(0, t.position.y, @"Should have stayed at last cell.");
}

- (void)testSwitchNormal {
    TestScenario *s = [[TestScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"100"
                                 name: @"streamliner"
                            direction: WestDirection
                                start: [s endpointWithName: @"Right"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"LeftBottom"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(4,0)];
    
    XCTAssertEqual(4, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    XCTAssertEqual(1300, t.distanceFromWestEndCurrentCell, @"");
    
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(3, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m isSwitchNormal: MakeCellPosition(2,0)], @"Switch not normal.");
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(2, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(1, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
}

- (void)testSwitchReversed {
    TestScenario *s = [[TestScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"100"
                                 name: @"streamliner"
                            direction: WestDirection
                                start: [s endpointWithName: @"Right"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"LeftBottom"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(4, 0)];
    XCTAssertEqual(1300, t.distanceFromWestEndCurrentCell, @"");
   
    XCTAssertEqual(4, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(3, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m isSwitchNormal: MakeCellPosition(2,0)], @"Switch not normal.");
    [m setSwitchPosition: MakeCellPosition(2,0) isNormal: false];
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(2, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(1, t.position.x, @"");
    XCTAssertEqual(1, t.position.y, @"");

}

- (void)testNoMoveOffTopOfGame {
    InvalidScenario *s = [[InvalidScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"101"
                                 name: @"streamliner"
                            direction: EastDirection
                                start: [s endpointWithName: @"Left"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"Right"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(0, 0)];
    
    XCTAssertEqual(0, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(1, t.position.x, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.position.y, @"Shouldn't have moved off board.");
    
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(2, t.position.x, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.position.y, @"Shouldn't have moved off board.");

    // Shouldn't move - goes off game board.
    XCTAssertFalse([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(2, t.position.x, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.position.y, @"Shouldn't have moved off board.");
 }

- (void)testNoMoveOffBottomOfGame {
    InvalidScenario *s = [[InvalidScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"100"
                                 name: @"streamliner"
                            direction: WestDirection
                                start: [s endpointWithName: @"Right"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"Left"]]];
    BannedRule *rule = nil;
   [m addActiveTrain: t position: MakeCellPosition(4, 0)];
    
    XCTAssertEqual(4, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(3, t.position.x, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.position.y, @"Shouldn't have moved off board.");
    
    XCTAssertFalse([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    
    XCTAssertEqual(3, t.position.x, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.position.y, @"Shouldn't have moved off board.");
    
}

- (void)testSignal {
    StraightScenario *s = [[StraightScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"101"
                                 name: @"streamliner"
                            direction: EastDirection
                                start: [s endpointWithName: @"Left"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"Right"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(0, 0)];
    
    Signal *sig = [Signal signalControlling: EastDirection position: MakeCellPosition(2,0)];
    NSArray *signals = [NSArray arrayWithObject: sig];
    s.all_signals = signals;
    XCTAssertEqual(0, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    XCTAssertFalse([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    sig.isGreen = true;
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    XCTAssertEqual(3, t.position.x, @"Didn't move correctly.");
    XCTAssertEqual(0, t.position.y, @"Didn't move correctly.");
}

- (void)testSignalDoesntAffectOtherDirection {
    StraightScenario *s = [[StraightScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"101"
                                 name: @"streamliner"
                            direction: EastDirection
                                start: [s endpointWithName: @"Left"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"Right"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(0, 0)];
    
    Signal *sig = [Signal signalControlling: WestDirection position: MakeCellPosition(2,0)];
    NSArray *signals = [NSArray arrayWithObject: sig];
    s.all_signals = signals;
    XCTAssertEqual(0, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    XCTAssertEqual(3, t.position.x, @"Didn't move correctly.");
    XCTAssertEqual(0, t.position.y, @"Didn't move correctly.");
}

- (void) testDistanceEast {
    TestScenarioWithDistances *s = [[TestScenarioWithDistances alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"101"
                                 name: @"streamliner"
                            direction: WestDirection
                                start: [s endpointWithName: @"Right"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"Left"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(4, 0)];
    t.speedMPH = 10;
    XCTAssertEqual(4, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    // Starts at far right.
    XCTAssertEqual(500, t.distanceFromWestEndCurrentCell, @"");
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    // 10mph is 440 feet per tick.
    XCTAssertEqual(4, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
   XCTAssertEqualWithAccuracy(60.0, t.distanceFromWestEndCurrentCell, 10, @"Wrong distance.");
    
    XCTAssertTrue([m moveTrainWest: t brokeRule: &rule], @"Couldn't move.");
    // 10mph is 440 feet per tick.
    XCTAssertEqual(3, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    // 2500 - 380.  (380 is 440 * 2 - 500).
    XCTAssertEqualWithAccuracy(2120.0, t.distanceFromWestEndCurrentCell, 10, @"Wrong distance.");
}

- (void) testDistancesWest {
    TestScenarioWithDistances *s = [[TestScenarioWithDistances alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithNumber: @"101"
                                 name: @"streamliner"
                            direction: EastDirection
                                start: [s endpointWithName: @"Left"]
                                 ends: [NSArray arrayWithObject: [s endpointWithName: @"Right"]]];
    BannedRule *rule = nil;
    [m addActiveTrain: t position: MakeCellPosition(0, 0)];
    t.speedMPH = 10;
    XCTAssertEqual(0, t.position.x, @"");
    XCTAssertEqual(0, t.position.y, @"");
    XCTAssertEqual(0, t.distanceFromWestEndCurrentCell, @"");
    XCTAssertTrue([m moveTrainEast: t brokeRule: &rule], @"Couldn't move.");
    // 10mph is 440 feet per tick.
    XCTAssertEqualWithAccuracy(440.0, t.distanceFromWestEndCurrentCell, 10, @"Wrong distance.");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
