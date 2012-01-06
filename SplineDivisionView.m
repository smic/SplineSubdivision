//
//  SplineDivisionView.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SplineDivisionView.h"
#import "NSBezierPath+Subdivision.h"


static char SplineDivisionViewObservationContext;

typedef struct {
    NSUInteger elementIndex;
    NSUInteger pointIndex;
} PathPoint;

@interface SplineDivisionView ()

- (NSUInteger)numberOfPointsForElement:(NSBezierPathElement)element;
- (PathPoint)pathPointUnderMouse:(NSPoint)point;
- (void)drawHandleAtPoint:(NSPoint)point;
    
@end


@implementation SplineDivisionView

@synthesize path = _path;
@synthesize pathStart = _pathStart;
@synthesize pathEnd = _pathEnd;

#pragma mark - Initialization / Deallocation

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        // add tracking area to get mouse events
        NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:frame
                                                                     options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                                       owner:self userInfo:nil] autorelease];
		[self addTrackingArea:trackingArea];
        
        // add observer for properties
        [self addObserver:self 
               forKeyPath:@"path" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&SplineDivisionViewObservationContext];
        [self addObserver:self 
               forKeyPath:@"pathStart" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&SplineDivisionViewObservationContext];
        [self addObserver:self 
               forKeyPath:@"pathEnd" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&SplineDivisionViewObservationContext];
    }
    return self;
}

- (void)dealloc {
    // remove observer for properties
    [self removeObserver:self 
              forKeyPath:@"path" 
                 context:&SplineDivisionViewObservationContext];
    [self removeObserver:self 
              forKeyPath:@"pathStart" 
                 context:&SplineDivisionViewObservationContext];
    [self removeObserver:self 
              forKeyPath:@"pathEnd" 
                 context:&SplineDivisionViewObservationContext];
    
	self.path = nil;
    
	[super dealloc];
}

#pragma mark - User interaction

// number of point for a given path element
- (NSUInteger)numberOfPointsForElement:(NSBezierPathElement)element {
    switch (element) {
        case NSMoveToBezierPathElement:
            return 1;
        case NSLineToBezierPathElement:
            return 1;
        case NSCurveToBezierPathElement:
            return 3;
        case NSClosePathBezierPathElement:
            return 0;
            
        default:
            return 0;
            break;
    }
}

// determine a path element and the corresponding point under a given point
- (PathPoint)pathPointUnderMouse:(NSPoint)point {
	NSUInteger numberOfElements = [self.path elementCount];
    
    NSPoint points[3];
    for (NSUInteger elementIndex = 0; elementIndex < numberOfElements; elementIndex++) {
        
        NSBezierPathElement element = [self.path elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        NSUInteger numberOfPoints = [self numberOfPointsForElement:element];
        for (NSInteger pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
            NSPoint selectedPoint = points[pointIndex];
            NSRect handleRect = NSInsetRect(NSMakeRect(selectedPoint.x, selectedPoint.y, 0, 0), -5, -5);
            if (NSPointInRect(point, handleRect)) {
                return (PathPoint){elementIndex, pointIndex};
            }
        }
    }
    return (PathPoint){NSNotFound, NSNotFound};
}

- (void)mouseDown:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	PathPoint selectedPathPoint = [self pathPointUnderMouse:point];
	if (selectedPathPoint.elementIndex == NSNotFound) return;
	
    [[NSCursor closedHandCursor] set];
	NSRect bounds = self.bounds;
	while ([event type]!=NSLeftMouseUp) {
		event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		NSPoint currentPoint = [self convertPoint:[event locationInWindow] fromView:nil];
		currentPoint.x = fminf(fmaxf(currentPoint.x, bounds.origin.x), bounds.size.width);
		currentPoint.y = fminf(fmaxf(currentPoint.y, bounds.origin.y), bounds.size.height);
		
		CGFloat dx = currentPoint.x-point.x;
		CGFloat dy = currentPoint.y-point.y;
        
        NSPoint points[3];
        NSBezierPathElement element = [self.path elementAtIndex:(NSInteger)selectedPathPoint.elementIndex associatedPoints:points];
        
        // move point
        points[selectedPathPoint.pointIndex].x += dx;
        points[selectedPathPoint.pointIndex].y += dy;
        [self.path setAssociatedPoints:points atIndex:(NSInteger)selectedPathPoint.elementIndex];
                
        // move also the control points of a spline
        if (element == NSCurveToBezierPathElement && 
            selectedPathPoint.pointIndex == 2) {
            points[1].x += dx;
            points[1].y += dy;
            [self.path setAssociatedPoints:points atIndex:(NSInteger)selectedPathPoint.elementIndex];
        }
        if ((element == NSMoveToBezierPathElement ||
             element == NSLineToBezierPathElement ||
             element == NSCurveToBezierPathElement) &&
            selectedPathPoint.pointIndex + 1 == [self numberOfPointsForElement:element] &&
            selectedPathPoint.elementIndex + 1 < [self.path elementCount]) {
            NSPoint nextPoints[3];
            NSBezierPathElement nextElement = [self.path elementAtIndex:(NSInteger)selectedPathPoint.elementIndex + 1 associatedPoints:nextPoints];
            if (nextElement == NSCurveToBezierPathElement) {
                nextPoints[0].x += dx;
                nextPoints[0].y += dy;
                [self.path setAssociatedPoints:nextPoints atIndex:(NSInteger)selectedPathPoint.elementIndex + 1];
            }
        }

		point = currentPoint;
        
        [self setNeedsDisplay:YES];
	}
    
    [[NSCursor openHandCursor] set];
}

- (void)mouseMoved:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	PathPoint selectedPathPoint = [self pathPointUnderMouse:point];
	if (selectedPathPoint.elementIndex == NSNotFound) {
		[[NSCursor arrowCursor] set];
	} else {
		[[NSCursor openHandCursor] set];
	}
}

- (void)mouseEntered:(NSEvent *)event {
	[[NSCursor arrowCursor] push];
}

- (void)mouseExited:(NSEvent *)event {
	[NSCursor pop];
}

#pragma mark - Drawinng

- (void)drawRect:(NSRect)rect {
    
    // fill background
    [[NSColor whiteColor] set];
    NSRectFill(rect);
    
    // draw borders
    [NSBezierPath setDefaultLineWidth:0.0f];
    [[NSColor lightGrayColor] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds)) 
                              toPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    [[NSColor darkGrayColor] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds)) 
                              toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];

    // draw complete path
    [[NSColor colorWithCalibratedRed:0.078 green:0.353 blue:0.549 alpha:1.] set];
    self.path.lineWidth = 0.0f;
	[self.path stroke];
    
    // draw sub-path
    NSBezierPath *subpath = [self.path subpathFromLength:self.pathStart toLength:self.pathEnd];
	
	[[NSColor colorWithDeviceRed:22.0f/255.0f green:32.0f/55.0f blue:27.0f/255.0f alpha:1.0f] set];
	subpath.lineWidth = 20.0f;
	[subpath stroke];
	
	[[NSColor colorWithDeviceRed:30.0f/255.0f green:60.0f/55.0f blue:75.0f/255.0f alpha:0.8f] set];
	subpath.lineWidth = 0.0f;
	[subpath stroke];
	
	CGFloat dashPattern[2];
	dashPattern[0] = 5.0f;
	dashPattern[1] = 2.0f;
    
    // draw tangents to the control points
    NSPoint points[3];
    NSPoint previousPoint;
    NSUInteger numberOfElements = [self.path elementCount];
    for (NSUInteger elementIndex = 0; elementIndex < numberOfElements; elementIndex++) {
        NSBezierPathElement element = [self.path elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                previousPoint = points[0];
            } break;
                
            case NSLineToBezierPathElement: {
                previousPoint = points[0];
            } break;
                
            case NSCurveToBezierPathElement: {
                [[NSColor redColor] set];
                NSBezierPath *path2 = [NSBezierPath bezierPath];
                [path2 setLineDash:dashPattern count: 2 phase: 0.0];
                [path2 moveToPoint:previousPoint];
                [path2 lineToPoint:points[0]];
                [path2 moveToPoint:points[1]];
                [path2 lineToPoint:points[2]];
                [path2 stroke];
                
                previousPoint = points[2];
            } break;
                
            case NSClosePathBezierPathElement: {
            } break;
                
            default:
                break;
        }
    }
    
    // draw handle for all points
    for (NSUInteger elementIndex = 0; elementIndex < numberOfElements; elementIndex++) {
        NSBezierPathElement element = [self.path elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                [[NSColor whiteColor] set];
                [self drawHandleAtPoint:points[0]];
                
                previousPoint = points[0];
            } break;
                
            case NSLineToBezierPathElement: {
                [[NSColor whiteColor] set];
                [self drawHandleAtPoint:points[0]];
                
                previousPoint = points[0];
            } break;
                
            case NSCurveToBezierPathElement: {
                [[NSColor redColor] set];
                [self drawHandleAtPoint:points[0]];
                [[NSColor redColor] set];
                [self drawHandleAtPoint:points[1]];
                [[NSColor whiteColor] set];
                [self drawHandleAtPoint:points[2]];
                
                previousPoint = points[2];
            } break;
                
            case NSClosePathBezierPathElement: {
            } break;
                
            default:
                break;
        }
    }
}

- (void)drawHandleAtPoint:(NSPoint)point {
    NSRect rect = NSInsetRect(NSMakeRect(point.x, point.y, 0, 0), -3, -3);
	NSRectFill(rect);
    [[NSColor blackColor] set];
    NSFrameRect(rect);
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context {
    if (context != &SplineDivisionViewObservationContext) {
        [super observeValueForKeyPath:keyPath 
                             ofObject:object 
                               change:change 
                              context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"path"]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"pathStart"]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"pathEnd"]) {
        [self setNeedsDisplay:YES];
    }
}

@end
