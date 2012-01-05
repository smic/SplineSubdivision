//
//  SplineDivisionView.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SplineDivisionView.h"


static char SplineDivisionViewObservationContext;

NSPoint midPoint(NSPoint p1, NSPoint p2);

void addCurvesDivision(NSBezierPath *path, NSPoint p[], NSInteger count, CGFloat start, CGFloat end);
BOOL addCurveDivision(NSBezierPath *path, NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat start, CGFloat end, BOOL started);
CGFloat calcCurveLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4);

void drawHandle(NSPoint p);


@implementation SplineDivisionView

@synthesize points = _points;
@synthesize curveStart = _curveStart;
@synthesize curveEnd = _curveEnd;

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
               forKeyPath:@"points" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&SplineDivisionViewObservationContext];
        [self addObserver:self 
               forKeyPath:@"curveStart" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&SplineDivisionViewObservationContext];
        [self addObserver:self 
               forKeyPath:@"curveEnd" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&SplineDivisionViewObservationContext];
    }
    return self;
}

- (void)dealloc {
    // remove observer for properties
    [self removeObserver:self 
              forKeyPath:@"points" 
                 context:&SplineDivisionViewObservationContext];
    [self removeObserver:self 
              forKeyPath:@"curveStart" 
                 context:&SplineDivisionViewObservationContext];
    [self removeObserver:self 
              forKeyPath:@"curveEnd" 
                 context:&SplineDivisionViewObservationContext];
    
	self.points = nil;
    
	[super dealloc];
}

#pragma mark - User interaction

- (NSUInteger)pointIndexUnderMouse:(NSPoint)point {
	NSInteger count = [self.points count];
	for (NSInteger index = 0; index < count; index++) {
		NSPoint selectedPoint = [[self.points objectAtIndex:index] pointValue];
		NSRect handleRect = NSInsetRect(NSMakeRect(selectedPoint.x, selectedPoint.y, 0, 0), -5, -5);
		if (NSPointInRect(point, handleRect)) {
			return index;
			break;
		}
	}
    return NSNotFound;
}

- (void)mouseDown:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSInteger selectedPointIndex = [self pointIndexUnderMouse:point];
	if (selectedPointIndex == NSNotFound) return;
	
    [[NSCursor closedHandCursor] set];
	NSRect bounds = self.bounds;
	while ([event type]!=NSLeftMouseUp) {
		event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		NSPoint currentPoint = [self convertPoint:[event locationInWindow] fromView:nil];
		currentPoint.x = fminf(fmaxf(currentPoint.x, bounds.origin.x), bounds.size.width);
		currentPoint.y = fminf(fmaxf(currentPoint.y, bounds.origin.y), bounds.size.height);
		
		CGFloat dx = currentPoint.x-point.x;
		CGFloat dy = currentPoint.y-point.y;
		
		NSMutableArray *newPoints = [self.points mutableCopy];
		
		// move also control point
		if (selectedPointIndex % 3 == 0) {
			// if a previous control point exists
			if (selectedPointIndex > 0) {
				NSPoint previousPoint = [[newPoints objectAtIndex:selectedPointIndex - 1] pointValue];
				previousPoint.x += dx;
				previousPoint.y += dy;
				[newPoints replaceObjectAtIndex:selectedPointIndex - 1 withObject:[NSValue valueWithPoint:previousPoint]];
			}
			
			// if a next control point exists
			if (selectedPointIndex < [newPoints count] - 1) {
				NSPoint nextPoint = [[newPoints objectAtIndex:selectedPointIndex + 1] pointValue];
				nextPoint.x += dx;
				nextPoint.y += dy;
				[newPoints replaceObjectAtIndex:selectedPointIndex +1 withObject:[NSValue valueWithPoint:nextPoint]];
			}
		}

		NSPoint selectedPoint = [[newPoints objectAtIndex:selectedPointIndex] pointValue];
		selectedPoint.x += dx;
		selectedPoint.y += dy;
		[newPoints replaceObjectAtIndex:selectedPointIndex withObject:[NSValue valueWithPoint:selectedPoint]];
		
		
		self.points = newPoints;
		[newPoints release];
		
		point = currentPoint;
	}
    
    [[NSCursor openHandCursor] set];
}

- (void)mouseMoved:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSInteger selectedPointIndex = [self pointIndexUnderMouse:point];
	if (selectedPointIndex == NSNotFound) {
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
    
    
    NSUInteger pointCount = [self.points count];
    if (pointCount == 0) {
        return;
    }
    
    NSPoint p[pointCount];
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        p[pointIndex] = [[self.points objectAtIndex:pointIndex] pointValue];
    }
    
	NSBezierPath *path = [NSBezierPath bezierPath];
	addCurvesDivision(path, p, pointCount, self.curveStart, self.curveEnd);
	
    // draw curve
	[[NSColor colorWithDeviceRed:22.0f/255.0f green:32.0f/55.0f blue:27.0f/255.0f alpha:1.0f] set];
	path.lineWidth = 20.0f;
	[path stroke];
	
	[[NSColor colorWithDeviceRed:30.0f/255.0f green:60.0f/55.0f blue:75.0f/255.0f alpha:0.8f] set];
	path.lineWidth = 0.0f;
	[path stroke];
	
	// draw helper lines and handles
	CGFloat dashPattern[2];
	dashPattern[0] = 5.0f;
	dashPattern[1] = 2.0f;
	
	for (NSUInteger pointIndex = 0; pointIndex < pointCount - 1; pointIndex += 3) {
		
		[[NSColor redColor] set];
		NSBezierPath *path2 = [NSBezierPath bezierPath];
		[path2 setLineDash:dashPattern count: 2 phase: 0.0];
		[path2 moveToPoint:p[pointIndex]];
		[path2 lineToPoint:p[pointIndex + 1]];
		[path2 moveToPoint:p[pointIndex + 2]];
		[path2 lineToPoint:p[pointIndex + 3]];
		[path2 stroke];
		
        [[NSColor whiteColor] set];
        drawHandle(p[pointIndex]);
        [[NSColor whiteColor] set];
		drawHandle(p[pointIndex + 3]);
		
		[[NSColor redColor] set];
		drawHandle(p[pointIndex + 1]);
        [[NSColor redColor] set];
		drawHandle(p[pointIndex + 2]);
		
	}
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
    
    if ([keyPath isEqualToString:@"points"]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"curveStart"]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"curveEnd"]) {
        [self setNeedsDisplay:YES];
    }
}

@end

NSPoint midPoint(NSPoint p1, NSPoint p2) {
	return NSMakePoint((p1.x + p2.x) / 2.0f, (p1.y + p2.y) / 2.0f);
}

void addCurvesDivision(NSBezierPath *path, NSPoint p[], NSInteger count, CGFloat start, CGFloat end) {
	if (start >= end) {
		return;
	}
	
	//[path moveToPoint:p[0]];
	BOOL started = NO;
	for (NSInteger index = 0; index < count - 1; index += 3) {
		CGFloat partLength = calcCurveLength(p[index], p[index + 1], p[index + 2], p[index + 3]);
		
		if (end < 0) {
			return;
		} else if (start <= 0 && partLength < end) {
			if (!started) {
				[path moveToPoint:p[index]];
				started = YES;
			}
			//strokeSpline(path, p[index], p[index + 1], p[index + 2], p[index + 3]);
			[path curveToPoint:p[index + 3] controlPoint1:p[index + 1] controlPoint2:p[index + 2]];
		} else {
			started = addCurveDivision(path, p[index], p[index + 1], p[index + 2], p[index + 3], start, end, started);
		}
		
		start -= partLength;
		end -= partLength;
	}
}

// see http://www.antigrain.com/research/adaptive_bezier/index.html

CGFloat const length_tolerance = 0.001f;

BOOL addCurveDivision(NSBezierPath *path, NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat start, CGFloat end, BOOL started) {
	if (start >= end || end <= 0) {
		return started;
	}
	
	// Calculate all the mid-points of the line segments
    NSPoint p12   = midPoint(p1, p2);
    NSPoint p23   = midPoint(p2, p3);
    NSPoint p34   = midPoint(p3, p4);
    NSPoint p123  = midPoint(p12, p23);
    NSPoint p234  = midPoint(p23, p34);
    NSPoint p1234 = midPoint(p123, p234);
	
	CGFloat length = calcCurveLength(p1, p12, p123, p1234);

	if (start - length_tolerance <= 0  && length <= end + length_tolerance) {
		if (!started) {
			[path moveToPoint:p1];
			started = YES;
		}
		[path curveToPoint:p1234 controlPoint1:p12 controlPoint2:p123];
		//strokeSpline(p1, p12, p123, p1234);
	} else if (start < length || end < length) {
		addCurveDivision(path, p1, p12, p123, p1234, start, end, started); 
	}
	
	start -= length;
	end -= length;
	
	if (end <= 0) {
		return started;
	}
	
	length = calcCurveLength(p1234, p234, p34, p4);
	
	if (start - length_tolerance <= 0  && length <= end + length_tolerance) {
		if (!started) {
			[path moveToPoint:p1234];
			started = YES;
		}
		//strokeSpline(p1234, p234, p34, p4);
		[path curveToPoint:p4 controlPoint1:p234 controlPoint2:p34];
	} else if (start < length || end < length) {
		addCurveDivision(path, p1234, p234, p34, p4, start, end, started); 
	}
	return started;
}


CGFloat const m_distance_tolerance = 0.5f;

CGFloat calcCurveLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4) {
	
	// Calculate all the mid-points of the line segments
    NSPoint p12   = midPoint(p1, p2);
    NSPoint p23   = midPoint(p2, p3);
    NSPoint p34   = midPoint(p3, p4);
    NSPoint p123  = midPoint(p12, p23);
    NSPoint p234  = midPoint(p23, p34);
    NSPoint p1234 = midPoint(p123, p234);
	
    // Try to approximate the full cubic curve by a single straight line
	CGFloat dx = p4.x - p1.x;
	CGFloat dy = p4.y - p1.y;
	
	CGFloat d2 = fabs(((p2.x - p4.x) * dy - (p2.y - p4.y) * dx));
	CGFloat d3 = fabs(((p3.x - p4.x) * dy - (p3.y - p4.y) * dx));
	
	if((d2 + d3) * (d2 + d3) <= m_distance_tolerance * (dx * dx + dy * dy)) {
		if (dx == 0.0f) {
			return dy;
		} else if (dy == 0.0f) {
			return dx;
		}
		
		return hypotf(dx, dy);
    }
    
    // Continue subdivision
    return calcCurveLength(p1, p12, p123, p1234) + 
           calcCurveLength(p1234, p234, p34, p4);
}

void drawHandle(NSPoint p) {
    NSRect rect = NSInsetRect(NSMakeRect(p.x, p.y, 0, 0), -3, -3);
	NSRectFill(rect);
    [[NSColor blackColor] set];
    NSFrameRect(rect);
}
