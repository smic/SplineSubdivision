//
//  NSBezierPath+Subdivision.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 05.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "NSBezierPath+Subdivision.h"
#import "SMGeometry.h"


@implementation NSBezierPath (Subdivision)

void SubdivisionAddCurveDivision(NSBezierPath *path, NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat *start, CGFloat *end, BOOL *started);

- (NSBezierPath *)subpathFromLength:(CGFloat)start toLength:(CGFloat)end {
    if (start >= end) {
		return [NSBezierPath bezierPath];
	}
    
    NSPoint points[3];
    BOOL started = NO;
    NSPoint previousPoint;
    NSBezierPath *subpath = [NSBezierPath bezierPath];
    for (NSUInteger elementIndex = 0; elementIndex < [self elementCount]; elementIndex++) {
        // if we already reached the end
        if (end < 0) {
            break;
        }
        
        NSBezierPathElement element = [self elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                started = NO;
                previousPoint = points[0];
            } break;
                
            case NSLineToBezierPathElement: {
                NSPoint p1 = previousPoint;
                NSPoint p2 = points[0];
                
                CGFloat lineLength = SMLineGetLength(p1, p2);
                
                // check if the reached the start
                if (start < lineLength) {
                    CGFloat d1 = MAX(start, 0);
                    CGFloat d2 = MIN(lineLength, end);
                    
                    CGPoint startPoint = SMLineGetPointAtParameter(p1, p2, d1 / lineLength);
                    CGPoint endPoint = SMLineGetPointAtParameter(p1, p2, d2 / lineLength);
                    
                    if (!(started)) {
                        started = YES;
                        [subpath moveToPoint:startPoint];
                    }
                    [subpath lineToPoint:endPoint];
                }

                start -= lineLength;
                end -= lineLength;
                previousPoint = p2;
            } break;
                
            case NSCurveToBezierPathElement: {
                CGPoint p1 = previousPoint;
                CGPoint p2 = points[0];
                CGPoint p3 = points[1];
                CGPoint p4 = points[2];
                
                SubdivisionAddCurveDivision(subpath, p1, p2, p3, p4, &start, &end, &started);
                
                previousPoint = p4;
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

- (CGPoint)pointAtLength:(CGFloat)length {
    
    NSPoint points[3];
    NSPoint previousPoint = NSZeroPoint;
    for (NSUInteger elementIndex = 0; elementIndex < [self elementCount]; elementIndex++) {
        
        NSBezierPathElement element = [self elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                NSPoint p = points[0];
                if (length <= 0) {
                    return p;
                }
                previousPoint = p;
            } break;
                
            case NSLineToBezierPathElement: {
                NSPoint p1 = previousPoint;
                NSPoint p2 = points[0];
                
                CGFloat lineLength = SMLineGetLength(p1, p2);
                
                if (length <= 0) {
                    return p1;
                } else if (length <= lineLength) {
                    return SMLineGetPointAtParameter(p1, p2, length / lineLength);
                } else {
                    length -= lineLength;
                }

                previousPoint = p2;
            } break;
                
            case NSCurveToBezierPathElement: {
                CGPoint p1 = previousPoint;
                CGPoint p2 = points[0];
                CGPoint p3 = points[1];
                CGPoint p4 = points[2];
                
                CGFloat curveLength = SMSplineGetTotalLength(p1, p2, p3, p4);
                
                if (length <= 0) {
                    return p1;
                } else if (length <= curveLength) {
                    double u = SMSplineParameterForLength(p1, p2, p3, p4, length);
                    
                    return SMSplineGetPointAtParameter(p1, p2, p3, p4, u);
                } else {
                    length -= curveLength;
                }
                
                previousPoint = points[2];
            } break;
                
            case NSClosePathBezierPathElement: {
            } break;
                
            default:
                break;
        }
    }
    return previousPoint;
}



CGFloat const length_tolerance = 0.001f;

void SubdivisionAddCurveDivision(NSBezierPath *path,
                                 NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4,
                                 CGFloat *start, CGFloat *end, BOOL *started) {
	if ((*start) >= (*end) || (*end) <= 0) {
		return;
	}
    
    // cacluclate length of the spline
    CGFloat length = SMSplineGetTotalLength(p1, p2, p3, p4);
    
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
    NSPoint p12   = MidPoint(p1, p2);
    NSPoint p23   = MidPoint(p2, p3);
    NSPoint p34   = MidPoint(p3, p4);
    NSPoint p123  = MidPoint(p12, p23);
    NSPoint p234  = MidPoint(p23, p34);
    NSPoint p1234 = MidPoint(p123, p234);
	
    // add first part if possible
    SubdivisionAddCurveDivision(path, p1, p12, p123, p1234, start, end, started); 
	
	if ((*end) <= 0) {
		return;
	}
	
    // add second part if possible
    SubdivisionAddCurveDivision(path, p1234, p234, p34, p4, start, end, started); 
}

@end
