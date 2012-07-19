//
//  NSBezierPath+Subdivision.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 05.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "NSBezierPath+Subdivision.h"


@implementation NSBezierPath (Subdivision)

NSPoint MidPoint(NSPoint p1, NSPoint p2);
void SubdivisionAddCurveDivision(NSBezierPath *path, NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat *start, CGFloat *end, BOOL *started);
CGFloat SMSplineGetTotalLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4);
double SMSplineParameterForLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat length);
CGPoint SMSplineGetPointAtParameter(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, double u);
CGFloat SMSplineTerm1(CGFloat u);
CGFloat SMSplineTerm2(CGFloat u);
CGFloat SMSplineTerm3(CGFloat u);
CGFloat SMSplineTerm4(CGFloat u);

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
                
                CGFloat dx = p2.x - p1.x;
                CGFloat dy = p2.y - p1.y;

                CGFloat length = hypotf(dx, dy);

                // check if the reached the start
                if (start < length) {
                    CGFloat d1 = MAX(start, 0);
                    CGFloat d2 = MIN(length, end);
                    
                    // Attention: p1 will be modified
                    p2.x = p1.x + dx * d2 / length;
                    p2.y = p1.y + dy * d2 / length;
                    p1.x = p1.x + dx * d1 / length;
                    p1.y = p1.y + dy * d1 / length;
                    
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
                
                CGFloat dx = p2.x - p1.x;
                CGFloat dy = p2.y - p1.y;
                
                CGFloat lineLength = hypotf(dx, dy);
                
                if (length <= 0) {
                    return p1;
                } else if (length <= lineLength) {
                    CGPoint point;
                    point.x = p1.x + dx * length / lineLength;
                    point.y = p1.y + dy * length / lineLength;
                    return point;
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
                    
                    CGPoint point = SMSplineGetPointAtParameter(p1, p2, p3, p4, u);
                    return point;
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


NSPoint MidPoint(NSPoint p1, NSPoint p2) {
	return NSMakePoint((p1.x + p2.x) / 2.0f,
                       (p1.y + p2.y) / 2.0f);
}

// see http://www.antigrain.com/research/adaptive_bezier/index.html

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


CGFloat const m_distance_tolerance = 0.5f;

CGFloat SMSplineGetTotalLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4) {
	
	// Calculate all the mid-points of the line segments
    NSPoint p12   = MidPoint(p1, p2);
    NSPoint p23   = MidPoint(p2, p3);
    NSPoint p34   = MidPoint(p3, p4);
    NSPoint p123  = MidPoint(p12, p23);
    NSPoint p234  = MidPoint(p23, p34);
    NSPoint p1234 = MidPoint(p123, p234);
	
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
    return SMSplineGetTotalLength(p1, p12, p123, p1234) + 
           SMSplineGetTotalLength(p1234, p234, p34, p4);
}

double SMSplineParameterForLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat length) {
    if (length <= 0) {
        return 0.0;
    }
    CGFloat totalLength = SMSplineGetTotalLength(p1, p2, p3, p4);
    if (totalLength < 0.0001f) {
        return 0.0f;
    }
    if (length >= totalLength) {
        return 1.0;
    }
    
    NSPoint p12   = MidPoint(p1, p2);
    NSPoint p23   = MidPoint(p2, p3);
    NSPoint p34   = MidPoint(p3, p4);
    NSPoint p123  = MidPoint(p12, p23);
    NSPoint p234  = MidPoint(p23, p34);
    NSPoint p1234 = MidPoint(p123, p234);

    CGFloat halfLength = SMSplineGetTotalLength(p1, p12, p123, p1234);
    if (halfLength == length) {
        return 0.5;
    } else if (length < halfLength) {
        return SMSplineParameterForLength(p1, p12, p123, p1234, length) * 0.5;
    } else {
        return SMSplineParameterForLength(p1234, p234, p34, p4, length - halfLength) * 0.5 + 0.5;
    }
}

CGPoint SMSplineGetPointAtParameter(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, double u) {
    if (u == 0.0) {
        return p1;
    }
    if (u == 1.0) {
        return p4;
    }
    CGFloat b0 = SMSplineTerm1(u);
    CGFloat b1 = SMSplineTerm2(u);
    CGFloat b2 = SMSplineTerm3(u);
    CGFloat b3 = SMSplineTerm4(u);
    
    CGPoint point;
    point.x = p1.x * b0 + p2.x * b1 + p3.x * b2 + p4.x * b3;
    point.y = p1.y * b0 + p2.y * b1 + p3.y * b2 + p4.y * b3;
    return point;
}

// Bezier multipliers
CGFloat SMSplineTerm1(CGFloat u) {
    CGFloat tmp = 1.0 - u;
    return (tmp * tmp * tmp);
}

CGFloat SMSplineTerm2(CGFloat u) {
    CGFloat tmp = 1.0 - u;
    return (3 * u * (tmp * tmp));
}

CGFloat SMSplineTerm3(CGFloat u) {
    CGFloat tmp = 1.0 - u;
    return (3 * u * u * tmp);
}

CGFloat SMSplineTerm4(CGFloat u) {
    return (u * u * u);
}


@end
