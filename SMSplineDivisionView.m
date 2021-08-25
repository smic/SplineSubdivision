//
//  SMSplineDivisionView.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SMSplineDivisionView.h"
#import "NSBezierPath+SMSubdivision.h"
#import "NSBezierPath+SMDrawing.h"
#import "SMLineGeometry.h"
#import "SMSplineGeometry.h"


static void *SMObservationContext = &SMObservationContext;

typedef struct {
    NSUInteger elementIndex;
    NSUInteger pointIndex;
} PathPoint;

@implementation SMSplineDivisionView

#pragma mark - Initialization / Deallocation

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        // add tracking area to get mouse events
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:frame
                                                                    options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                                      owner:self userInfo:nil];
		[self addTrackingArea:trackingArea];
        
        // add observer for properties
        [self addObserver:self 
               forKeyPath:@"path" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:SMObservationContext];
        [self addObserver:self 
               forKeyPath:@"pathStart" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:SMObservationContext];
        [self addObserver:self
               forKeyPath:@"pathEnd" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:SMObservationContext];
        [self addObserver:self
               forKeyPath:@"probe"
                  options:(NSKeyValueObservingOptionNew)
                  context:SMObservationContext];
    }
    return self;
}

- (void)dealloc {
    // remove observer for properties
    [self removeObserver:self 
              forKeyPath:@"path" 
                 context:SMObservationContext];
    [self removeObserver:self 
              forKeyPath:@"pathStart" 
                 context:SMObservationContext];
    [self removeObserver:self
              forKeyPath:@"pathEnd" 
                 context:SMObservationContext];
    [self removeObserver:self
              forKeyPath:@"probe"
                 context:SMObservationContext];
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
    while ([event type]!=NSEventTypeLeftMouseUp) {
        event = [[self window] nextEventMatchingMask:(NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)];
		NSPoint currentPoint = [self convertPoint:[event locationInWindow] fromView:nil];
		currentPoint.x = fminf(fmaxf(currentPoint.x, bounds.origin.x), bounds.size.width);
		currentPoint.y = fminf(fmaxf(currentPoint.y, bounds.origin.y), bounds.size.height);
		
		CGFloat dx = currentPoint.x-point.x;
		CGFloat dy = currentPoint.y-point.y;
        
        if (dx == 0.0f && dy == 0.0f) {
            continue;
        }
        
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
        
        [self.delegate splineDivisionViewDidChangePath:self];
        
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

#pragma mark - Drawing

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
    
//    [self drawCurveSubdivisions:self.path];
	
    [self.path drawTangents];
    
    // draw probe
    CGPoint probePoint = [self.path pointAtLength:self.probe];
    [self drawProbeAtPoint:probePoint];
    
    [self.path drawHandles];
}

- (void)drawProbeAtPoint:(NSPoint)point {
    
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(point.x - 4.0f,
                                                                           point.y - 4.0f,
                                                                           8.0f, 8.0)];
    [[NSColor redColor] set];
    [path fill];
//    [[NSColor colorWithDeviceRed:0.2f green:0.2f blue:0.6f alpha:1.0f] set];
//    [path stroke];
}

static NSUInteger subdivisionIndex;

- (void)drawCurveSubdivisions:(NSBezierPath *)path {
    subdivisionIndex = 0;
    
    NSPoint points[3];
    BOOL started = NO;
    NSPoint previousPoint;
    for (NSUInteger elementIndex = 0; elementIndex < [path elementCount]; elementIndex++) {
        
        NSBezierPathElement element = [path elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                started = NO;
                previousPoint = points[0];
            } break;
                
            case NSLineToBezierPathElement: {
                NSPoint p1 = previousPoint;
                NSPoint p2 = points[0];
                
                [self drawLinearSubdivisionWithP1:p1 p2:p2];
                
                previousPoint = p2;
            } break;
                
            case NSCurveToBezierPathElement: {
                CGPoint p1 = previousPoint;
                CGPoint p2 = points[0];
                CGPoint p3 = points[1];
                CGPoint p4 = points[2];
                
                [self drawCurveSubdivisionsWithP1:p1 p2:p2 p3:p3 p4:p4];
                
                previousPoint = p4;
            } break;
                
            case NSClosePathBezierPathElement: {
                started = NO;
            } break;
                
            default:
                break;
        }
    }
}

- (void)drawCurveSubdivisionsWithP1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 {
    if (SMSplineIsLinear(p1, p2, p3, p4)) {
        [self drawLinearSubdivisionWithP1:p1 p2:p4];
        return;
    }
    
    // Calculate all the mid-points of the line segments
    NSPoint p12   = SMLineGetMidPoint(p1, p2);
    NSPoint p23   = SMLineGetMidPoint(p2, p3);
    NSPoint p34   = SMLineGetMidPoint(p3, p4);
    NSPoint p123  = SMLineGetMidPoint(p12, p23);
    NSPoint p234  = SMLineGetMidPoint(p23, p34);
    NSPoint p1234 = SMLineGetMidPoint(p123, p234);
    
    // Continue subdivision
    [self drawCurveSubdivisionsWithP1:p1 p2:p12 p3:p123 p4:p1234];
    [self drawCurveSubdivisionsWithP1:p1234 p2:p234 p3:p34 p4:p4];
}

- (void)drawLinearSubdivisionWithP1:(CGPoint)p1 p2:(CGPoint)p2 {
    if (subdivisionIndex % 2 == 0) {
        [[NSColor redColor] set];
    } else {
        [[NSColor greenColor] set];
    }
    
    [NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
    
    subdivisionIndex++;
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    if (context != SMObservationContext) {
        [super observeValueForKeyPath:keyPath 
                             ofObject:object 
                               change:change 
                              context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"path"]) {
        [self.delegate splineDivisionViewDidChangePath:self];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"pathStart"]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"pathEnd"]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"probe"]) {
        [self setNeedsDisplay:YES];
    }
}

@end
