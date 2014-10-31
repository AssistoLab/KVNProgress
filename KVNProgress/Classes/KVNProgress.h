//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, KVNProgressBackgroundType) {
	/** Don't allow user interactions and show a solid color background */
	KVNProgressBackgroundTypeSolid,
	/** Don't allow user interactions and show a blurred background */
	KVNProgressBackgroundTypeBlurred
};

/** The minimum time (in seconds) the hud will be displayed. No matter if <code>dismiss</code> is called. */
static NSTimeInterval const KVNMinimumDisplayTime = 0.3;
/** The minimum time (in seconds) the success checkmark will be displayed. */
static NSTimeInterval const KVNMinimumSuccessDisplayTime = 2.0;

@interface KVNProgress : UIView

#pragma mark - Appearance

/** Color of the background view. Is not used when backgroundType is KVNProgressBackgroundTypeBlurred. */
@property (nonatomic) UIColor *backgroundFillColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Tint color of the background view. Used to tint blurred background only when backgroundType is KVNProgressBackgroundTypeBlurred. */
@property (nonatomic) UIColor *backgroundTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Color of the circle stroke. */
@property (nonatomic) UIColor *circleStrokeForegroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Background color of the circle stroke. Used only when view is showing with a progress circle. */
@property (nonatomic) UIColor *circleStrokeBackgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** background color of the circle. */
@property (nonatomic) UIColor *circleFillBackgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** color of the circle and checkmark when showing success. */
@property (nonatomic) UIColor *successColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** color of the circle and checkmark when showing error. */
@property (nonatomic) UIColor *errorColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Color of the status label. */
@property (nonatomic) UIColor *statusColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Font of the status label. */
@property (nonatomic) UIFont *statusFont NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Size of the circle. */
@property (nonatomic) CGFloat circleSize NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
/** Width of the circle stroke line */
@property (nonatomic) CGFloat lineWidth NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;

#pragma mark - Undeterminate progress methods

/** Show an indeterminate progress view with blurred background and no status (not in fullscreen). */
+ (void)show NS_AVAILABLE_IOS(7_0);
/**
 Show an indeterminate progress view with blurred background and no status.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showFullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show an indeterminate progress view with specified background and no status.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showWithBackgroundType:(KVNProgressBackgroundType)backgroundType
					fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show an indeterminate progress view with blurred background and specified status (not in fullscreen).
 @param status The status to show on the displayed view.
 */
+ (void)showWithStatus:(NSString *)status NS_AVAILABLE_IOS(7_0);
/**
 Show an indeterminate progress view with blurred background and specified status.
 @param status The status to show on the displayed view.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showWithStatus:(NSString *)status
			fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show an indeterminate progress view with specified background and specified status.
 @param status The status to show on the displayed view.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showWithStatus:(NSString *)status
		backgroundType:(KVNProgressBackgroundType)backgroundType
			fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);

/**
 Show an indeterminate progress view with specified background and specified status.
 @param status The status to show on the displayed view.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param view The superview of the progress view.
 */
+ (void)showWithStatus:(NSString *)status
		backgroundType:(KVNProgressBackgroundType)backgroundType
				  view:(UIView *)view;

#pragma mark - Determinate progress methods

/**
 Show a specified progress view with blurred background and no status (not in fullscreen).
 @param progress The progress to display between 0 and 1.
 */
+ (void)showProgress:(CGFloat)progress NS_AVAILABLE_IOS(7_0);
/**
 Show a specified progress view with blurred background and no status.
 @param progress The progress to display between 0 and 1.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showProgress:(CGFloat)progress
		  fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show a specified progress view with specified background and no status.
 @param progress The progress to display between 0 and 1.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showProgress:(CGFloat)progress
	  backgroundType:(KVNProgressBackgroundType)backgroundType
		  fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show a specified progress view with blurred background and specified status (not in fullscreen).
 @param status The status to show on the displayed view.
 */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status NS_AVAILABLE_IOS(7_0);
/**
 Show a specified progress view with blurred background and specified status.
 @param progress The progress to display between 0 and 1.
 @param status The status to show on the displayed view.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status
		  fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show a full screen specified progress view with specified background and specified status.
 @param progress The progress to display between 0 and 1.
 @param status The status to show on the displayed view.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status
	  backgroundType:(KVNProgressBackgroundType)backgroundType
		  fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);

#pragma mark - Success methods

/** Show a sucess view with blurred background and no status (not in fullscreen). */
+ (void)showSuccess NS_AVAILABLE_IOS(7_0);
/**
 Show a sucess view with blurred background and no status.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showSuccessFullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show a sucess view with specified background and no status.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showSuccessWithBackgroundType:(KVNProgressBackgroundType)backgroundType
						   fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show a sucess view with blurred background and specified status (not in fullscreen).
 @param status The status to show on the displayed view.
 */
+ (void)showSuccessWithStatus:(NSString *)status NS_AVAILABLE_IOS(7_0);
/**
 Show a sucess view with blurred background and specified status.
 @param status The status to show on the displayed view.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showSuccessWithStatus:(NSString *)status
				   fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);
/**
 Show a sucess view with specified background and specified status.
 @param status The status to show on the displayed view.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param fullScreen Boolean that tells if view has to be fullscreen or display as a basic HUD.
 */
+ (void)showSuccessWithStatus:(NSString *)status
			   backgroundType:(KVNProgressBackgroundType)backgroundType
				   fullScreen:(BOOL)fullScreen NS_AVAILABLE_IOS(7_0);

/**
 Show a sucess view with specified background and specified status.
 @param status The status to show on the displayed view.
 @param backgroundType The view background type. See KVNProgressBackgroundType.
 @param view The superview of the progress view.
 */
+ (void)showSuccessWithStatus:(NSString *)status
			   backgroundType:(KVNProgressBackgroundType)backgroundType
						 view:(UIView *)view;

#pragma mark - Dimiss

/**
 Dismiss progress view with a fade animation. Does nothing if the progress view is not on screen.
 <br/><br/><b>Remark:</b> You may want to use <code>dismissWithCompletion:</code> if <code>KVNMinimumDisplayTime</code> is greater than zero.
 @see dismissWithCompletion:
 */
+ (void)dismiss NS_AVAILABLE_IOS(7_0);

/**
 Dismiss progress view with a fade animation and call a completion handler when the dismiss process is finished. Does nothing if the progress view is not on screen.
 <br/><br/><b>Remark:</b> This method can be usefull if the <code>KVNMinimumDisplayTime</code> constant is greater than zero to ensure the view is correctly dismissed.
 @param completion The completion handler called after the view is completely dismissed
 */
+ (void)dismissWithCompletion:(void (^)(void))completion NS_AVAILABLE_IOS(7_0);

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
