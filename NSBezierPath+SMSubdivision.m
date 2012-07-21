//
//  NSBezierPath+Subdivision.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 05.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "NSBezierPath+SMSubdivision.h"
#import "SMLineGeometry.h"
#import "SMSplineGeometry.h"


@implementation NSBezierPath (SMSubdivision)

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
            return subpath;
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
                    double u1 = MAX(start, 0) / lineLength;
                    double u2 = MIN(lineLength, end) / lineLength;
                    
                    CGPoint startPoint = SMLineGetPointAtParameter(p1, p2, u1);
                    CGPoint endPoint = SMLineGetPointAtParameter(p1, p2, u2);
                    
                    if (!started) {
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
                
                CGFloat curveLength = SMSplineGetTotalLength(p1, p2, p3, p4);
                
                // check if the reached the start
                if (start < curveLength) {
                    
                    double u1 = SMSplineParameterForLength(p1, p2, p3, p4, start);
                    double u2 = SMSplineParameterForLength(p1, p2, p3, p4, end);
                    
                    CGPoint sdp1 = p1;
                    CGPoint sdp2 = p2;
                    CGPoint sdp3 = p3;
                    CGPoint sdp4 = p4;
                    
                    // check to remove a part at the beginning of the current curve element
                    if (u1 > 0.0) {
                        SMSplineGetSubdivisionAtParameter(sdp1, sdp2, sdp3, sdp4, u1, NO,
                                                          &sdp1, &sdp2, &sdp3, &sdp4);
                        [subpath moveToPoint:sdp1];
                        started = YES;
                    }
                    if (!started) {
                        [subpath moveToPoint:sdp1];
                        started = YES;
                    }
                    
                    // check to remove a part at the end of the current curve element
                    if (u2 < 1.0) {
                        SMSplineGetSubdivisionAtParameter(sdp1, sdp2, sdp3, sdp4, (u2 - u1) / (1 - u1), YES,
                                                          &sdp1, &sdp2, &sdp3, &sdp4);
                    }
                    
                    [subpath curveToPoint:sdp4 controlPoint1:sdp2 controlPoint2:sdp3];                    
                }
                
                start -= curveLength;
                end -= curveLength;
                previousPoint = p4;
            } break;
                
            case NSClosePathBezierPathElement: {
                [subpath closePath];
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

- (CGFloat)length {
    CGFloat length = 0;
    
    NSPoint points[3];
    NSPoint previousPoint = NSZeroPoint;
    for (NSUInteger elementIndex = 0; elementIndex < [self elementCount]; elementIndex++) {
        
        NSBezierPathElement element = [self elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                NSPoint p = points[0];
                previousPoint = p;
            } break;
                
            case NSLineToBezierPathElement: {
                NSPoint p1 = previousPoint;
                NSPoint p2 = points[0];
                
                CGFloat lineLength = SMLineGetLength(p1, p2);
                length += lineLength;
                
                previousPoint = p2;
            } break;
                
            case NSCurveToBezierPathElement: {
                CGPoint p1 = previousPoint;
                CGPoint p2 = points[0];
                CGPoint p3 = points[1];
                CGPoint p4 = points[2];
                
                CGFloat curveLength = SMSplineGetTotalLength(p1, p2, p3, p4);
                length += curveLength;
                
                previousPoint = points[2];
            } break;
                
            case NSClosePathBezierPathElement: {
            } break;
                
            default:
                break;
        }
    }
    return length;
}

@end
