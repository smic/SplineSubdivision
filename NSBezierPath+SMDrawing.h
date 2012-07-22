//
//  NSBezierPath+SMDrawing.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 21.07.12.
//
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (SMDrawing)

- (void)drawTangents;
- (void)drawHandles;

@end
