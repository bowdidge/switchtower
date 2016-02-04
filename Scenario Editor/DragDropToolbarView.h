//
//  DragDropToolbarView.h
//  SwitchTower
//
//  Created by bowdidge on 1/25/16.
//  Copyright © 2016 bowdidge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DragDropToolbarViewDelegate;

// DragDropToolBarView implements a view that draws a "toolbar-like" row of icons
// that can be dragged to other views.
@interface DragDropToolbarView : NSView <NSDraggingSource, NSPasteboardItemDataProvider> {
}

@property (assign) id<DragDropToolbarViewDelegate> delegate;
@property (assign) NSInteger tileSize;
// Index of the tile being dragged.  Used to remember which tile to paste.
@property (assign) NSInteger tileDragged;
// Width / height of each tile.
@property (nonatomic, retain) NSMutableArray *tiles;
// Rectangle inside frame containing the surrounding line and tiles.  Used for mapping to selected tile.
@property (assign) NSRect innerTileRect;

- (id)initWithCoder:(NSCoder *)coder;
// Call each time to set up a new tile.
- (void) registerTile: (NSImage*) tileImage value: (NSString*) value toolTip: (NSString*) toolTip;
@end

@protocol DragDropToolbarViewDelegate <NSObject>

- (void)dropComplete:(NSString *)filePath;

@end

@interface NSImage (ImageAdditions)

+(NSImage *)swatchWithColor:(NSColor *)color size:(NSSize)size;


@end

// Pasteboard type used when dragging a tile.
extern NSString *kTileDragUTI;

