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

#import "DragDropToolbarView.h"
#import "Label.h"
#import "NamedPoint.h"
#import "Scenario.h"
#import "Signal.h"
#import "Train.h"

@implementation TrackContext
@end

@implementation TrackDrawer
- (id) init {
    self = [super init];
    if (self) {
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
    }
    return self;
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
- (void)drawLine:(CGContextRef)cellContext
        startDir: (TrackDirection) startDir
          endDir: (TrackDirection) endDir
{
    CGContextMoveToPoint(cellContext, CellXPosOffset(startDir), CellYPosOffset(startDir));
    CGContextAddLineToPoint(cellContext, TILE_HALF_WIDTH, TILE_HALF_HEIGHT);
    CGContextAddLineToPoint(cellContext, CellXPosOffset(endDir), CellYPosOffset(endDir));
    CGContextStrokePath(cellContext);
}

// Draw a switch with multiple possible routings.
- (void) drawSwitchWithContext: (CGContextRef) context
                  trackContext: (TrackContext*) tc
                     pointsDir: (TrackDirection) pointsDirection
                     normalDir: (TrackDirection) normalDirection
                    reverseDir: (TrackDirection) reverseDirection
                    isReversed: (BOOL) isReversed {
    if (isReversed) {
        TrackDirection temp = normalDirection;
        normalDirection = reverseDirection;
        reverseDirection = temp;
    }
    
    // Draw reversed first.
    [tc.reversedTrackColor setStroke];
    [self drawLine: context startDir: reverseDirection endDir: Center];
    
    [tc.normalTrackColor setStroke];
    [self drawLine: context startDir: pointsDirection endDir: normalDirection];
}

// Draw a specified tile at 0,0 with the provided context.
- (void) drawTile: (char) tile withContext: (CGContextRef) context trackContext: (TrackContext*) tc isReversed: (BOOL) isReversed {
    [tc.normalTrackColor setStroke];
    CGContextSetLineWidth(context, 10.0);
    
    switch (tile) {
        case ' ':
            // do nothing.
            break;
        case '.':
            // Dotted line for continuation of layout off.
            CGContextSaveGState(context);
            //CGContextSetLineDash(context, 0.0, dashes, 2);
            [self drawLine: context startDir: West endDir: East];
            CGContextRestoreGState(context);
            break;
        case '-':
            [self drawLine: context startDir: West endDir: East];
            break;
            // Platform.
        case '=':
            [self drawLine: context  startDir: West endDir: East];
            [self.platformColor setStroke];
            [self drawLine: context startX: 0 startY: 3
                      endX: TILE_DRAW_WIDTH endY: 3];
            break;
        case 'Z': // lower left to right
            [self drawLine: context startDir: Southwest endDir: East];
            break;
        case 'z': // left to lower right
            [self drawLine: context startDir: West endDir: Southeast];
            break;
        case 'P': // left to right, switch to upper right
            [self drawSwitchWithContext:context trackContext: tc pointsDir:West normalDir:East reverseDir:Northeast isReversed: isReversed];
            break;
        case 'p': // left to right, switch to upper left
            [self drawSwitchWithContext:context trackContext: tc pointsDir:East normalDir:West reverseDir:Northwest isReversed: isReversed];
            break;
        case 'Q': // left to right, switch to lower right
            [self drawSwitchWithContext:context trackContext: tc pointsDir:West normalDir:East reverseDir:Southeast isReversed: isReversed];
            break;
        case 'q': // left to right, switch to lower left
            [self drawSwitchWithContext:context trackContext: tc pointsDir:East normalDir:West reverseDir:Southwest isReversed: isReversed];
            break;
        case 'R': // lower left to upper right, switch to right
            [self drawSwitchWithContext:context trackContext: tc pointsDir:Southwest normalDir:Northeast reverseDir:East isReversed: isReversed];
            break;
        case 'r': // upper left to lower right, switch to left
            [self drawSwitchWithContext:context trackContext: tc pointsDir:Southeast normalDir:Northwest reverseDir:West isReversed: isReversed];
            break;
        case 'W': // upper left to right
            [self drawLine: context startDir: Northwest endDir: East];
            break;
        case 'w': // left to upper right
            [self drawLine: context startDir: West endDir: Northeast];
            break;
        case 'Y': // left to upper and lower right
            [self drawSwitchWithContext:context trackContext: tc pointsDir:West normalDir:Northeast reverseDir:Southeast isReversed: isReversed];
            break;
        case 'y': // upper and lower left to right
            [self drawSwitchWithContext:context trackContext: tc pointsDir:East normalDir:Northwest reverseDir:Southwest isReversed: isReversed];
            break;
        case 'V': // upper left to lower right, switch to right
            [self drawSwitchWithContext:context trackContext: tc pointsDir:Northwest normalDir:Southeast reverseDir:East isReversed: isReversed];
            break;
        case 'v': // upper right to lower left, switch to left.
            [self drawSwitchWithContext:context trackContext: tc pointsDir:Northeast normalDir:Southwest reverseDir:West isReversed: isReversed];
            break;
        case '\\':
            [self drawLine: context  startDir: Northwest endDir: Southeast];
            break;
        case '/':
            [self drawLine: context startDir: Northeast endDir: Southwest];
            break;
        case 'T': // spur open to right
            [tc.normalTrackColor setStroke];
            [self drawLine: context startX: TILE_HALF_WIDTH startY: TILE_HALF_HEIGHT
                      endX: TILE_DRAW_WIDTH endY: TILE_HALF_HEIGHT];
            [self drawLine: context startX: TILE_HALF_WIDTH startY: 5
                      endX: TILE_HALF_WIDTH endY: 26];
            break;
        case 't': // spur open to left.
            [tc.normalTrackColor setStroke];
            [self drawLine: context startX: TILE_HALF_WIDTH startY:  TILE_HALF_HEIGHT
                      endX: 0 endY: TILE_HALF_HEIGHT];
            [self drawLine: context startX: TILE_HALF_WIDTH startY: 5
                      endX: TILE_HALF_WIDTH endY: 26];
        default:
            break;
    }
}

@end


@implementation CocoaLayoutView

- (id) initWithCoder: (NSCoder*) coder {
    self = [super initWithCoder: coder];
    self.viewSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    self.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);;
    NSLog(@"Initing layout view");
   // self.containingScrollView.contentSize = self.viewSize;
    self.displayForEditing = true;
    self.score = 0;
    self.trackDrawer = [[TrackDrawer alloc] init];
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
    // Aim for CTC green.
    self.backgroundColor = [NSColor colorWithRed:32.0/256 green: 48.0/256 blue: 30.0/256 alpha: 1.0];
    self.displayForEditing = true;
    [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                   NSPasteboardTypeTIFF, kTileDragUTI, nil]];
}


- (TrackContext*) trackContextForCell: (struct CellPosition) pos {
    TrackContext *ret = [[TrackContext alloc] init];
    NSColor *trackColor = self.trackDrawer.activeTrackColor;
    
    Train *occupyingTrain = [self.layoutModel occupyingTrainAtCell: pos];
    BOOL isPath = [self.layoutModel routeForCell: pos] != 0;
    
    if (occupyingTrain && occupyingTrain.currentState == Waiting) {
        trackColor = self.trackDrawer.approachingColor;
    } else if (occupyingTrain) {
        trackColor = self.trackDrawer.occupiedColor;
    } else if (isPath) {
        int routeNumber = ([self.layoutModel routeForCell: pos]);
        NSColor *routeColor = [self.routeColors objectAtIndex: (routeNumber-1) % [self.routeColors count]];
        trackColor = routeColor;
    }
    ret.normalTrackColor = trackColor;
    ret.reversedTrackColor = self.trackDrawer.inactiveTrackColor;
    return ret;
}


- (NSRect) boundsForTile: (struct CellPosition) pos {
    return NSMakeRect(LEFT_MARGIN + pos.x * TILE_WIDTH, self.bounds.size.height - TOP_MARGIN - (pos.y * TILE_HEIGHT) - TILE_HEIGHT,
                      TILE_WIDTH, TILE_HEIGHT);
}


// Draw the specified tile at the particular location.
- (void)drawTile: (char) tile atCell: (struct CellPosition) pos withContext:(CGContextRef)context {
    TrackContext *tc = [self trackContextForCell: pos];

    BOOL isReversed = false;
    if ([self.layoutModel cellIsSwitch: pos] && ![self.layoutModel isSwitchNormal: pos]) {
        isReversed = true;
    }

    CGContextSaveGState(context);
    NSRect tileBounds = [self boundsForTile: pos];
    CGContextTranslateCTM(context, tileBounds.origin.x, tileBounds.origin.y);
    [self.trackDrawer drawTile: tile withContext: (CGContextRef) context trackContext: (TrackContext*) tc isReversed: isReversed];
    CGContextRestoreGState(context);
}

// Draw the specified cell in the current layout model.
- (void)drawTileAtCell: (struct CellPosition) pos withContext:(CGContextRef)context
{
    char tile = [self.layoutModel.scenario tileAtCell: pos];
    [self drawTile: tile atCell:  pos withContext: context];
}

// Highlight the point where trains can enter the simulation.
- (void) drawEntryPoint: (NSString*) entryName cell: (struct CellPosition) pos context: (CGContextRef) context {
    NSRect tileBounds = [self boundsForTile: pos];
    //CGContextSetShadow(context, CGSizeMake(5.0, 5.0), 3.0);
    [self.trackDrawer.inactiveTrackColor setFill];
    CGContextFillRect(context, CGRectMake(tileBounds.origin.x, tileBounds.origin.y + TILE_HALF_HEIGHT- 7,
                                          TILE_WIDTH, 14));
    
    // Turn down shadow for text.
    CGContextSetShadow(context, CGSizeMake(2.0, 2.0), 2.0);
    
    // TODO(bowdidge): Better label appearance.
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *fontAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize: 12.0],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: self.trackDrawer.entryLabelColor,
                                };
    
    [entryName drawInRect: CGRectMake(tileBounds.origin.x-ENTRY_POINT_LABEL_WIDTH/2+TILE_WIDTH/2, tileBounds.origin.y,
                                      ENTRY_POINT_LABEL_WIDTH, ENTRY_POINT_LABEL_HEIGHT)
           withAttributes: fontAttrs];
}

- (CGRect) rectForSignal: (Signal*) signal isTarget: (BOOL) isTarget {
    NSRect tileBounds = [self boundsForTile: signal.position];
    float signalCenterX = 0;
    float signalCenterY = 0;
    if (signal.trafficDirection == EastDirection) {
        signalCenterX = tileBounds.origin.x + TILE_WIDTH / 2 + SIGNAL_OFFSET_WIDTH,
        signalCenterY = tileBounds.origin.y + TILE_HEIGHT / 2 + SIGNAL_OFFSET_HEIGHT;
    } else {
        signalCenterX = tileBounds.origin.x + TILE_WIDTH / 2 - SIGNAL_OFFSET_WIDTH;
        signalCenterY = tileBounds.origin.y + TILE_HEIGHT / 2 - SIGNAL_OFFSET_HEIGHT;
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
    [self.trackDrawer.targetColor setFill];
    CGContextFillEllipseInRect(context, [self rectForSignal: signal isTarget: true]);
    
    if (signal.isGreen) {
        [self.trackDrawer.greenSignalColor setFill];
    } else {
        [self.trackDrawer.redSignalColor setFill];
    }

    CGContextFillEllipseInRect(context, [self rectForSignal: signal isTarget: FALSE]);
}

- (void)drawGrid:(CGContextRef)context
{
    // Draw grid for placement.
    [[NSColor whiteColor] setStroke];
    for (int x = 0; x <= self.scenario.tileColumns; x++) {
        CGContextMoveToPoint(context, LEFT_MARGIN + x * TILE_WIDTH, self.bounds.size.height - TOP_MARGIN);
        CGContextAddLineToPoint(context, LEFT_MARGIN + x * TILE_WIDTH, self.bounds.size.height - (TOP_MARGIN + self.scenario.tileRows * TILE_HEIGHT));
        CGContextStrokePath(context);
    }
    for (int y = 0; y <= self.scenario.tileRows; y++) {
        CGContextMoveToPoint(context, LEFT_MARGIN, self.bounds.size.height - (TOP_MARGIN + y * TILE_HEIGHT));
        CGContextAddLineToPoint(context, LEFT_MARGIN + self.scenario.tileColumns * TILE_WIDTH, self.bounds.size.height - (TOP_MARGIN + y * TILE_HEIGHT));
        CGContextStrokePath(context);
    }
}

// Returns the NSPoint describing the center of the rectangle provided.
CGPoint CenterOfRectangle(CGRect r) {
    return CGPointMake(r.origin.x + r.size.width / 2, r.origin.y + r.size.height / 2);
}

// Draw a train label at the specified position.
- (void)drawTrainLabelInContext:(CGContextRef)context center: (CGPoint) center  message:(NSString *)message {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *fontAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize: 12.0],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: self.trackDrawer.trainLabelColor};
    [message drawInRect: CGRectMake(center.x, center.y - TRAIN_LABEL_OFFSET_Y, TILE_WIDTH, TRAIN_LABEL_HEIGHT)
         withAttributes: fontAttrs];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = [NSGraphicsContext currentContext].CGContext;
    [self.backgroundColor setFill];
    CGContextFillRect(context, rect);
    
    if (self.draggingTile) {
        [self drawGrid:context];
    }

    
    // Draw entry points.
    for (NamedPoint *ep in [self.scenario all_endpoints]) {
        [self drawEntryPoint: ep.name cell: ep.position context: context];
    }
    
    for (Label *label in self.scenario.all_labels) {
        // TILE_WIDTH/2 to center.
        NSRect cellBounds = [self boundsForTile: label.position];
        int labelPosX = cellBounds.origin.x + TILE_WIDTH / 2;
        int labelPosY = cellBounds.origin.y + TILE_HEIGHT / 2;
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *fontAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize: 14],
                                    NSParagraphStyleAttributeName: paragraphStyle,
                                    NSForegroundColorAttributeName: self.trackDrawer.labelColor};
        [label.labelString drawInRect: CGRectMake(labelPosX-LABEL_WIDTH/2,
                                                  labelPosY-LABEL_HEIGHT /2 ,
                                                  LABEL_WIDTH, LABEL_HEIGHT)
                       withAttributes: fontAttrs];
    }
    
    for (Signal *signal in self.scenario.all_signals) {
        [self drawSignal: signal context: context];
    }
    
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
    
    if (self.displayForEditing) {
        // Draw train lengths and other information not needed during gaming.
        for (int x = 0; x < self.scenario.tileColumns; x++) {
            // Only using for X.
            NSRect lengthCellBounds = [self boundsForTile: MakeCellPosition(x, self.scenario.tileRows + 1)];
            NSRect indexCellBounds = [self boundsForTile: MakeCellPosition(x, self.scenario.tileRows + 2)];
            
            [self drawTrainLabelInContext:context center: CenterOfRectangle(lengthCellBounds)
                                  message: [NSString stringWithFormat: @"%d feet", (int) [self.scenario lengthOfCellInFeet:MakeCellPosition(x, 0)]]];
            [self drawTrainLabelInContext:context center: CenterOfRectangle(indexCellBounds)
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
    [theMenu insertItemWithTitle:@"Add column to right" action:@selector(addColumnToRight:) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:@"Remove column" action:@selector(removeColumn:) keyEquivalent:@"" atIndex:1];
    [theMenu insertItemWithTitle:@"Add row below" action:@selector(addRowBelow:) keyEquivalent:@"" atIndex:2];
    [theMenu insertItemWithTitle:@"Remove row" action:@selector(removeRow:) keyEquivalent:@"" atIndex:3];
   [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self];
}

- (CGPoint) centerOfPosition: (struct CellPosition) p {
    float x = LEFT_MARGIN + p.x * TILE_WIDTH - TILE_WIDTH/2;
    float y = self.bounds.size.height - (TOP_MARGIN + p.y * TILE_HEIGHT - TILE_HEIGHT / 2);
    return CGPointMake(x,y);
}

#pragma mark - Destination Operations

// Watch for drags of tiles from the DragDropView to the Scenario.
// Turn on the grid appearance of the view,
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag enters our drop zone
     --------------------------------------------------------*/
    
    // Check if the pasteboard contains image data and source/user wants it copied
    //highlight our drop zone
    self.draggingTile = YES;
    [self setNeedsDisplay: YES];
    
    /* When an image from one window is dragged over another, we want to resize the dragging item to
     * preview the size of the image as it would appear if the user dropped it in. */
    [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent
                                      forView:self
                                      classes:[NSArray arrayWithObject:[NSPasteboardItem class]]
                                searchOptions:nil
                                   usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                       
                                       /* Only resize a fragging item if it originated from one of our windows.  To do this,
                                        * we declare a custom UTI that will only be assigned to dragging items we created.  Here
                                        * we check if the dragging item can represent our custom UTI.  If it can't we stop. */
                                       if ( ![[[draggingItem item] types] containsObject:kTileDragUTI] ) {
                                           
                                           *stop = YES;
                                           
                                       } else {
                                           /* In order for the dragging item to actually resize, we have to reset its contents.
                                            * The frame is going to be the destination view's bounds.  (Coordinates are local
                                            * to the destination view here).
                                            * For the contents, we'll grab the old contents and use those again.  If you wanted
                                            * to perform other modifications in addition to the resize you could do that here. */
                                           [draggingItem setDraggingFrame:self.bounds contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
                                       }
                                   }];
    
    //accept data as a copy operation
    return NSDragOperationCopy;
}

// Handle shutting off the grid appearance when the tile drag exits the view.
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    //remove highlight of the drop zone
    self.draggingTile = NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}


- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSString *available = [pboard availableTypeFromArray: [NSArray arrayWithObject: kTileDragUTI]];
    NSLog(@"Available: %@", available);
    NSString *tileString = [pboard propertyListForType:kTileDragUTI];
    
    CGPoint loc = [self convertPoint: [sender draggingLocation] fromView: nil];
    int x = (loc.x - LEFT_MARGIN) / TILE_WIDTH;
    int y = ((self.bounds.size.height - loc.y) - TOP_MARGIN) / TILE_HEIGHT;
    NSLog(@"Dropping tile %@ at %d, %d", tileString, x, y);
    // TODO(bowdidge): Fix encoding lossiness with backslashes and spaces.
    if (tileString.length == 0) {
        tileString = @"\\";
    }
    char tile = [tileString characterAtIndex: 0];
    [self.scenario changeTile: tile atCell: MakeCellPosition(x, y)];

    self.draggingTile = NO;
    [self setNeedsDisplay: YES];

    return TRUE;
}


@synthesize currentTime;
@synthesize score;

@end
