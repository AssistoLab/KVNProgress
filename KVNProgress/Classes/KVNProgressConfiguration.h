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
@property (nonatomic, strong) UIColor *backgroundFillColor;
/** Tint color of the background view. Used to tint blurred background only when backgroundType is KVNProgressBackgroundTypeBlurred. */
@property (nonatomic, strong) UIColor *backgroundTintColor;
/** Tells which background type the HUD will use. */
@property (nonatomic, assign) KVNProgressBackgroundType backgroundType;
/** Tells wether the HUD is full screen or not. */
@property (nonatomic, getter = isFullScreen) BOOL fullScreen;
/**
 * Tells wether the stop squared button will be shown in the middle of a progress circle or not.
 * @remark If no <code>tapBlock</code> is configured, <code>showStop</code> will have no effect.
 * <code>tapBlock</code> is executed when the stop button is pressed.
 * @see <code>tapBlock</code>
 */
@property (nonatomic, getter = doesShowStop) BOOL showStop;

#pragma mark - Circle

/** Color of the circle stroke. */
@property (nonatomic, strong) UIColor *circleStrokeForegroundColor;
/** Background color of the circle stroke. Used only when view is showing with a progress circle. */
@property (nonatomic, strong) UIColor *circleStrokeBackgroundColor;
/** background color of the circle. */
@property (nonatomic, strong) UIColor *circleFillBackgroundColor;
/** Size of the circle. */
@property (nonatomic, assign) CGFloat circleSize;
/** Relative height of the stop squared button. Between 0 and 1. For example: 0.3 will display a square that has 30% de size of the circle. */
@property (nonatomic, assign) CGFloat stopRelativeHeight;
/** Width of the circle stroke line. */
@property (nonatomic, assign) CGFloat lineWidth;

#pragma mark - Status

/** Color of the status label. */
@property (nonatomic, strong) UIColor *statusColor;
/** Font of the status label. */
@property (nonatomic, strong) UIFont *statusFont;

#pragma mark - Success/Error

/** color of the circle and checkmark when showing success. */
@property (nonatomic, strong) UIColor *successColor;
/** color of the circle and checkmark when showing error. */
@property (nonatomic, strong) UIColor *errorColor;
/** color of the square when showing stop button. */
@property (nonatomic, strong) UIColor *stopColor;

#pragma mark - Display times

/** The minimum time (in seconds) the hud will be displayed. No matter if <code>dismiss</code> is called. */
@property (nonatomic, assign) NSTimeInterval minimumDisplayTime;
/** The minimum time (in seconds) the success will be displayed. */
@property (nonatomic, assign) NSTimeInterval minimumSuccessDisplayTime;
/** The minimum time (in seconds) the error will be displayed. */
@property (nonatomic, assign) NSTimeInterval minimumErrorDisplayTime;

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
/** Enable the use of feedback usign UINotificationFeedbackGenerator. Default to false. */
@property (nonatomic, getter = isUIFeedbackEnabled) BOOL enableUIFeedback API_AVAILABLE(ios(10));

#pragma mark - Helper

/** Create an instance of <code>KVNProgressConfiguration</code> with default configuration. */
+ (instancetype)defaultConfiguration;

@end
