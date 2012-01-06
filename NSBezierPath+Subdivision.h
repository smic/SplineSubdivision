//
//  NSBezierPath+Subdivision.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 05.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSBezierPath (Subdivision)

- (NSBezierPath *)subpathFromLength:(CGFloat)startLength toLength:(CGFloat)endLength;

@end
