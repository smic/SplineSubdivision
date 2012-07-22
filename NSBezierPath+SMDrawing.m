//
//  NSBezierPath+SMDrawing.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 21.07.12.
//
//

#import "NSBezierPath+SMDrawing.h"

@implementation NSBezierPath (SMDrawing)

- (void)drawTangents {
    
    CGFloat dashPattern[2];
	dashPattern[0] = 5.0f;
	dashPattern[1] = 2.0f;
    
    // draw tangents to the control points
    NSPoint points[3];
    NSPoint previousPoint;
    NSUInteger numberOfElements = [self elementCount];
    for (NSUInteger elementIndex = 0; elementIndex < numberOfElements; elementIndex++) {
        NSBezierPathElement element = [self elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
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
}

- (void)drawHandles {
    
    // draw handle for all points
    NSPoint points[3];
    NSPoint previousPoint;
    NSUInteger numberOfElements = [self elementCount];
    for (NSUInteger elementIndex = 0; elementIndex < numberOfElements; elementIndex++) {
        NSBezierPathElement element = [self elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
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
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    point = CGContextConvertPointToDeviceSpace(context, point);
    
    point.x = roundf(point.x + 0.5f) - 0.5f;
    point.y = roundf(point.y + 0.5f) - 0.5f;
    NSRect rect = NSMakeRect(point.x - 3.5f, point.y - 3.5f, 7.0f, 7.0f);
    
    rect = CGContextConvertRectToUserSpace(context, rect);
    
	NSRectFill(rect);
    
    [[NSColor blackColor] set];
    NSFrameRect(rect);
}

@end
