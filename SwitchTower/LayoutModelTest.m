 //
//  LayoutModelTest.m
//  SwitchTower
//
//  Created by bowdidge on 11/15/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <XCTest/XCTest.h>

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
    Train *t = [Train trainWithName: @"101"
                        description: @"streamliner"
                          direction: EastDirection
                              start: [s endpointWithName: @"LeftBottom"]
                                end: [s endpointWithName: @"Right"]];
    [m addTrain: t];
    t.xPosition = 0;
    t.yPosition = 1;

    XCTAssertEqual(0, t.xPosition, @"");
    XCTAssertEqual(1, t.yPosition, @"");

    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");

    XCTAssertEqual(1, t.xPosition, @"");
    XCTAssertEqual(1, t.yPosition, @"");
    
    XCTAssertTrue([m isSwitchNormalX: 2 Y: 0], @"Switch not normal.");
    
    XCTAssertFalse([m moveTrainEast: t], @"should not have moved.");

    XCTAssertTrue([m setSwitchPositionX: 2 Y: 0 isNormal: false], @"couldn't throw switch.");

    XCTAssertTrue([m moveTrainEast: t], @"didn't move.");
    
    XCTAssertEqual(2, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");

    XCTAssertTrue([m moveTrainEast: t], @"didn't move.");
    XCTAssertEqual(3, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");

    XCTAssertTrue([m moveTrainEast: t], @"didn't move.");
    XCTAssertEqual(4, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    // TODO(bowdidge): Avoid moving outside the game board.
    XCTAssertFalse([m moveTrainEast: t], @"should not have moved.");
    XCTAssertEqual(4, t.xPosition, @"Should have stayed at last cell.");
    XCTAssertEqual(0, t.yPosition, @"Should have stayed at last cell.");
}

- (void)testSwitchNormal {
    TestScenario *s = [[TestScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithName: @"100"
                        description: @"streamliner"
                          direction: EastDirection
                              start: [s endpointWithName: @"Right"]
                                end: [s endpointWithName: @"LeftBottom"]];
    [m addTrain: t];
    t.xPosition = 4;
    t.yPosition = 0;
    
    XCTAssertEqual(4, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(3, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m isSwitchNormalX: 2 Y: 0], @"Switch not normal.");
    XCTAssertTrue([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(2, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(1, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
}

- (void)testSwitchReversed {
    TestScenario *s = [[TestScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithName: @"100"
                        description: @"streamliner"
                          direction: EastDirection
                              start: [s endpointWithName: @"Right"]
                                end: [s endpointWithName: @"LeftBottom"]];
    [m addTrain: t];
    t.xPosition = 4;
    t.yPosition = 0;
    
    XCTAssertEqual(4, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(3, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m isSwitchNormalX: 2 Y: 0], @"Switch not normal.");
    [m setSwitchPositionX: 2 Y: 0 isNormal: false];
    XCTAssertTrue([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(2, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(1, t.xPosition, @"");
    XCTAssertEqual(1, t.yPosition, @"");

}

- (void)testNoMoveOffTopOfGame {
    InvalidScenario *s = [[InvalidScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithName: @"101"
                        description: @"streamliner"
                          direction: EastDirection
                              start: [s endpointWithName: @"Left"]
                                end: [s endpointWithName: @"Right"]];
    [m addTrain: t];
    t.xPosition = 0;
    t.yPosition = 0;
    
    XCTAssertEqual(0, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    
    XCTAssertEqual(1, t.xPosition, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.yPosition, @"Shouldn't have moved off board.");
    
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    
    XCTAssertEqual(2, t.xPosition, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.yPosition, @"Shouldn't have moved off board.");

    // Shouldn't move - goes off game board.
    XCTAssertFalse([m moveTrainEast: t], @"Couldn't move.");
    
    XCTAssertEqual(2, t.xPosition, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.yPosition, @"Shouldn't have moved off board.");
 }

- (void)testNoMoveOffBottomOfGame {
    InvalidScenario *s = [[InvalidScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithName: @"100"
                        description: @"streamliner"
                          direction: WestDirection
                              start: [s endpointWithName: @"Right"]
                                end: [s endpointWithName: @"Left"]];
    [m addTrain: t];
    t.xPosition = 4;
    t.yPosition = 0;
    
    XCTAssertEqual(4, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(3, t.xPosition, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.yPosition, @"Shouldn't have moved off board.");
    
    XCTAssertFalse([m moveTrainWest: t], @"Couldn't move.");
    
    XCTAssertEqual(3, t.xPosition, @"Shouldn't have moved off board.");
    XCTAssertEqual(0, t.yPosition, @"Shouldn't have moved off board.");
    
}

- (void)testSignal {
    StraightScenario *s = [[StraightScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithName: @"101"
                        description: @"streamliner"
                          direction: EastDirection
                              start: [s endpointWithName: @"Left"]
                                end: [s endpointWithName: @"Right"]];
    [m addTrain: t];
    t.xPosition = 0;
    t.yPosition = 0;
    
    Signal *sig = [Signal signalControlling: EastDirection X: 2 Y: 0];
    NSArray *signals = [NSArray arrayWithObject: sig];
    s.all_signals = signals;
    XCTAssertEqual(0, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    XCTAssertFalse([m moveTrainEast: t], @"Couldn't move.");
    sig.isGreen = true;
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    XCTAssertEqual(3, t.xPosition, @"Didn't move correctly.");
    XCTAssertEqual(0, t.yPosition, @"Didn't move correctly.");
}

- (void)testSignalDoesntAffectOtherDirection {
    StraightScenario *s = [[StraightScenario alloc] init];
    LayoutModel *m = [[LayoutModel alloc] initWithScenario: s];
    Train *t = [Train trainWithName: @"101"
                        description: @"streamliner"
                          direction: EastDirection
                              start: [s endpointWithName: @"Left"]
                                end: [s endpointWithName: @"Right"]];
    [m addTrain: t];
    t.xPosition = 0;
    t.yPosition = 0;
    
    Signal *sig = [Signal signalControlling: WestDirection X: 2 Y: 0];
    NSArray *signals = [NSArray arrayWithObject: sig];
    s.all_signals = signals;
    XCTAssertEqual(0, t.xPosition, @"");
    XCTAssertEqual(0, t.yPosition, @"");
    
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    XCTAssertTrue([m moveTrainEast: t], @"Couldn't move.");
    XCTAssertEqual(3, t.xPosition, @"Didn't move correctly.");
    XCTAssertEqual(0, t.yPosition, @"Didn't move correctly.");
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
