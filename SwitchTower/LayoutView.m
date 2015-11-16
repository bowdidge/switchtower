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

#import "NamedPoint.h"
#import "Label.h"
#import "Scenario.h"
#import "LayoutView.h"
#import "Signal.h"
#import "Train.h"
#import "LayoutViewController.h"

@implementation LayoutView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    self.viewSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    self.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);;
    NSLog(@"Initing layout view");
    self.containingScrollView.contentSize = self.viewSize;
    self.routeColors = [NSArray arrayWithObjects: [UIColor blueColor], [UIColor purpleColor],
                        [UIColor greenColor], [UIColor orangeColor], nil];
    self.score = 0;
    self.targetColor = [UIColor colorWithWhite: 0.5 alpha: 1.0];
    self.greenSignalColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.redSignalColor = [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0];
    self.labelColor = [UIColor whiteColor];
    self.trainLabelColor = [UIColor whiteColor];
    self.entryLabelColor = [UIColor whiteColor];
    
    self.approachingColor = [UIColor orangeColor];
    self.occupiedColor = [UIColor yellowColor];
    self.activeTrackColor = [UIColor lightGrayColor];
    self.inactiveTrackColor = [UIColor darkGrayColor];
    self.platformColor = [UIColor greenColor];
    
    return self;
}

// Set the size of the game view to match the scenario.
- (void) setSizeInTilesX: (int) x Y: (int) y {
    self.viewSize = CGSizeMake(TILE_WIDTH * x + 160.0, SCREEN_HEIGHT);
    self.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
}

// Work to be done on instantiating the nib.  Note that the view is pre-generated, so
// initialization needs to be here.
- (void) viewDidLoad {
    self.containingScrollView.contentSize = self.viewSize;
    
    self.routeColors = [NSArray arrayWithObjects: [UIColor blueColor], [UIColor purpleColor],
                        [UIColor greenColor], [UIColor orangeColor], nil];

    // Add long tap for the main tiles
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self addGestureRecognizer:longPressGesture];
    [longPressGesture release];
}

// Handle long hold on a particular cell.
-(void) longTap:(UILongPressGestureRecognizer *)gestureRecognizer{
    // TODO(bowdidge): Draw information window for the selected train.
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
            return 0;
        default:
            return TILE_DRAW_HEIGHT;
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
- (void)drawLine:(CGContextRef)context X: (int) cellX Y: (int) cellY
        startDir: (TrackDirection) startDir
          endDir: (TrackDirection) endDir
{
    int posX = LEFT_MARGIN + cellX * TILE_WIDTH;
    int posY = TOP_MARGIN  + cellY * TILE_HEIGHT;

    CGContextMoveToPoint(context, posX + CellXPosOffset(startDir), posY + CellYPosOffset(startDir));
    CGContextAddLineToPoint(context, posX + TILE_HALF_WIDTH, posY + TILE_HALF_HEIGHT);
    CGContextAddLineToPoint(context, posX + CellXPosOffset(endDir), posY + CellYPosOffset(endDir));
    CGContextStrokePath(context);
}

// Sets the appropriate color for the track on the cell based on whether the track is active,
// occupied, etc.
- (void) setTrackColorForCellX: (int) cellX Y: (int) cellY isActive: (BOOL) isActive
                   withContext: (CGContextRef) context{

    Train *occupyingTrain = [self.layoutModel occupyingTrainAtX: cellX Y: cellY];
    BOOL isPath = isActive && [self.layoutModel routeForCellX: cellX Y: cellY] != 0;

    if (isActive && occupyingTrain && occupyingTrain.currentState == Waiting) {
        [self.approachingColor setStroke];
    } else if (isActive && occupyingTrain) {
        [self.occupiedColor setStroke];
    } else if (isPath) {
        int routeNumber = ([self.layoutModel routeForCellX: cellX Y: cellY]);
        UIColor *routeColor = [self.routeColors objectAtIndex: (routeNumber-1) % [self.routeColors count]];
        [routeColor setStroke];
    } else if (isActive) {
        [self.activeTrackColor setStroke];
    } else {
        [self.inactiveTrackColor setStroke];
    }
}

// Draw a switch with multiple possible routings.
- (void) drawSwitchWithContext: (CGContextRef) context
                         cellX: (int) cellX cellY: (int) cellY
                     pointsDir: (TrackDirection) pointsDirection
                     normalDir: (TrackDirection) normalDirection
                    reverseDir: (TrackDirection) reverseDirection {
    if (![self.layoutModel isSwitchNormalX: (int) cellX Y: (int) cellY]) {
        TrackDirection temp = normalDirection;
        normalDirection = reverseDirection;
        reverseDirection = temp;
    }
    
    // Draw reversed first.
    [self setTrackColorForCellX: cellX Y: cellY isActive: 0 withContext: context];
    [self drawLine: context X: cellX Y: cellY startDir: reverseDirection endDir: Center];
    
    [self setTrackColorForCellX: cellX Y: cellY isActive: 1 withContext: context];
    [self drawLine: context X: cellX Y: cellY startDir: pointsDirection endDir: normalDirection];
}

// Draw a train label at the specified position.
- (void)drawTrainLabelInContext:(CGContextRef)context posY:(int)posY posX:(int)posX message:(NSString *)message {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *fontAttrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 12.0],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: self.trainLabelColor};
    [message drawInRect: CGRectMake(posX, posY - TRAIN_LABEL_OFFSET_Y, TILE_WIDTH, TRAIN_LABEL_HEIGHT)
         withAttributes: fontAttrs];
}

- (void)drawTileAtY:(int)y X:(int)x withContext:(CGContextRef)context
{
    int posX = LEFT_MARGIN + x * TILE_WIDTH;
    int posY = TOP_MARGIN  + y * TILE_HEIGHT;
    
    
    char cell = [self.layoutModel.scenario cellAtTileX: x Y: y];
    [self setTrackColorForCellX: x Y: y isActive: YES withContext: context];
    float dashes[2] = {DASH_WIDTH, DASH_WIDTH};
    switch (cell) {
        case ' ':
            // do nothing.
            break;
        case '.':
            // Dotted line for continuation of layout off.
            CGContextSaveGState(context);
            CGContextSetLineDash(context, 0.0, dashes, 2);
            [self drawLine: context X: x Y: y startDir: West endDir: East];
            CGContextRestoreGState(context);
            break;
        case '-':
            [self drawLine: context X: x Y: y startDir: West endDir: East];
            break;
            // Platform.
        case '=':
            [self drawLine: context X: x Y: y startDir: West endDir: East];
            [self.platformColor setStroke];
            [self drawLine: context startX: posX startY: posY + 3
                      endX: posX + TILE_DRAW_WIDTH endY: posY + 3];
            break;
        case 'Z': // lower left to right
            [self drawLine: context X: x Y: y startDir: Southwest endDir: East];
            break;
        case 'z': // left to lower right
            [self drawLine: context X: x Y: y startDir: West endDir: Southeast];
            break;
        case 'P': // left to right, switch to upper right
            [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:West normalDir:East reverseDir:Northeast];
            break;
        case 'p': // left to right, switch to upper left
            [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:East normalDir:West reverseDir:Northwest];
           break;
        case 'Q': // left to right, switch to lower right
            [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:West normalDir:East reverseDir:Southeast];
            break;
        case 'q': // left to right, switch to lower left
            [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:East normalDir:West reverseDir:Southwest];
            break;
        case 'R': // lower left to upper right, switch to right
            [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:Southwest normalDir:Northeast reverseDir:East];
            break;
        case 'r': // upper left to lower right, switch to left
            [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:Southeast normalDir:Northwest reverseDir:West];
            break;
        case 'W': // upper left to right
            [self drawLine: context X: x Y: y startDir: Northwest endDir: East];
            break;
        case 'w': // left to upper right
            [self drawLine: context X: x Y: y startDir: West endDir: Northeast];
            break;
        case 'Y': // left to upper and lower right
            [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:West normalDir:Northeast reverseDir:Southeast];
           break;
        case 'y': // upper and lower left to right
             [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:East normalDir:Northwest reverseDir:Southwest];
            break;
        case 'V': // upper left to lower right, switch to right
             [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:Northwest normalDir:Southeast reverseDir:East];
            break;
        case 'v': // upper right to lower left, switch to left.
             [self drawSwitchWithContext:context cellX:x cellY:y pointsDir:Northeast normalDir:Southwest reverseDir:West];
            break;
        case '\\':
            [self drawLine: context X: x Y: y startDir: Northwest endDir: Southeast];
            break;
        case '/':
            [self drawLine: context X: x Y: y startDir: Northeast endDir: Southwest];
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

- (CGRect) cellRectForX: (int) cellX Y: (int) cellY {
    int posX = LEFT_MARGIN + cellX * TILE_WIDTH;
    int posY = TOP_MARGIN  + cellY * TILE_HEIGHT;
    return CGRectMake(posX, posY, TILE_WIDTH, TILE_HEIGHT);
}

// Highlight the point where trains can enter the simulation.
- (void) drawEntryPoint: (NSString*) entryName X: (int) cellX Y: (int) cellY context: (CGContextRef) context {
    int posX = LEFT_MARGIN + cellX * TILE_WIDTH;
    int posY = TOP_MARGIN  + cellY * TILE_HEIGHT;
    //CGContextSetShadow(context, CGSizeMake(5.0, 5.0), 3.0);
    [self.inactiveTrackColor setFill];
    CGContextFillRect(context, CGRectMake(posX, posY + TILE_HALF_HEIGHT- 7,
                                          TILE_WIDTH, 14));

    // Turn down shadow for text.
    CGContextSetShadow(context, CGSizeMake(2.0, 2.0), 2.0);
    
    // TODO(bowdidge): Better label.
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *fontAttrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 12.0],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: self.entryLabelColor,
                                };

    [entryName drawInRect: CGRectMake(posX-ENTRY_POINT_LABEL_WIDTH/2+TILE_WIDTH/2, posY,
                                      ENTRY_POINT_LABEL_WIDTH, ENTRY_POINT_LABEL_HEIGHT)
                                      withAttributes: fontAttrs];
}

CGRect GetSignalRect(Signal* signal, BOOL isTarget) {
    int posX = LEFT_MARGIN + signal.x * TILE_WIDTH;
    int posY = TOP_MARGIN  + signal.y * TILE_HEIGHT;
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
    CGContextFillEllipseInRect(context, GetSignalRect(signal, TRUE));

    if (signal.isGreen) {
        [self.greenSignalColor setFill];
    } else {
        [self.redSignalColor setFill];
    }
    CGContextFillEllipseInRect(context, GetSignalRect(signal, FALSE));
}

- (void)drawRect:(CGRect)rect
{
    self.containingScrollView.contentSize = self.viewSize;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);

    // Draw entry points.
    for (NamedPoint *ep in [self.scenario all_endpoints]) {
        [self drawEntryPoint: ep.name X: ep.xPosition Y: ep.yPosition context: context];
    }
    
    for (Label *label in self.scenario.all_labels) {
        // TILE_WIDTH/2 to center.
        int labelPosX = LEFT_MARGIN + label.xCenter * TILE_WIDTH + TILE_WIDTH/2;
        int labelPosY = TOP_MARGIN  + label.yCenter * TILE_HEIGHT;
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *fontAttrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 14],
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

    for (int y = 0; y < [self.scenario tileRows]; y++) {
        for (int x = 0; x < [self.scenario tileColumns]; x++) {
            int posX = LEFT_MARGIN + x * TILE_WIDTH;
            int posY = TOP_MARGIN  + y * TILE_HEIGHT;
            
            [self drawTileAtY:y X:x withContext:context];
            Train *occupyingTrain = [self.layoutModel occupyingTrainAtX: x Y: y];
            if (occupyingTrain != nil) {
                [self drawTrainLabelInContext:context posY:posY posX:posX
                                 message: occupyingTrain.trainName];
            }
        }
    }
    
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"HH:mm:ss"];

    NSString *timeString = [format stringFromDate: self.currentTime];
    self.controller.timeLabel.text = timeString;
    self.controller.scoreLabel.text = [NSString stringWithFormat: @"Score: %d", self.score];
}

- (NSString*) popoverDescriptionForTrain: (Train*) tr{
    NSMutableString *str = [NSMutableString string];
    [str appendFormat: @"%@ %@\n", tr.trainName, tr.trainDescription];
    [str appendFormat: @"Leaving %@ at %@ for %@", tr.startPoint.name, formattedDate(tr.departureTime),
     tr.expectedEndPoint.name];
    return str;
}

// Dispatches touches back to the main view to change view to the witchlist of interest.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self];
    int cellX = (location.x - LEFT_MARGIN) / TILE_WIDTH;
    int cellY = (location.y - TOP_MARGIN) / TILE_HEIGHT;
    
    for (Signal *signal in self.layoutModel.scenario.all_signals) {
        CGRect rect = GetSignalRect(signal, TRUE);
        if (CGRectContainsPoint(rect, location)) {
            [self.controller signalTouched: signal];
            [self setNeedsDisplay];
            return;
        }
    }

    if ([self.layoutModel cellIsSwitchX: cellX Y: cellY]) {
        [self.controller switchTouchedX: cellX Y: cellY];
        [self setNeedsDisplay];
    }
    
    // If there's a train there, describe the train.
    Train* tr;
    if ((tr = [self.self.layoutModel occupyingTrainAtX: cellX Y: cellY]) != nil) {
        // TODO(bowdidge): Pop up.
        NSLog(@"%@", [tr description]);
    }
}

@synthesize currentTime;
@synthesize score;

@end
