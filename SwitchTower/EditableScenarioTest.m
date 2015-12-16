//
//  EditableScenarioTest.m
//  SwitchTower
//
//  Created by bowdidge on 12/15/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "EditableScenario.h"
#import "Label.h"
#import "NamedPoint.h"
#import "Signal.h"
#import "TestScenario.h"

@interface EditableScenarioTest : XCTestCase

@end

@implementation EditableScenarioTest

// Test that the general case of adding a column works.
- (void)testAddColumn {
    TestScenario *s = [[TestScenario alloc] init];
    
    XCTAssertTrue([s validateTileString], @"");
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(5, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(0,0)], @"Wrong");
    XCTAssertEqual('/', [s tileAtCell: MakeCellPosition(1,1)], @"");
    XCTAssertEqual('q', [s tileAtCell: MakeCellPosition(2,0)], @"");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(3,0)], @"");

    XCTAssertEqualObjects(@"LeftTop", [s endpointAtCell: MakeCellPosition(0,0)].name, @"");
    XCTAssertEqualObjects(@"Right", [s endpointAtCell: MakeCellPosition(4,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(3,0)], @"");
    
    [s addColumnAfter: 1];

    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(6, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqualObjects(nil, [s endpointWithName: @"Foo"], @"wrong answer for non-existent name.");
    XCTAssertEqualObjects(@"LeftTop", [s endpointWithName: @"LeftTop"].name, @"Wrong name");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(0,0)], @"Wrong");
    XCTAssertEqual('/', [s tileAtCell: MakeCellPosition(1,1)], @"");
    XCTAssertEqual(' ', [s tileAtCell: MakeCellPosition(2,0)], @"");
    XCTAssertEqual('q', [s tileAtCell: MakeCellPosition(3,0)], @"");
    XCTAssertEqualObjects(@"LeftTop", [s endpointAtCell: MakeCellPosition(0,0)].name, @"");
    XCTAssertEqualObjects(@"Right", [s endpointAtCell: MakeCellPosition(5,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(4,0)], @"");
}

// Test that removing a column generally works.
- (void)testRemoveColumn {
    TestScenario *s = [[TestScenario alloc] init];
    
    XCTAssertTrue([s validateTileString], @"");
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(5, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(0,0)], @"Wrong");
    XCTAssertEqual('/', [s tileAtCell: MakeCellPosition(1,1)], @"");
    XCTAssertEqual('q', [s tileAtCell: MakeCellPosition(2,0)], @"");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(3,0)], @"");
    
    XCTAssertEqualObjects(@"LeftTop", [s endpointAtCell: MakeCellPosition(0,0)].name, @"");
    XCTAssertEqualObjects(@"Right", [s endpointAtCell: MakeCellPosition(4,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(3,0)], @"");
    
    [s removeColumn: 3];
    
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(4, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqualObjects(nil, [s endpointWithName: @"Foo"], @"wrong answer for non-existent name.");
    XCTAssertEqualObjects(@"LeftTop", [s endpointWithName: @"LeftTop"].name, @"Wrong name");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(0,0)], @"Wrong");
    XCTAssertEqual('/', [s tileAtCell: MakeCellPosition(1,1)], @"");
    XCTAssertEqual('q', [s tileAtCell: MakeCellPosition(2,0)], @"");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(3,0)], @"");
    XCTAssertEqual(' ', [s tileAtCell: MakeCellPosition(4,0)], @"");
    XCTAssertEqualObjects(@"LeftTop", [s endpointAtCell: MakeCellPosition(0,0)].name, @"");
    XCTAssertEqualObjects(@"Right", [s endpointAtCell: MakeCellPosition(3,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(4,0)], @"");
}

// Test that removing a column with a named point, a label, and a signal removes all those objects.
- (void)testRemovesColumn {
    TestScenario *s = [[TestScenario alloc] init];
    
    XCTAssertTrue([s validateTileString], @"");
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(5, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(0,0)], @"Wrong");
    XCTAssertEqual('/', [s tileAtCell: MakeCellPosition(1,1)], @"");
    XCTAssertEqual('q', [s tileAtCell: MakeCellPosition(2,0)], @"");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(3,0)], @"");
    
    
    [s removeColumn: 4];
    
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(4, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(0,0)], @"Wrong");
    XCTAssertEqual('/', [s tileAtCell: MakeCellPosition(1,1)], @"");
    XCTAssertEqual('q', [s tileAtCell: MakeCellPosition(2,0)], @"");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(3,0)], @"");
    XCTAssertEqual(' ', [s tileAtCell: MakeCellPosition(4,0)], @"");
}

// Test that removing a column with a named point, a label, and a signal removes all those objects.
- (void)testRemovesEndpointsAtColumn {
    TestScenario *s = [[TestScenario alloc] init];
    
    XCTAssertTrue([s validateTileString], @"");
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(5, s.tileColumns , @"Wrong number for columns.");
    
    XCTAssertEqualObjects(@"LeftTop", [s endpointAtCell: MakeCellPosition(0,0)].name, @"");
    XCTAssertEqualObjects(@"Right", [s endpointAtCell: MakeCellPosition(4,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(3,0)], @"");
    
    [s removeColumn: 4];
    
    XCTAssertEqual(4, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqualObjects(nil, [s endpointWithName: @"Foo"], @"wrong answer for non-existent name.");
    XCTAssertEqualObjects(@"LeftTop", [s endpointWithName: @"LeftTop"].name, @"Wrong name");
   XCTAssertEqualObjects(@"LeftTop", [s endpointAtCell: MakeCellPosition(0,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(3,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(4,0)], @"");
    XCTAssertEqualObjects(nil, [s endpointWithName: @"Right"], @"");
}

// Test that removing a column with a named point, a label, and a signal removes all those objects.
- (void)testRemovesSignalsAtPoint {
    TestScenario *s = [[TestScenario alloc] init];
    
    s.all_signals = [NSMutableArray arrayWithObjects:
                     [Signal signalControlling: WestDirection position: MakeCellPosition(4,0)],
                     [Signal signalControlling: EastDirection position: MakeCellPosition(0,0)],
                     nil];
    s.all_labels = [NSMutableArray arrayWithObjects:
                    [Label labelWithString: @"Right" cell: MakeCellPosition(4,0)],
                    [Label labelWithString: @"Left" cell: MakeCellPosition(3,0)],
                    nil];
    
    
    XCTAssertTrue([s validateTileString], @"");
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(5, s.tileColumns , @"Wrong number for columns.");
    XCTAssertTrue(nil != [s signalAtCell: MakeCellPosition(4,0) direction: WestDirection], @"");
    
    XCTAssertEqual(2, s.all_signals.count);
    XCTAssertEqual(2, s.all_labels.count);
    
    [s removeColumn: 4];
    
    XCTAssertEqual(4, s.tileColumns , @"Wrong number for columns.");

    XCTAssertEqual(1, s.all_signals.count, @"Signal not deleted");
    Signal *sig = [s.all_signals objectAtIndex: 0];
    XCTAssertEqual(EastDirection, sig.trafficDirection, @"Wrong signal deleted");
    
    XCTAssertEqual(1, s.all_labels.count, @"Label not deleted");
    Label *l = [s.all_labels objectAtIndex: 0];
    XCTAssertEqual(3, l.position.x, @"Wrong label deleted");
}


@end
