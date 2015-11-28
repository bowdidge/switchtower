//
//  LayoutView.h
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

#import <UIKit/UIKit.h>

#import "Cell.h"
#import "LayoutModel.h"

@class Train;
@class Scenario;
@class LayoutViewController;

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

// Draws the layout schematic.
// TODO(bowdidge): Consider using SpriteKit.
@interface LayoutView : UIView {

}
- (void) setSizeInTilesX: (int) x Y: (int) y;

// Returns x,y coordinates for named cell.  Intended for showing alerts.
- (CGPoint) centerOfPosition: (struct CellPosition) p;

@property(nonatomic, retain) NSDate *currentTime;
@property(nonatomic, retain) NSArray *routeColors;
// LayoutModel contains the running data.
@property(nonatomic, retain) LayoutModel *layoutModel;
// Scenario contains the static data.
@property(nonatomic, retain) Scenario *scenario;
@property(nonatomic, assign) IBOutlet LayoutViewController *controller;
@property(nonatomic, assign) IBOutlet UIScrollView *containingScrollView;
@property(nonatomic, assign) CGSize viewSize;
// TODO(bowdidge): Move score out?
@property(nonatomic, assign) int score;
// Color for the target surrounding the signal.
@property(nonatomic, retain) UIColor* targetColor;
@property(nonatomic, retain) UIColor* redSignalColor;
@property(nonatomic, retain) UIColor* greenSignalColor;

@property(nonatomic, retain) UIColor* labelColor;
@property(nonatomic, retain) UIColor* trainLabelColor;
@property(nonatomic, retain) UIColor* entryLabelColor;

@property(nonatomic, retain) UIColor* approachingColor;
@property(nonatomic, retain) UIColor* occupiedColor;
@property(nonatomic, retain) UIColor* activeTrackColor;
@property(nonatomic, retain) UIColor* inactiveTrackColor;
@property(nonatomic, retain) UIColor* platformColor;

@property(nonatomic, retain) UIColor* backgroundColor;
// True if layout view should include additional information for an editable view.
@property (nonatomic) BOOL displayForEditing;
@end
