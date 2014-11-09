//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, KVNProgressBackgroundType) {
	/** Don't allow user interactions and show a blurred background. Default value. */
	KVNProgressBackgroundTypeBlurred,
	/** Don't allow user interactions and show a solid color background. */
	KVNProgressBackgroundTypeSolid,
};

/** @see showWithParameters: */
extern NSString * const KVNProgressViewParameterFullScreen;
/** @see showWithParameters: */
extern NSString * const KVNProgressViewParameterBackgroundType;
/** @see showWithParameters: */
extern NSString * const KVNProgressViewParameterStatus;
/** @see showWithParameters: */
extern NSString * const KVNProgressViewParameterSuperview;

/** The minimum time (in seconds) the hud will be displayed. No matter if <code>dismiss</code> is called. */
static NSTimeInterval const KVNMinimumDisplayTime = 0.3;
/** The minimum time (in seconds) the success will be displayed. */
static NSTimeInterval const KVNMinimumSuccessDisplayTime = 2.0;
/** The minimum time (in seconds) the error will be displayed. */
static NSTimeInterval const KVNMinimumErrorDisplayTime = 1.3;

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

#pragma mark - Loading

/** Shows an indeterminate progress view with blurred background and no status (not in fullscreen). */
+ (void)show NS_AVAILABLE_IOS(7_0);

/**
 Shows an indeterminate progress view with blurred background and specified status (not in fullscreen).
 @param status The status to show on the displayed view.
 */
+ (void)showWithStatus:(NSString *)status NS_AVAILABLE_IOS(7_0);

/**
 Shows a progress view with defined parameters.
 <br/><br/>Use:
 <br/><br/><code><b>KVNProgressViewParameterFullScreen</b></code>:<br/> to precise full screen or not HUD (<code>NSNumber</code> value from a boolean). <br/><i>Omit to set default non full screen.</i>
 <br/><br/><code><b>KVNProgressViewParameterBackgroundType</b></code>:<br/> to precise blurred or solid HUD background (<code>NSNumber</code> value from a <code>KVNProgressBackgroundType</code> enumeration value). <br/><i>Omit to set default blurred background type.</i>
 <br/><br/><code><b>KVNProgressViewParameterStatus</b></code>:<br/> to precise the HUD status (<code>NSString</code> value). <br/><i>Omit to set default no status.</i>
 <br/><br/><code><b>KVNProgressViewParameterSuperview</b></code>:<br/> to precise the superview of the HUD. <br/><i>Omit to set default current window superview.</i>
 <br/><br/>Example:
 <br/>
 <pre>
[KVNProgress showWithParameters:<br/>
  @{KVNProgressViewParameterFullScreen: @(YES),<br/>
    KVNProgressViewParameterBackgroundType: @(KVNProgressBackgroundTypeSolid),<br/>
    KVNProgressViewParameterStatus: \@"Loading",<br/>
    KVNProgressViewParameterSuperview: self.view<br/>
   }];
 </pre>
 @param parameters The parameters of the progress view.
 */
+ (void)showWithParameters:(NSDictionary *)parameters NS_AVAILABLE_IOS(7_0);

#pragma mark - Progress

/**
 Show a specified progress view with blurred background and no status (not in fullscreen).
 @param progress The progress to display between 0 and 1.
 */
+ (void)showProgress:(CGFloat)progress NS_AVAILABLE_IOS(7_0);

/**
 Show a specified progress view with blurred background and specified status (not in fullscreen).
 @param status The status to show on the displayed view.
 */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status NS_AVAILABLE_IOS(7_0);

/**
 Shows a specified progress view with defined parameters.
 @see <code> showWithParameters:</code> method for more information on the possible parameters.
 @param progress The progress to display between 0 and 1.
 @param parameters The parameters of the progress view.
 */
+ (void)showProgress:(CGFloat)progress
		  parameters:(NSDictionary *)parameters NS_AVAILABLE_IOS(7_0);

#pragma mark - Success

/** Show a success view with blurred background and no status (not in fullscreen). */
+ (void)showSuccess NS_AVAILABLE_IOS(7_0);

/**
 Show a success view with blurred background and specified status (not in fullscreen).
 @param status The status to show on the displayed view.
 */
+ (void)showSuccessWithStatus:(NSString *)status NS_AVAILABLE_IOS(7_0);

/**
 Shows a success view with defined parameters.
 @see <code> showWithParameters:</code> method for more information on the possible parameters.
 @param parameters The parameters of the progress view.
 */
+ (void)showSuccessWithParameters:(NSDictionary *)parameters NS_AVAILABLE_IOS(7_0);

#pragma mark - Error

/** Show an error view with blurred background and no status (not in fullscreen). */
+ (void)showError NS_AVAILABLE_IOS(7_0);

/**
 Show an error view with blurred background and specified status (not in fullscreen).
 @param status The status to show on the displayed view.
 */
+ (void)showErrorWithStatus:(NSString *)status NS_AVAILABLE_IOS(7_0);

/**
 Shows an error view with defined parameters.
 @see <code> showWithParameters:</code> method for more information on the possible parameters.
 @param parameters The parameters of the progress view.
 */
+ (void)showErrorWithParameters:(NSDictionary *)parameters NS_AVAILABLE_IOS(7_0);

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
