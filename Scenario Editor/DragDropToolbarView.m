//
//  DragDropToolbarView.m
//  SwitchTower
//
//  Created by bowdidge on 1/25/16.
//  Copyright © 2016 bowdidge. All rights reserved.
//

#import "DragDropToolbarView.h"

@implementation NSImage (ImageAdditions)

+(NSImage *)swatchWithColor:(NSColor *)color size:(NSSize)size
{
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [color drawSwatchInRect:NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    return image;
}

@end

extern NSString *kTileDragUTI;

// Object representing a single tile in the DragDropToolbarView.
@interface DragDropTile : NSObject {
}

- (id) initWithImage: (NSImage*) image value: (NSString*) value toolTip: (NSString*) toolTip;

// Image to show.
@property (nonatomic, retain) NSImage *image;
// Value to copy and paste when dragging.
@property (nonatomic, retain) NSString *value;
// Tool tip to show when hovering.
@property (nonatomic, retain) NSString *toolTip;

@end


@implementation DragDropTile
- (id) initWithImage: (NSImage*) img value: (NSString*) val toolTip: (NSString*) tip {
    self = [super init];
    if (self) {
        self.image = img;
        self.value = val;
        self.toolTip = tip;
    }
    return self;
}

@synthesize image;
@synthesize value;
@synthesize toolTip;
@end

@implementation DragDropToolbarView

@synthesize delegate;

NSString *kTileDragUTI = @"com.vasonabranch.cocoadraganddrop";

- (id)initWithCoder:(NSCoder *)coder
{
    /*------------------------------------------------------
     Init method called for Interface Builder objects
     --------------------------------------------------------*/
    self=[super initWithCoder:coder];
    if ( self ) {
        self.tiles = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Source Operations

NSImage *partOfImage(NSImage *input, NSRect targetRect) {
    if (input) {
        NSImage *output = [[NSImage alloc] initWithSize: targetRect.size];
        [output lockFocus];
        [input
         drawAtPoint: NSZeroPoint
         fromRect: targetRect
         operation: NSCompositeCopy
         fraction:  1.0f];
        [output unlockFocus];
        return output;
    } else {
        return nil;
    }
}

float INNER_BOUND = 4.0; // 2 pixels around each tile.
float INNER_LINE_WIDTH = 1.0; // width of line around all tiles.
float TILE_HEIGHT = 40.0;
float TILE_WIDTH = 40.0;

NSRect CenteredRectInRect(NSRect container, NSSize inner) {
    return NSMakeRect((container.size.width - inner.width) / 2, (container.size.height - inner.height) / 2, inner.width, inner.height);
}

- (void) drawRect: (NSRect) rect {
    CGContextRef context = [NSGraphicsContext currentContext].CGContext;
    [[NSColor darkGrayColor] setFill];
    CGContextFillRect(context, rect);
    
    NSInteger tileCount = self.tiles.count;
    // x: INNER_BOUND
    NSSize tileContainerSize = NSMakeSize(INNER_LINE_WIDTH + tileCount * (INNER_LINE_WIDTH + INNER_BOUND + TILE_HEIGHT + INNER_BOUND),
                                          INNER_LINE_WIDTH + INNER_BOUND + TILE_HEIGHT + INNER_BOUND + INNER_LINE_WIDTH);

    NSRect innerLine = CenteredRectInRect(self.frame, tileContainerSize);
    // Draw box 1 pixel wide 2 pixels from boundaries of tiles.
    [[NSColor whiteColor] setStroke];
    CGContextStrokeRect(context, innerLine);
    self.innerTileRect = innerLine;

    for (int i=0; i < self.tiles.count; i++) {
        NSRect tileBox = NSMakeRect(innerLine.origin.x +  i * (INNER_LINE_WIDTH + INNER_BOUND + TILE_WIDTH + INNER_BOUND) + INNER_LINE_WIDTH + INNER_BOUND,
                                    innerLine.origin.y + INNER_LINE_WIDTH + INNER_BOUND,
                                    TILE_WIDTH, TILE_HEIGHT);
        DragDropTile *tile = [self.tiles objectAtIndex: i];
        [tile.image drawInRect: tileBox];
    }
}


- (void) registerTile: (NSImage*) tileImage value: (NSString*) value toolTip: (NSString*) tip {
    DragDropTile *tile = [[DragDropTile alloc] initWithImage: tileImage value: value toolTip: tip];
    [self.tiles addObject: tile];
}


- (void)mouseDown:(NSEvent*)event
{
    /*------------------------------------------------------
     catch mouse down events in order to start drag
     --------------------------------------------------------*/
    
    /* Dragging operation occur within the context of a special pasteboard (NSDragPboard).
     * All items written or read from a pasteboard must conform to NSPasteboardWriting or
     * NSPasteboardReading respectively.  NSPasteboardItem implements both these protocols
     * and is as a container for any object that can be serialized to NSData. */
    
    NSPasteboardItem *pbItem = [NSPasteboardItem new];
    /* Our pasteboard item will support public.tiff, public.pdf, and our custom UTI (see comment in -draggingEntered)
     * representations of our data (the image).  Rather than compute both of these representations now, promise that
     * we will provide either of these representations when asked.  When a receiver wants our data in one of the above
     * representations, we'll get a call to  the NSPasteboardItemDataProvider protocol method –pasteboard:item:provideDataForType:. */
    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObjects: kTileDragUTI, NSPasteboardTypeTIFF, nil]];
    
    //create a new NSDraggingItem with our pasteboard item.
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    
    /* The coordinates of the dragging frame are relative to our view.  Setting them to our view's bounds will cause the drag image
     * to be the same size as our view.  Alternatively, you can set the draggingFrame to an NSRect that is the size of the image in
     * the view but this can cause the dragged image to not line up with the mouse if the actual image is smaller than the size of the
     * our view. */
    //NSRect draggingRect = self.bounds;
    
    CGPoint location = [self convertPoint: event.locationInWindow fromView: nil];

    if (!NSMouseInRect(location, self.innerTileRect, false)) {
        NSLog(@"Outside.");
        return;
    }
    int tileIndex = (location.x - self.innerTileRect.origin.x - INNER_LINE_WIDTH) / (TILE_WIDTH + 2 * INNER_BOUND + INNER_LINE_WIDTH);

    self.tileDragged = tileIndex;
    
    /* While our dragging item is represented by an image, this image can be made up of multiple images which
     * are automatically composited together in painting order.  However, since we are only dragging a single
     * item composed of a single image, we can use the convince method below. For a more complex example
     * please see the MultiPhotoFrame sample. */
    NSRect draggingRect = NSMakeRect(self.tileSize * self.tileDragged, 0, self.tileSize, self.tileSize);
    [dragItem setDraggingFrame:draggingRect contents: [[NSImage alloc] initWithSize: NSMakeSize(self.tileSize, self.tileSize)]];
    
    //create a dragging session with our drag item and ourself as the source.
    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:event source:self];
    
    //causes the dragging item to slide back to the source if the drag fails.
    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
    draggingSession.draggingFormation = NSDraggingFormationNone;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    /*------------------------------------------------------
     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
     --------------------------------------------------------*/
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
            
            //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationCopy;
            break;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    /*------------------------------------------------------
     accept activation click as click in window
     --------------------------------------------------------*/
    //so source doesn't have to be the active window
    return YES;
}

- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
{
    /*------------------------------------------------------
     method called by pasteboard to support promised
     drag types.
     --------------------------------------------------------*/
    //sender has accepted the drag and now we need to send the data for the type we promised
    if ((self.tileDragged < 0) || (self.tileDragged >= self.tiles.count)) {
        return;
    }
    DragDropTile *tile = [self.tiles objectAtIndex: self.tileDragged];
    // TODO(bowdidge): Redo so lossiness doesn't matter.
    NSString *tileToEncode = [NSString stringWithFormat: @"'%@'", tile.value];
    if ([type compare: kTileDragUTI] == NSOrderedSame) {
        [sender setData: [tileToEncode dataUsingEncoding:NSUTF8StringEncoding] forType: kTileDragUTI];
    } else if ( [type compare: NSPasteboardTypeTIFF] == NSOrderedSame ) {
        
        //set data for TIFF type on the pasteboard as requested
        [sender setData:[tile.image TIFFRepresentation] forType:NSPasteboardTypeTIFF];

    }
}
@end



