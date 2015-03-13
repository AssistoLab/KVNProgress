//
//  KVNProgressConfiguration.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 20/12/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KVNProgress;

typedef void (^KVNTapBlock)(KVNProgress *);

typedef NS_ENUM(NSUInteger, KVNProgressBackgroundType) {
	/** Don't allow user interactions and show a blurred background. Default value. */
	KVNProgressBackgroundTypeBlurred,
	/** Don't allow user interactions and show a solid color background. */
	KVNProgressBackgroundTypeSolid,
};

/** Configuration of UI for a <code>KVNProgress</code> instance. */
@interface KVNProgressConfiguration : NSObject <NSCopying>

#pragma mark - Background

/** Color of the background view. Is not used when backgroundType is KVNProgressBackgroundTypeBlurred. */
@property (nonatomic) UIColor *backgroundFillColor;
/** Tint color of the background view. Used to tint blurred background only when backgroundType is KVNProgressBackgroundTypeBlurred. */
@property (nonatomic) UIColor *backgroundTintColor;
/** Tells which background type the HUD will use. */
@property (nonatomic) KVNProgressBackgroundType backgroundType;
/** Tells wether the HUD is full screen or not. */
@property (nonatomic, getter = isFullScreen) BOOL fullScreen;

#pragma mark - Circle

/** Color of the circle stroke. */
@property (nonatomic) UIColor *circleStrokeForegroundColor;
/** Background color of the circle stroke. Used only when view is showing with a progress circle. */
@property (nonatomic) UIColor *circleStrokeBackgroundColor;
/** background color of the circle. */
@property (nonatomic) UIColor *circleFillBackgroundColor;
/** Size of the circle. */
@property (nonatomic) CGFloat circleSize;
/** Width of the circle stroke line. */
@property (nonatomic) CGFloat lineWidth;

#pragma mark - Status

/** Color of the status label. */
@property (nonatomic) UIColor *statusColor;
/** Font of the status label. */
@property (nonatomic) UIFont *statusFont;

#pragma mark - Success/Error

/** color of the circle and checkmark when showing success. */
@property (nonatomic) UIColor *successColor;
/** color of the circle and checkmark when showing error. */
@property (nonatomic) UIColor *errorColor;

#pragma mark - Display times

/** The minimum time (in seconds) the hud will be displayed. No matter if <code>dismiss</code> is called. */
@property (nonatomic) NSTimeInterval minimumDisplayTime;
/** The minimum time (in seconds) the success will be displayed. */
@property (nonatomic) NSTimeInterval minimumSuccessDisplayTime;
/** The minimum time (in seconds) the error will be displayed. */
@property (nonatomic) NSTimeInterval minimumErrorDisplayTime;

#pragma mark - Interaction

/**
 * The block called when the HUD is tapped.
 * Use <code>nil</code> for no tap interaction with the HUD.
 * Works only when <code>allowUserInteraction</code> is set to <code>NO</code>.
 */
@property (nonatomic, copy) KVNTapBlock tapBlock;
/** 
 * Enable user interaction with views behind the HUD. Does not work in fullscreen mode. 
 * Is not compatible with the <code>tapBlock</code> property.
 * @see tapBlock
 */
@property (nonatomic, getter = doesAllowUserInteraction) BOOL allowUserInteraction;

#pragma mark - Helper

/** Create an instance of <code>KVNProgressConfiguration</code> with default configuration. */
+ (instancetype)defaultConfiguration;

@end
