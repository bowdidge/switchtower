//
//  CocoaLayoutView.m
//  SwitchTower
//
//  Created by bowdidge on 11/30/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "CocoaLayoutView.h"

//
//  LayoutView.m
//  SwitchTower
//
//  Created by Robert Bowdidge on 12/22/12.
// Copyright (c) 2013, Robert Bowdidge
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

#import "ScenarioDocument.h"
#import "Label.h"
#import "NamedPoint.h"
#import "Scenario.h"
#import "Signal.h"
#import "Train.h"

@implementation CocoaLayoutView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    self.viewSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    self.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);;
    NSLog(@"Initing layout view");
   // self.containingScrollView.contentSize = self.viewSize;
    self.displayForEditing = true;
    self.score = 0;
    return self;
}

// Set the size of the game view to match the scenario.
- (void) setSizeInTilesX: (int) x Y: (int) y {
    self.viewSize = CGSizeMake(TILE_WIDTH * x + 160.0, SCREEN_HEIGHT);
    self.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
}

// Work to be done on instantiating the nib.  Note that the view is pre-generated, so
// initialization needs to be here.
// TODO(bowdidge): Why not awakeFromNib?
- (void) awakeFromNib {
    self.routeColors = [NSArray arrayWithObjects: [NSColor blueColor], [NSColor purpleColor],
                        [NSColor greenColor], [NSColor colorWithRed: 0.25 green: 0.25 blue: 1.0 alpha: 1.0], nil];
    self.targetColor = [NSColor colorWithWhite: 0.5 alpha: 1.0];
    self.greenSignalColor = [NSColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.redSignalColor = [NSColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0];
    self.labelColor = [NSColor whiteColor];
    self.trainLabelColor = [NSColor whiteColor];
    self.entryLabelColor = [NSColor whiteColor];
    
    self.approachingColor = [NSColor orangeColor];
    self.occupiedColor = [NSColor yellowColor];
    self.activeTrackColor = [NSColor lightGrayColor];
    self.inactiveTrackColor = [NSColor darkGrayColor];
    self.platformColor = [NSColor greenColor];
    
    // Aim for CTC green.
    self.backgroundColor = [NSColor colorWithRed:32.0/256 green: 48.0/256 blue: 30.0/256 alpha: 1.0];
    self.displayForEditing = true;
}

// Returns the X coordinate of the end point in the specified direction from the center of the tile.
float CellXPosOffset(TrackDirection dir) {
    switch (dir) {
        case North:
        case South:
        case Center:
            return TILE_HALF_WIDTH;
            break;
        case Northwest:
        case West:
        case Southwest:
            return 0;
        default:
            return TILE_DRAW_WIDTH;
    }
    return 0;
}

// Returns the Y coordinate of the end point in the specified direction from the center of the tile.
float CellYPosOffset(TrackDirection dir) {
    switch (dir) {
        case West:
        case East:
        case Center:
            return TILE_HALF_HEIGHT;
            break;
        case Northwest:
        case Northeast:
        case North:
            return TILE_DRAW_HEIGHT;
        default:
            return 0;
    }
    return 0;
}

// Draws a line without any particular context.  Used for non-track lines.
- (void)drawLine:(CGContextRef)context startX: (float) startX startY: (float) startY
            endX: (float) endX endY: (float) endY {
    CGContextMoveToPoint(context, startX, startY); //start at this point
    CGContextAddLineToPoint(context, endX, endY); //draw to this point
    CGContextStrokePath(context);
}

// Draws a single track line from startDir's edge of the tile through the middle, and out the endDir.
// Use the stroke color already set.
- (void)drawLine:(CGContextRef)context cell: (struct CellPosition) pos
        startDir: (TrackDirection) startDir
          endDir: (TrackDirection) endDir
{
    float posX = LEFT_MARGIN + pos.x * TILE_WIDTH;
    float posY = self.bounds.size.height - (TOP_MARGIN  + pos.y * TILE_HEIGHT);
    
    CGContextMoveToPoint(context, posX + CellXPosOffset(startDir), posY + CellYPosOffset(startDir));
    CGContextAddLineToPoint(context, posX + TILE_HALF_WIDTH, posY + TILE_HALF_HEIGHT);
    CGContextAddLineToPoint(context, posX + CellXPosOffset(endDir), posY + CellYPosOffset(endDir));
    CGContextStrokePath(context);
}

// Sets the appropriate color for the track on the cell based on whether the track is active,
// occupied, etc.
- (void) setTrackColorForCell: (struct CellPosition) pos isActive: (BOOL) isActive
                  withContext: (CGContextRef) context{
    
    Train *occupyingTrain = [self.layoutModel occupyingTrainAtCell: pos];
    BOOL isPath = isActive && [self.layoutModel routeForCell: pos] != 0;
    
    if (isActive && occupyingTrain && occupyingTrain.currentState == Waiting) {
        [self.approachingColor setStroke];
    } else if (isActive && occupyingTrain) {
        [self.occupiedColor setStroke];
    } else if (isPath) {
        int routeNumber = ([self.layoutModel routeForCell: pos]);
        NSColor *routeColor = [self.routeColors objectAtIndex: (routeNumber-1) % [self.routeColors count]];
        [routeColor setStroke];
    } else if (isActive) {
        [self.activeTrackColor setStroke];
    } else {
        [self.inactiveTrackColor setStroke];
    }
}

// Draw a switch with multiple possible routings.
- (void) drawSwitchWithContext: (CGContextRef) context
                          cell: (struct CellPosition) pos
                     pointsDir: (TrackDirection) pointsDirection
                     normalDir: (TrackDirection) normalDirection
                    reverseDir: (TrackDirection) reverseDirection {
    if (![self.layoutModel isSwitchNormal: pos]) {
        TrackDirection temp = normalDirection;
        normalDirection = reverseDirection;
        reverseDirection = temp;
    }
    
    // Draw reversed first.
    [self setTrackColorForCell: pos isActive: 0 withContext: context];
    [self drawLine: context cell: pos startDir: reverseDirection endDir: Center];
    
    [self setTrackColorForCell: pos isActive: 1 withContext: context];
    [self drawLine: context cell: pos startDir: pointsDirection endDir: normalDirection];
}

// Draw a train label at the specified position.
- (void)drawTrainLabelInContext:(CGContextRef)context center: (CGPoint) center  message:(NSString *)message {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *fontAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize: 12.0],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: self.trainLabelColor};
    [message drawInRect: CGRectMake(center.x, center.y - TRAIN_LABEL_OFFSET_Y, TILE_WIDTH, TRAIN_LABEL_HEIGHT)
         withAttributes: fontAttrs];
}

- (void)drawTileAtCell: (struct CellPosition) pos withContext:(CGContextRef)context
{
    int posX = LEFT_MARGIN + pos.x * TILE_WIDTH;
    int posY = self.bounds.size.height - (TOP_MARGIN  + pos.y * TILE_HEIGHT);
    
    
    char cell = [self.layoutModel.scenario tileAtCell: pos];
    [self setTrackColorForCell: pos isActive: YES withContext: context];
    float dashes[2] = {DASH_WIDTH, DASH_WIDTH};
    switch (cell) {
        case ' ':
            // do nothing.
            break;
        case '.':
            // Dotted line for continuation of layout off.
            CGContextSaveGState(context);
            // CGContextSetLineDash(context, 0.0, dashes, 2);
            [self drawLine: context cell: pos startDir: West endDir: East];
            CGContextRestoreGState(context);
            break;
        case '-':
            [self drawLine: context cell: pos startDir: West endDir: East];
            break;
            // Platform.
        case '=':
            [self drawLine: context cell: pos startDir: West endDir: East];
            [self.platformColor setStroke];
            [self drawLine: context startX: posX startY: posY + 3
                      endX: posX + TILE_DRAW_WIDTH endY: posY + 3];
            break;
        case 'Z': // lower left to right
            [self drawLine: context cell: pos startDir: Southwest endDir: East];
            break;
        case 'z': // left to lower right
            [self drawLine: context cell: pos startDir: West endDir: Southeast];
            break;
        case 'P': // left to right, switch to upper right
            [self drawSwitchWithContext:context cell: pos pointsDir:West normalDir:East reverseDir:Northeast];
            break;
        case 'p': // left to right, switch to upper left
            [self drawSwitchWithContext:context cell: pos pointsDir:East normalDir:West reverseDir:Northwest];
            break;
        case 'Q': // left to right, switch to lower right
            [self drawSwitchWithContext:context cell: pos pointsDir:West normalDir:East reverseDir:Southeast];
            break;
        case 'q': // left to right, switch to lower left
            [self drawSwitchWithContext:context cell: pos pointsDir:East normalDir:West reverseDir:Southwest];
            break;
        case 'R': // lower left to upper right, switch to right
            [self drawSwitchWithContext:context cell: pos pointsDir:Southwest normalDir:Northeast reverseDir:East];
            break;
        case 'r': // upper left to lower right, switch to left
            [self drawSwitchWithContext:context cell: pos pointsDir:Southeast normalDir:Northwest reverseDir:West];
            break;
        case 'W': // upper left to right
            [self drawLine: context cell: pos  startDir: Northwest endDir: East];
            break;
        case 'w': // left to upper right
            [self drawLine: context cell: pos startDir: West endDir: Northeast];
            break;
        case 'Y': // left to upper and lower right
            [self drawSwitchWithContext:context cell: pos pointsDir:West normalDir:Northeast reverseDir:Southeast];
            break;
        case 'y': // upper and lower left to right
            [self drawSwitchWithContext:context cell: pos pointsDir:East normalDir:Northwest reverseDir:Southwest];
            break;
        case 'V': // upper left to lower right, switch to right
            [self drawSwitchWithContext:context cell: pos pointsDir:Northwest normalDir:Southeast reverseDir:East];
            break;
        case 'v': // upper right to lower left, switch to left.
            [self drawSwitchWithContext:context cell: pos pointsDir:Northeast normalDir:Southwest reverseDir:West];
            break;
        case '\\':
            [self drawLine: context cell: pos startDir: Northwest endDir: Southeast];
            break;
        case '/':
            [self drawLine: context cell: pos startDir: Northeast endDir: Southwest];
            break;
        case 'T': // spur open to right
            [self drawLine: context startX: posX + TILE_HALF_WIDTH startY: posY + TILE_HALF_HEIGHT
                      endX: posX + TILE_DRAW_WIDTH endY: posY + TILE_HALF_HEIGHT];
            [self drawLine: context startX: posX + TILE_HALF_WIDTH startY: posY + 5
                      endX: posX + TILE_HALF_WIDTH endY: posY + 26];
            break;
        case 't': // spur open to left.
            [self drawLine: context startX: posX + TILE_HALF_WIDTH startY: posY + TILE_HALF_HEIGHT
                      endX: posX endY: posY + TILE_HALF_HEIGHT];
            [self drawLine: context startX: posX + TILE_HALF_WIDTH startY: posY + 5
                      endX: posX + TILE_HALF_WIDTH endY: posY + 26];
        default:
            break;
    }
}

// Highlight the point where trains can enter the simulation.
- (void) drawEntryPoint: (NSString*) entryName X: (int) cellX Y: (int) cellY context: (CGContextRef) context {
    int posX = LEFT_MARGIN + cellX * TILE_WIDTH;
    int posY = self.bounds.size.height - (TOP_MARGIN  + cellY * TILE_HEIGHT);
    //CGContextSetShadow(context, CGSizeMake(5.0, 5.0), 3.0);
    [self.inactiveTrackColor setFill];
    CGContextFillRect(context, CGRectMake(posX, posY + TILE_HALF_HEIGHT- 7,
                                          TILE_WIDTH, 14));
    
    // Turn down shadow for text.
    CGContextSetShadow(context, CGSizeMake(2.0, 2.0), 2.0);
    
    // TODO(bowdidge): Better label appearance.
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *fontAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize: 12.0],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: self.entryLabelColor,
                                };
    
    [entryName drawInRect: CGRectMake(posX-ENTRY_POINT_LABEL_WIDTH/2+TILE_WIDTH/2, posY,
                                      ENTRY_POINT_LABEL_WIDTH, ENTRY_POINT_LABEL_HEIGHT)
           withAttributes: fontAttrs];
}

- (CGRect) rectForSignal: (Signal*) signal isTarget: (BOOL) isTarget {
    float posX = LEFT_MARGIN + signal.position.x * TILE_WIDTH;
    float posY = self.bounds.size.height - (TOP_MARGIN  + signal.position.y * TILE_HEIGHT);
    float signalCenterX = 0;
    float signalCenterY = 0;
    if (signal.trafficDirection == EastDirection) {
        signalCenterX = posX + TILE_WIDTH / 2 + SIGNAL_OFFSET_WIDTH,
        signalCenterY = posY + TILE_HEIGHT / 2 + SIGNAL_OFFSET_HEIGHT;
    } else {
        signalCenterX = posX + TILE_WIDTH / 2 - SIGNAL_OFFSET_WIDTH;
        signalCenterY = posY + TILE_HEIGHT / 2 - SIGNAL_OFFSET_HEIGHT;
    }
    if (isTarget) {
        return CGRectMake(signalCenterX - SIGNAL_TARGET_DIAMETER / 2,
                          signalCenterY - SIGNAL_TARGET_DIAMETER/2,
                          SIGNAL_TARGET_DIAMETER, SIGNAL_TARGET_DIAMETER);
    }
    return CGRectMake(signalCenterX - SIGNAL_DIAMETER / 2,
                      signalCenterY - SIGNAL_DIAMETER/2,
                      SIGNAL_DIAMETER, SIGNAL_DIAMETER);
}

// Highlight the point where trains can enter the simulation.
- (void) drawSignal: (Signal*) signal context: (CGContextRef) context {
    CGContextSetShadow(context, CGSizeMake(5.0, 5.0), 3.0);
    [self.targetColor setFill];
    CGContextFillEllipseInRect(context, [self rectForSignal: signal isTarget: true]);
    
    if (signal.isGreen) {
        [self.greenSignalColor setFill];
    } else {
        [self.redSignalColor setFill];
    }

    CGContextFillEllipseInRect(context, [self rectForSignal: signal isTarget: FALSE]);
}

- (void)drawRect:(CGRect)rect
{
    // self.containingScrollView.contentSize = self.viewSize;
    
    CGContextRef context = [NSGraphicsContext currentContext].CGContext;
    [self.backgroundColor setFill];
    CGContextFillRect(context, rect);
    
    // Draw entry points.
    for (NamedPoint *ep in [self.scenario all_endpoints]) {
        [self drawEntryPoint: ep.name X: ep.position.x Y: ep.position.y context: context];
    }
    
    for (Label *label in self.scenario.all_labels) {
        // TILE_WIDTH/2 to center.
        int labelPosX = LEFT_MARGIN + label.position.x * TILE_WIDTH + TILE_WIDTH/2;
        int labelPosY = self.bounds.size.height - (TOP_MARGIN  + label.position.y * TILE_HEIGHT);
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *fontAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize: 14],
                                    NSParagraphStyleAttributeName: paragraphStyle,
                                    NSForegroundColorAttributeName: self.labelColor};
        [label.labelString drawInRect: CGRectMake(labelPosX-LABEL_WIDTH/2,
                                                  labelPosY-LABEL_HEIGHT /2 ,
                                                  LABEL_WIDTH, LABEL_HEIGHT)
                       withAttributes: fontAttrs];
    }
    
    for (Signal *signal in self.scenario.all_signals) {
        [self drawSignal: signal context: context];
    }
    
    CGContextSetLineWidth(context, 10.0);
    
    for (int y = 0; y < self.scenario.tileRows; y++) {
        for (int x = 0; x < self.scenario.tileColumns; x++) {
            float centerX = LEFT_MARGIN + x * TILE_WIDTH;
            float centerY = TOP_MARGIN  + y * TILE_HEIGHT;
            struct CellPosition pos = MakeCellPosition(x,y);
            
            [self drawTileAtCell: pos withContext:context];
            Train *occupyingTrain = [self.layoutModel occupyingTrainAtCell: pos];
            if (occupyingTrain != nil) {
                [self drawTrainLabelInContext:context center: CGPointMake(centerX, centerY)
                                      message: occupyingTrain.trainNumber];
            }
        }
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm:ss"];
    
    NSString *timeString = [format stringFromDate: self.currentTime];
    //self.controller.timeLabel.text = timeString;
    //self.controller.scoreLabel.text = [NSString stringWithFormat: @"Score: %d", self.score];
    
    if (self.displayForEditing) {
        // TODO(bowdidge): Draw grid as place to edit.
        for (int x = 0; x < self.scenario.tileColumns; x++) {
            float centerX = LEFT_MARGIN + x * TILE_WIDTH;
            float lengthY = self.bounds.size.height - (TOP_MARGIN  + (self.scenario.tileRows + 2) * TILE_HEIGHT);
            float indexY = self.bounds.size.height - (TOP_MARGIN  + (self.scenario.tileRows + 1) * TILE_HEIGHT);
            
            [self drawTrainLabelInContext:context center: CGPointMake(centerX, lengthY)
                                  message: [NSString stringWithFormat: @"%d feet", [self.scenario lengthOfCellInFeet:MakeCellPosition(x, 0)]]];
            [self drawTrainLabelInContext:context center: CGPointMake(centerX, indexY)
                                  message: [NSString stringWithFormat: @"%d", x]];
        }
    }
}

- (NSString*) popoverDescriptionForTrain: (Train*) tr{
    NSMutableString *str = [NSMutableString string];
    [str appendFormat: @"%@ %@\n", tr.trainNumber, tr.trainName];
    [str appendFormat: @"Leaving %@ at %@ for %@", tr.startPoint.name, formattedDate(tr.departureTime), [tr endPointsAsText]];
    return str;
}

// Generates the text string used when user selects a train.
- (NSString*) detailForTrain: (Train*) tr {
    NSMutableString *result = [NSMutableString string];
    [result appendFormat: @"%@: %@\n", tr.trainNumber, tr.trainName];
    [result appendFormat: @"%.1f feet from west end of block.", (float) tr.distanceFromWestEndCurrentCell];
    [result appendFormat: @"From '%@' to '%@'\n", tr.startPoint.name, [tr endPointsAsText]];
    [result appendFormat: @"Train should be at destination by %@\n", formattedDate(tr.arrivalTime)];
    [result appendString: tr.trainDescription];
    return result;
}

- (void)mouseDown:(NSEvent *)theEvent {
    CGPoint locationInWindow = theEvent.locationInWindow;
    CGPoint location = [self convertPoint: locationInWindow fromView: nil];
    int cellX = (location.x - LEFT_MARGIN) / TILE_WIDTH;
    int cellY = (self.bounds.size.height - (location.y - TOP_MARGIN)) / TILE_HEIGHT;
    struct CellPosition pos = MakeCellPosition(cellX, cellY);
    if (theEvent.modifierFlags & NSShiftKeyMask) {
        NSLog(@"shift Click on Cell %d,%D", pos.x,pos.y);
    } else {
        NSLog(@"Click on Cell %d,%D", pos.x,pos.y);
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    CGPoint locationInWindow = theEvent.locationInWindow;
    CGPoint location = [self convertPoint: locationInWindow fromView: nil];
    int cellX = (location.x - LEFT_MARGIN) / TILE_WIDTH;
    int cellY = (self.bounds.size.height - (location.y - TOP_MARGIN)) / TILE_HEIGHT;
    struct CellPosition pos = MakeCellPosition(cellX, cellY);
    NSLog(@"Right click on Cell %d,%D", pos.x,pos.y);
    self.lastRightClick = pos;
    
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [theMenu insertItemWithTitle:@"Add row to right" action:@selector(addRowToRight:) keyEquivalent:@"" atIndex:0];
    [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self];
}


@synthesize currentTime;
@synthesize score;

@end
