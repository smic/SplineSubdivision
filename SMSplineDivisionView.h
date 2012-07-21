//
//  SMSplineDivisionView.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol SMSplineDivisionViewDelegate;

@interface SMSplineDivisionView : NSView

@property (nonatomic, retain) NSBezierPath *path;
@property (nonatomic, assign) CGFloat pathStart;
@property (nonatomic, assign) CGFloat pathEnd;
@property (nonatomic, assign) CGFloat probe;
@property (nonatomic, assign) id<SMSplineDivisionViewDelegate> delegate;

@end

@protocol SMSplineDivisionViewDelegate <NSObject>

- (void)splineDivisionViewDidChangePath:(SMSplineDivisionView *)view;

@end
