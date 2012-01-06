//
//  NSBezierPath+Subdivision.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 05.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "NSBezierPath+Subdivision.h"


@implementation NSBezierPath (Subdivision)

NSPoint midPoint(NSPoint p1, NSPoint p2);
void SubdivisionAddCurveDivision(NSBezierPath *path, NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat *start, CGFloat *end, BOOL *started);
CGFloat SubdivisionCalcCurveLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4);


- (NSBezierPath *)subpathFromLength:(CGFloat)start toLength:(CGFloat)end {
    if (start >= end) {
		return [NSBezierPath bezierPath];
	}
    
    NSPoint points[3];
    BOOL started = NO;
    NSPoint previousPoint;
    NSBezierPath *subpath = [NSBezierPath bezierPath];
    for (NSUInteger elementIndex = 0; elementIndex < [self elementCount]; elementIndex++) {
        
        if (end < 0) {
            break;
        }
        
        NSBezierPathElement element = [self elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
//        NSLog(@"Element: %i", element);
        switch (element) {
            case NSMoveToBezierPathElement: {
                started = NO;
                previousPoint = points[0];
            } break;
                
            case NSLineToBezierPathElement: {
                NSPoint p1 = previousPoint;
                NSPoint p2 = points[0];
                
                CGFloat dx = p2.x - p1.x;
                CGFloat dy = p2.y - p1.y;

                CGFloat length = hypotf(dx, dy);
                
                if (start <= 0 || length <= end) {
                    CGFloat d1 = MAX(start, 0);
                    CGFloat d2 = MIN(length, end);
                    
                    p1.x = p1.x + dx * d1 / length;
                    p1.y = p1.y + dy * d1 / length;
                    p2.x = p2.x + dx * d2 / length;
                    p2.y = p2.y + dy * d2 / length;
                    
                    if (!(started)) {
                        started = YES;
                        [subpath moveToPoint:p1];
                    }
                    [subpath lineToPoint:p2];
                }

                start -= length;
                end -= length;
                previousPoint = points[0];
            } break;
                
            case NSCurveToBezierPathElement: {
                SubdivisionAddCurveDivision(subpath, previousPoint, points[0], points[1], points[2], &start, &end, &started);
                
                previousPoint = points[2];
            } break;
                
            case NSClosePathBezierPathElement: {
                started = NO;
            } break;
                
            default:
                break;
        }
    }
    return subpath;
}


NSPoint midPoint(NSPoint p1, NSPoint p2) {
	return NSMakePoint((p1.x + p2.x) / 2.0f, (p1.y + p2.y) / 2.0f);
}

// see http://www.antigrain.com/research/adaptive_bezier/index.html

CGFloat const length_tolerance = 0.001f;

void SubdivisionAddCurveDivision(NSBezierPath *path, NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat *start, CGFloat *end, BOOL *started) {    
	if ((*start) >= (*end) || (*end) <= 0) {
		return;
	}
    
    // cacluclate length of the spline
    CGFloat length = SubdivisionCalcCurveLength(p1, p2, p3, p4);
    
    // if the length smaller than the tolerance
    if (length <= length_tolerance) {
        *start -= length;
        *end -= length;
        return;
    }
    if ((*start) <= 0 && length < (*end)) {
        // Add complete spline because the spline is in between start and end
        if (!(*started)) {
            *started = YES;
            [path moveToPoint:p1];
        }
        [path curveToPoint:p4 controlPoint1:p2 controlPoint2:p3];
        
        *start -= length;
        *end -= length;
        return;
    }
    
    // Spline is before start
    if (*start >= length) {
        *start -= length;
        *end -= length;
        return;
    }

	
	// Calculate all the mid-points of the line segments
    NSPoint p12   = midPoint(p1, p2);
    NSPoint p23   = midPoint(p2, p3);
    NSPoint p34   = midPoint(p3, p4);
    NSPoint p123  = midPoint(p12, p23);
    NSPoint p234  = midPoint(p23, p34);
    NSPoint p1234 = midPoint(p123, p234);
	
    // add first part if possible
    SubdivisionAddCurveDivision(path, p1, p12, p123, p1234, start, end, started); 
	
	if ((*end) <= 0) {
		return;
	}
	
    // add second part if possible
    SubdivisionAddCurveDivision(path, p1234, p234, p34, p4, start, end, started); 
}


CGFloat const m_distance_tolerance = 0.5f;

CGFloat SubdivisionCalcCurveLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4) {
	
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
    return SubdivisionCalcCurveLength(p1, p12, p123, p1234) + 
           SubdivisionCalcCurveLength(p1234, p234, p34, p4);
}

@end
