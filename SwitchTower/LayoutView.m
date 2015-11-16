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
    return self;
}

- (void) setSizeInTilesX: (int) x Y: (int) y {
    self.viewSize = CGSizeMake(TILE_WIDTH * x + 160.0, 768.0);
    self.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
}

// Work to be done on instantiating the nib.  Note that the view is pre-generated, so
// initialization needs to be here.
- (void) viewDidLoad {

    // TODO(bowdidge): Not working.  Figure out how to do programmatically - currently set in nib.
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
    int posX = 40.0 + cellX * TILE_WIDTH;
    int posY = 100.0  + cellY * TILE_HEIGHT;

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
        // TODO(bowdidge): Choose better color.
        CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    } else if (isActive && occupyingTrain) {
        CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    } else if (isPath) {
        int routeNumber = ([self.layoutModel routeForCellX: cellX Y: cellY]);
        UIColor *routeColor = [self.routeColors objectAtIndex: (routeNumber-1) % [self.routeColors count]];
        CGContextSetStrokeColorWithColor(context, routeColor.CGColor);
    } else if (isActive) {
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
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

// Draw a label at the specified position.
- (void)drawLabelInContext:(CGContextRef)context color:(UIColor*) color posY:(int)posY posX:(int)posX message:(NSString *)message {
    CGContextSetFillColorWithColor(context, color.CGColor);
    [message drawInRect: CGRectMake(posX, posY - 5.0, TILE_WIDTH, 10.0)
                      withFont: [UIFont boldSystemFontOfSize: 12.0]
                 lineBreakMode: NSLineBreakByClipping alignment: NSTextAlignmentCenter];
}

- (void)drawTileAtY:(int)y X:(int)x withContext:(CGContextRef)context
{
    int posX = 40.0 + x * TILE_WIDTH;
    int posY = 100.0  + y * TILE_HEIGHT;
    
    
    char cell = [self.layoutModel.scenario cellAtTileX: x Y: y];
    [self setTrackColorForCellX: x Y: y isActive: YES withContext: context];
    float dashes[2] = {10.0, 10.0};
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
            CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
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
    int posX = 40.0 + cellX * TILE_WIDTH;
    int posY = 100.0  + cellY * TILE_HEIGHT;
    return CGRectMake(posX, posY, TILE_WIDTH, TILE_HEIGHT);
}

// Highlight the point where trains can enter the simulation.
- (void) drawEntryPoint: (NSString*) entryName X: (int) cellX Y: (int) cellY context: (CGContextRef) context {
    int posX = 40.0 + cellX * TILE_WIDTH;
    int posY = 100.0  + cellY * TILE_HEIGHT;
    //CGContextSetShadow(context, CGSizeMake(5.0, 5.0), 3.0);
    CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1.0);
    CGContextFillRect(context, CGRectMake(posX, posY + TILE_HALF_HEIGHT- 7,
                                          TILE_WIDTH, 14));

    // Turn down shadow for text.
    CGContextSetShadow(context, CGSizeMake(2.0, 2.0), 2.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    // TODO(bowdidge): Better label.
    [entryName drawInRect: CGRectMake(posX-75+TILE_WIDTH/2, posY, 150.0, 20.0)
               withFont: [UIFont boldSystemFontOfSize: 12.0]
          lineBreakMode: NSLineBreakByClipping alignment: NSTextAlignmentCenter];
}

const float TARGET_DIAMETER = 12;
const float SIGNAL_DIAMETER = 8;
const float SIGNAL_OFFSET = (TARGET_DIAMETER - SIGNAL_DIAMETER) / 2;

CGRect GetSignalRect(Signal* signal, BOOL isTarget) {
    int posX = 40.0 + signal.x * TILE_WIDTH;
    int posY = 100.0  + signal.y * TILE_HEIGHT;
    float signalCenterX = 0;
    float signalCenterY = 0;
    if (signal.trafficDirection == EastDirection) {
        signalCenterX = posX + TILE_WIDTH * 0.75;
        signalCenterY = posY + TILE_HEIGHT * 0.75;
    } else {
        signalCenterX = posX + TILE_WIDTH * 0.25;
        signalCenterY = posY + TILE_HEIGHT * 0.25;
    }
    if (isTarget) {
        return CGRectMake(signalCenterX - TARGET_DIAMETER / 2, signalCenterY - TARGET_DIAMETER/2,
                          TARGET_DIAMETER, TARGET_DIAMETER);
    }
    return CGRectMake(signalCenterX - SIGNAL_DIAMETER / 2, signalCenterY - SIGNAL_DIAMETER/2,
                      SIGNAL_DIAMETER, SIGNAL_DIAMETER);
}

// Highlight the point where trains can enter the simulation.
- (void) drawSignal: (Signal*) signal context: (CGContextRef) context {
    CGContextSetShadow(context, CGSizeMake(5.0, 5.0), 3.0);
    CGContextSetRGBFillColor(context, 0.75, 0.75, 0.75, 1.0);
    CGContextFillEllipseInRect(context, GetSignalRect(signal, TRUE));

    if (signal.isGreen) {
        CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 1.0);
    } else {
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
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
    
    // Draw labels.
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    for (Label *label in self.scenario.all_labels) {
        // TILE_WIDTH/2 to center.
        int labelPosX = 40.0 + label.xCenter * TILE_WIDTH + TILE_WIDTH/2;
        // -10 to raise up.
        int labelPosY = 100.0  + label.yCenter * TILE_HEIGHT - 10.0;
        [label.labelString drawInRect: CGRectMake(labelPosX-100.0, labelPosY-10.0, 200.0, 20.0)
                     withFont: [UIFont boldSystemFontOfSize: 14.0]
                lineBreakMode: NSLineBreakByClipping alignment: NSTextAlignmentCenter];
        
    }
    
    for (Signal *signal in self.scenario.all_signals) {
        [self drawSignal: signal context: context];
    }

    CGContextSetLineWidth(context, 10.0);

    for (int y = 0; y < [self.scenario tileRows]; y++) {
        for (int x = 0; x < [self.scenario tileColumns]; x++) {
            int posX = 40.0 + x * TILE_WIDTH;
            int posY = 100.0  + y * TILE_HEIGHT;
            
            [self drawTileAtY:y X:x withContext:context];
            Train *occupyingTrain = [self.layoutModel occupyingTrainAtX: x Y: y];
            if (occupyingTrain != nil) {
                UIColor *labelColor = [UIColor whiteColor];
                [self drawLabelInContext:context color:labelColor posY:posY posX:posX
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
    int cellX = (location.x - 40) / TILE_WIDTH;
    int cellY = (location.y - 100) / TILE_HEIGHT;
    
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
        [self.controller performSegueWithIdentifier: @"popover" sender:self];
        //pc.label.text = [self popoverDescriptionForTrain: tr];
    }
}

@synthesize currentTime;
@synthesize score;

@end
