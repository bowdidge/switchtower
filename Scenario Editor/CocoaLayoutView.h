//
//  CocoaLayoutView.h
//  SwitchTower
//
//  Created by bowdidge on 11/30/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

// TODO(bowdidge): Near-identical copy of LayoutView.  Consider breaking out the non-UIKit/Cocoa differences.
// Major differences are API differences and coordinate system.

#import <Cocoa/Cocoa.h>

#import "Cell.h"
#import "LayoutModel.h"

@class Train;
@class EditableScenario;
@class ScenarioDocument;

#define TILE_WIDTH 40.0
#define TILE_HEIGHT 40.0
#define TILE_HALF_WIDTH 20.0
#define TILE_HALF_HEIGHT 20.0
#define TILE_DRAW_WIDTH (TILE_WIDTH - 1.0)
#define TILE_DRAW_HEIGHT (TILE_HEIGHT - 1.0)

#define TRAIN_LABEL_OFFSET_Y 5.0
#define TRAIN_LABEL_HEIGHT 18.0

// Large labels for captions.
#define LABEL_HEIGHT 20.0
#define LABEL_WIDTH 200.0

// Labels for marking entry point tiles.
#define ENTRY_POINT_LABEL_WIDTH 150.0
#define ENTRY_POINT_LABEL_HEIGHT 20.0

#define SIGNAL_OFFSET_WIDTH (TILE_WIDTH / 4)
#define SIGNAL_OFFSET_HEIGHT (TILE_HEIGHT / 4)

#define DASH_WIDTH 10.0

#define LEFT_MARGIN 40.0  // was 40
#define TOP_MARGIN 40.0  // was 100

#define SCREEN_WIDTH 1024
// From Interface Builder.
#define SCREEN_HEIGHT 550

#define SIGNAL_TARGET_DIAMETER 12.0
#define SIGNAL_DIAMETER 8.0
#define SIGNAL_OFFSET ((SIGNAL_TARGET_DIAMETER - SIGNAL_DIAMETER) / 2)

// TrackContext carries color information about how to draw a particular cell.  It allows gathering the
// state of a switch or contents of the track long before drawing.
@interface TrackContext : NSObject {
}
@property (nonatomic, retain) NSColor *normalTrackColor;
@property (nonatomic, retain) NSColor *reversedTrackColor;

@end

// TrackDrawer ("TrackDrawingThingy") hides the logic used for drawing the track tiles in the LayoutView.
// It is a separate class so the same code can draw tiles outside the view (such as for dragging.)
@interface TrackDrawer : NSObject {
}
- (void) drawTile: (char) tile withContext: (CGContextRef) context trackContext: (TrackContext*) tc isReversed: (BOOL) isReversed;

// Color for the target surrounding the signal.
@property(nonatomic, retain) NSColor* targetColor;
@property(nonatomic, retain) NSColor* redSignalColor;
@property(nonatomic, retain) NSColor* greenSignalColor;

@property(nonatomic, retain) NSColor* labelColor;
@property(nonatomic, retain) NSColor* trainLabelColor;
@property(nonatomic, retain) NSColor* entryLabelColor;

@property(nonatomic, retain) NSColor* approachingColor;
@property(nonatomic, retain) NSColor* occupiedColor;
@property(nonatomic, retain) NSColor* activeTrackColor;
@property(nonatomic, retain) NSColor* inactiveTrackColor;
@property(nonatomic, retain) NSColor* platformColor;
@end


// Draws the layout schematic.
// TODO(bowdidge): Consider using SpriteKit.
@interface CocoaLayoutView : NSView<NSDraggingDestination> {
    
}
- (void) setSizeInTilesX: (int) x Y: (int) y;

// Returns x,y coordinates for named cell.  Intended for showing alerts.
- (CGPoint) centerOfPosition: (struct CellPosition) p;

@property(nonatomic) ScenarioDocument *controller;

// Class hiding details of drawing track cells.
@property (nonatomic, retain) TrackDrawer *trackDrawer;

@property(nonatomic, retain) NSDate *currentTime;
@property(nonatomic, retain) NSArray *routeColors;
// LayoutModel contains the running data.
@property(nonatomic, retain) LayoutModel *layoutModel;
// Scenario contains the static data.
@property(nonatomic, retain) EditableScenario *scenario;
//@property(nonatomic, assign) IBOutlet NSScrollView *containingScrollView;
@property(nonatomic, assign) CGSize viewSize;
// TODO(bowdidge): Move score out?
@property(nonatomic, assign) int score;


@property(nonatomic, retain) NSColor* backgroundColor;

// True if layout view should include additional information for an editable view.
@property (nonatomic) BOOL displayForEditing;

// Location of right click, for controller.
@property (nonatomic) struct CellPosition lastRightClick;

// True if we're dragging a tile onto the schematic.  This causes drawRect to show grid for dropping tile.
@property (nonatomic) BOOL draggingTile;

@end
