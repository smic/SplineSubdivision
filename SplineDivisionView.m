//
//  SplineDivisionView.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright 2010 Beilstein Institut. All rights reserved.
//

#import "SplineDivisionView.h"


@implementation SplineDivisionView

@synthesize points, curveStart, curveEnd;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib {
	NSMutableArray *newPoints = [NSMutableArray array];
	[newPoints addObject:[NSValue valueWithPoint:NSMakePoint(50, 200)]];
	[newPoints addObject:[NSValue valueWithPoint:NSMakePoint(90, 300)]];
	[newPoints addObject:[NSValue valueWithPoint:NSMakePoint(160, 300)]];
	[newPoints addObject:[NSValue valueWithPoint:NSMakePoint(200, 200)]];
	[newPoints addObject:[NSValue valueWithPoint:NSMakePoint(240, 100)]];
	[newPoints addObject:[NSValue valueWithPoint:NSMakePoint(310, 100)]];
	[newPoints addObject:[NSValue valueWithPoint:NSMakePoint(350, 200)]];
	self.points = newPoints;
	
	self.curveStart = 50.0f;
	self.curveEnd = 150.0f;
}

- (IBAction)changeCurveStart:(id)sender {
	self.curveStart = [sender floatValue];
	//self.curveEnd = MAX(self.curveStart + 1.0f, self.curveEnd);
	
	[self setNeedsDisplay:YES];
}

- (IBAction)changeCurveEnd:(id)sender {
	self.curveEnd = [sender floatValue];
	//self.curveEnd = MAX(self.curveStart + 1.0f, self.curveEnd);
	
	[self setNeedsDisplay:YES];
}


- (void)mouseDown:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSInteger selectedPointIndex = NSNotFound;
	NSInteger count = [self.points count];
	for (NSInteger index = 0; index < count; index++) {
		NSPoint selectedPoint = [[self.points objectAtIndex:index] pointValue];
		NSRect handleRect = NSInsetRect(NSMakeRect(selectedPoint.x, selectedPoint.y, 0, 0), -5, -5);
		if (NSPointInRect(point, handleRect)) {
			selectedPointIndex = index;
			break;
		}
	}
	if (selectedPointIndex == NSNotFound) return;
	
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
		self.needsDisplay = YES;
	}
}

- (void)drawRect:(NSRect)rect {
		NSInteger count = [self.points count];
		NSPoint p[count];
		for (NSInteger index = 0; index < count; index++) {
			p[index] = [[self.points objectAtIndex:index] pointValue];
		}
		
		/*NSBezierPath *path = [NSBezierPath bezierPath];
		[path moveToPoint:p[0]];
		[path curveToPoint:p[3] controlPoint1:p[1] controlPoint2:p[2]];
		[path curveToPoint:p[6] controlPoint1:p[4] controlPoint2:p[5]];
		
		[path stroke];
		
		*/
	
	// NSLog(@"start=%f, end=%f, length=%f", self.curveStart, self.curveEnd, calcCurveLength(p[0], p[1], p[2], p[3]));
	
	//drawSpline(p[0], p[1], p[2], p[3], 4);
	//drawSpline(p[3], p[4], p[5], p[6], 4);
	//drawSplineWithLength(p[0], p[1], p[2], p[3], self.splineLength);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	addCurvesDivision(path, p, count, self.curveStart, self.curveEnd);
	
	[[NSColor colorWithDeviceRed:22.0f/255.0f green:32.0f/55.0f blue:27.0f/255.0f alpha:1.0f] set];
	path.lineWidth = 20.0f;
	[path stroke];
	
	[[NSColor colorWithDeviceRed:30.0f/255.0f green:60.0f/55.0f blue:75.0f/255.0f alpha:0.8f] set];
	path.lineWidth = 0.0f;
	[path stroke];
	
	
	
	
	CGFloat dashPattern[2];
	dashPattern[0] = 5.0f; //segment painted with stroke color
	dashPattern[1] = 2.0f; //segment not painted with a color
	
	for (NSInteger index = 0; index < count - 1; index += 3) {
		
		[[NSColor redColor] set];
		NSBezierPath *path2 = [NSBezierPath bezierPath];
		[path2 setLineDash:dashPattern count: 2 phase: 0.0];
		[path2 moveToPoint:p[index]];
		[path2 lineToPoint:p[index + 1]];
		[path2 moveToPoint:p[index + 2]];
		[path2 lineToPoint:p[index + 3]];
		[path2 stroke];
		
		[[NSColor blackColor] set];
		drawHandle(p[index]);
		drawHandle(p[index + 3]);
		
		[[NSColor redColor] set];
		drawHandle(p[index + 1]);
		drawHandle(p[index + 2]);
		
	}
}

- (BOOL)isFlipped {
	return YES;
}

- (void)dealloc {
	self.points = nil;
		 
	[super dealloc];
}

@end

NSPoint midPoint(NSPoint p1, NSPoint p2) {
	return NSMakePoint((p1.x + p2.x) / 2.0f, (p1.y + p2.y) / 2.0f);
}

/*void drawSpline(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, NSInteger deep) {
	
	// Calculate all the mid-points of the line segments
    NSPoint p12   = midPoint(p1, p2);
    NSPoint p23   = midPoint(p2, p3);
    NSPoint p34   = midPoint(p3, p4);
    NSPoint p123  = midPoint(p12, p23);
    NSPoint p234  = midPoint(p23, p34);
    NSPoint p1234 = midPoint(p123, p234);
	
    if(deep <= 0) {
		[NSBezierPath strokeLineFromPoint:p1 toPoint:p4];
    } else {
        drawSpline(p1, p12, p123, p1234, deep - 1); 
        drawSpline(p1234, p234, p34, p4, deep - 1);
	}
	
//	drawHandle(p1);
//	drawHandle(p2);
//	drawHandle(p3);
//	drawHandle(p4);
}*/

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
	
	CGFloat dx = p4.x - p1.x;
	CGFloat dy = p4.y - p1.y;
	
	CGFloat d2 = fabs(((p2.x - p4.x) * dy - (p2.y - p4.y) * dx));
	CGFloat d3 = fabs(((p3.x - p4.x) * dy - (p3.y - p4.y) * dx));
	
	if((d2 + d3)*(d2 + d3) <= m_distance_tolerance * (dx*dx + dy*dy)) {
		if (dx == 0.0f) {
			return dy;
		} else if (dy == 0.0f) {
			return dx;
		}
		
		return sqrtf(dx * dx + dy * dy);
    } else {
        return calcCurveLength(p1, p12, p123, p1234) + 
			calcCurveLength(p1234, p234, p34, p4);
	}
}

void drawHandle(NSPoint p) {
	NSRectFill(NSInsetRect(NSMakeRect(p.x, p.y, 0, 0), -3, -3));
}
