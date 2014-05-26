//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, KVNProgressBackgroundType) {
	/** Don't allow user interactions and show a solid color background */
    KVNProgressBackgroundTypeSolid,
	/** Don't allow user interactions and show a blurred background */
    KVNProgressBackgroundTypeBlurred
};

@interface KVNProgress : UIView

#pragma mark - Appearance

/** Color of the background view. Is not used when backgroundType is KVNProgressBackgroundTypeBlurred. */
@property (nonatomic) UIColor *backgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Tint color of the background view. Used to tint blurred background only when backgroundType is KVNProgressBackgroundTypeBlurred. */
@property (nonatomic) UIColor *backgroundTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Color of the circle stroke. */
@property (nonatomic) UIColor *circleStrokeForegroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Background color of the circle stroke. Used only when view is showing with a progress circle. */
@property (nonatomic) UIColor *circleStrokeBackgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** background color of the circle. */
@property (nonatomic) UIColor *circleFillBackgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Color of the status label. */
@property (nonatomic) UIColor *statusColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Font of the status label. */
@property (nonatomic) UIFont *statusFont NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Size of the circle. */
@property (nonatomic) CGFloat circleSize NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Width of the circle stroke line */
@property (nonatomic) CGFloat lineWidth NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;

#pragma mark - Progress methods

/** Show a full screen indeterminate progress view with blurred background and no status. */
+ (void)show NS_AVAILABLE_IOS(7_0);
/** Show a full screen indeterminate progress view with specified background and no status. */
+ (void)showWithBackgroundType:(KVNProgressBackgroundType)backgroundType NS_AVAILABLE_IOS(7_0);
/** Show a full screen indeterminate progress view with blurred background and specified status. */
+ (void)showWithStatus:(NSString *)status NS_AVAILABLE_IOS(7_0);
/** Show a full screen indeterminate progress view with specified background and specified status. */
+ (void)showWithStatus:(NSString *)status
		backgroundType:(KVNProgressBackgroundType)backgroundType NS_AVAILABLE_IOS(7_0);

/** Show a full screen specified progress view with blurred background and no status. */
+ (void)showProgress:(CGFloat)progress NS_AVAILABLE_IOS(7_0);
/** Show a full screen specified progress view with specified background and no status. */
+ (void)showProgress:(CGFloat)progress
	  backgroundType:(KVNProgressBackgroundType)backgroundType NS_AVAILABLE_IOS(7_0);
/** Show a full screen specified progress view with blurred background and specified status. */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status NS_AVAILABLE_IOS(7_0);
/** Show a full screen specified progress view with specified background and specified status. */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status
	  backgroundType:(KVNProgressBackgroundType)backgroundType NS_AVAILABLE_IOS(7_0);

/** Dismiss progress view with a fade animation. Does nothing if the progress view is not on screen. */
+ (void)dismiss NS_AVAILABLE_IOS(7_0);

#pragma mark - Update

/**
 Change the loading status while it's showing.
 Nothing happens when progress view isn't showing.
 @param status The status to show
 */
+ (void)updateStatus:(NSString*)status;

/**
 Update the progress loader while it's showing
 Nothing happens when progress view isn't showing.
 @param progress The progress value between 0 and 1
 @param animated Wether or not the change has to be animated
 */
+ (void)updateProgress:(CGFloat)progress
			  animated:(BOOL)animated;

#pragma mark - Information

/**
 Tell if the progress view is on screen.
 @return YES if the progress view is on screen, otherwise NO.
 */
+ (BOOL)isVisible;

@end
