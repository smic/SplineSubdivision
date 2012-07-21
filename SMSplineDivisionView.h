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

@property (nonatomic, strong) NSBezierPath *path;
@property (nonatomic) CGFloat pathStart;
@property (nonatomic) CGFloat pathEnd;
@property (nonatomic) CGFloat probe;
@property (nonatomic, weak) id<SMSplineDivisionViewDelegate> delegate;

@end

@protocol SMSplineDivisionViewDelegate <NSObject>

- (void)splineDivisionViewDidChangePath:(SMSplineDivisionView *)view;

@end
