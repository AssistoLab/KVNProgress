//
//  KVNProgress.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

@import QuartzCore;
@import GLKit;

#import "KVNProgress.h"

#import "UIImage+KVNImageEffects.h"
#import "UIImage+KVNEmpty.h"

typedef NS_ENUM(NSUInteger, KVNProgressStyle) {
	KVNProgressStyleHidden,
	KVNProgressStyleProgress,
	KVNProgressStyleSuccess,
	KVNProgressStyleError
};

NSString * const KVNProgressViewParameterFullScreen = @"KVNProgressViewParameterFullScreen";
NSString * const KVNProgressViewParameterBackgroundType = @"KVNProgressViewParameterBackgroundType";
NSString * const KVNProgressViewParameterStatus = @"KVNProgressViewParameterStatus";
NSString * const KVNProgressViewParameterSuperview = @"KVNProgressViewParameterSuperview";

static CGFloat const KVNFadeAnimationDuration = 0.3f;
static CGFloat const KVNLayoutAnimationDuration = 0.3f;
static CGFloat const KVNTextUpdateAnimationDuration = 0.5f;
static CGFloat const KVNCheckmarkAnimationDuration = 0.5f;
static CGFloat const KVNInfiniteLoopAnimationDuration = 1.0f;
static CGFloat const KVNProgressAnimationDuration = 0.25f;
static CGFloat const KVNProgressIndeterminate = CGFLOAT_MAX;
static CGFloat const KVNCircleProgressViewToStatusLabelVerticalSpaceConstraintConstant = 20.0f;
static CGFloat const KVNContentViewFullScreenModeLeadingAndTrailingSpaceConstraintConstant = 0.0f;
static CGFloat const KVNContentViewNotFullScreenModeLeadingAndTrailingSpaceConstraintConstant = 55.0f;
static CGFloat const KVNContentViewWithStatusInset = 10.0f;
static CGFloat const KVNContentViewWithoutStatusInset = 20.0f;
static CGFloat const KVNContentViewCornerRadius = 8.0f;
static CGFloat const KVNContentViewWithoutStatusCornerRadius = 15.0f;
static CGFloat const KVNAlertViewWidth = 270.0f;
static CGFloat const KVNMotionEffectRelativeValue = 10.0f;

@interface KVNProgress ()

@property (nonatomic) CGFloat progress;
@property (nonatomic) KVNProgressBackgroundType backgroundType;
@property (nonatomic) NSString *status;
@property (nonatomic, getter = isFullScreen) BOOL fullScreen;
@property (nonatomic) KVNProgressStyle style;
@property (nonatomic) NSDate *showActionTrigerredDate;
@property (nonatomic, getter = isWaitingToChangeHUD) BOOL waitingToChangeHUD;
@property (nonatomic, getter = isDismissing) BOOL dismissing;

// UI
@property (nonatomic, weak) IBOutlet UIImageView *contentView;
@property (nonatomic, weak) IBOutlet UIView *circleProgressView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) CAShapeLayer *checkmarkLayer;
@property (nonatomic, strong) CAShapeLayer *crossLayer;
@property (nonatomic, strong) CAShapeLayer *circleProgressLineLayer;
@property (nonatomic, strong) CAShapeLayer *circleBackgroundLineLayer;

// Constraints
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *circleProgressViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *circleProgressViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleProgressViewToStatusLabelVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeadingToSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTrailingToSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleProgressViewTopToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelBottomToSuperViewConstraint;

@property (nonatomic) NSArray *constraintsToSuperview;

@end

@implementation KVNProgress

#pragma mark - Shared

+ (KVNProgress *)sharedView
{
	static KVNProgress *sharedView = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		UINib *nib = [UINib nibWithNibName:@"KVNProgressView"
									bundle:nil];
		NSArray *nibViews = [nib instantiateWithOwner:self
											  options:0];
		
		sharedView = nibViews[0];
	});
	
	return sharedView;
}

#pragma mark - Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		// Appearance
		_backgroundFillColor = [UIColor colorWithWhite:1.0f alpha:0.85f];
		_backgroundTintColor = [UIColor whiteColor];
		
		_circleStrokeForegroundColor = [UIColor darkGrayColor];
		_circleStrokeBackgroundColor = [_circleStrokeForegroundColor colorWithAlphaComponent:0.3f];
		_circleFillBackgroundColor = [UIColor clearColor];
		
		_successColor = [UIColor darkGrayColor];
		_errorColor = [UIColor darkGrayColor];
		
		_statusColor = [UIColor darkGrayColor];
		_statusFont = [UIFont systemFontOfSize:17.0f];
		
		_lineWidth = 2.0f;
	}
	
	return self;
}

#pragma mark - Loading

+ (void)show
{
	[self showWithStatus:nil];
}

+ (void)showWithStatus:(NSString *)status
{
	[self showWithParameters:[self baseHUDParametersWithStatus:status]];
}

+ (void)showWithParameters:(NSDictionary *)parameters
{
	[self showHUDWithProgress:KVNProgressIndeterminate
						style:KVNProgressStyleProgress
				   parameters:parameters];
}

#pragma mark - Progress

+ (void)showProgress:(CGFloat)progress
{
	[self showProgress:progress
				status:nil];
}

+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status
{
	[self showProgress:progress
			parameters:[self baseHUDParametersWithStatus:status]];
}

+ (void)showProgress:(CGFloat)progress
		  parameters:(NSDictionary *)parameters
{
	[self showHUDWithProgress:progress
						style:KVNProgressStyleProgress
				   parameters:parameters];
}

#pragma mark - Success

+ (void)showSuccess
{
	[self showSuccessWithStatus:nil];
}

+ (void)showSuccessWithStatus:(NSString *)status
{
	[self showSuccessWithParameters:[self baseHUDParametersWithStatus:status]];
}

+ (void)showSuccessWithParameters:(NSDictionary *)parameters
{
	[self showHUDWithProgress:KVNProgressIndeterminate
						style:KVNProgressStyleSuccess
				   parameters:parameters];
}

#pragma mark - Error

+ (void)showError
{
	[self showErrorWithStatus:nil];
}

+ (void)showErrorWithStatus:(NSString *)status
{
	[self showErrorWithParameters:[self baseHUDParametersWithStatus:status]];
}

+ (void)showErrorWithParameters:(NSDictionary *)parameters
{
	[self showHUDWithProgress:KVNProgressIndeterminate
						style:KVNProgressStyleError
				   parameters:parameters];
}

#pragma mark - Show

+ (void)showHUDWithProgress:(CGFloat)progress
					  style:(KVNProgressStyle)style
				 parameters:(NSDictionary *)parameters
{
	[[self sharedView] showProgress:progress
							 status:parameters[KVNProgressViewParameterStatus]
							  style:style
					 backgroundType:(KVNProgressBackgroundType)[parameters[KVNProgressViewParameterBackgroundType] unsignedIntegerValue]
						 fullScreen:[parameters[KVNProgressViewParameterFullScreen] boolValue]
							   view:parameters[KVNProgressViewParameterSuperview]];
}

- (void)showProgress:(CGFloat)progress
			  status:(NSString *)status
			   style:(KVNProgressStyle)style
	  backgroundType:(KVNProgressBackgroundType)backgroundType
		  fullScreen:(BOOL)fullScreen
				view:(UIView *)superview
{
	__block KVNProgress *__blockSelf = self;
	
	// We check if a previous HUD is displaying
	// If so, we wait its minimum display time before switching to the new one
	// But, if we are changing from an indeterminate progress HUD to a determinate one,
	// we do not apply this rule
	if (![self isWaitingToChangeHUD] && self.style != KVNProgressStyleHidden
		&& !(self.style == KVNProgressStyleProgress && self.progress == KVNProgressIndeterminate && progress != KVNProgressIndeterminate)) {
		self.waitingToChangeHUD = YES;
		self.dismissing = NO;

		NSTimeInterval timeIntervalSinceShow = [self.showActionTrigerredDate timeIntervalSinceNow];
		NSTimeInterval delay = 0;
		
		if (timeIntervalSinceShow < KVNMinimumDisplayTime) {
			// The hud hasn't showed enough time
			timeIntervalSinceShow = (timeIntervalSinceShow < 0) ? 0 : timeIntervalSinceShow;
			delay = KVNMinimumDisplayTime - timeIntervalSinceShow;
		}
		
		if (delay > 0) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if ([__blockSelf isDismissing] || ![__blockSelf.class isVisible]) {
					// While waiting for displaying previous HUD enough time before showing the new one,
					// the dismiss method on this new HUD has already been called
					// So logically, we do not display the new HUD that is already dismissed (before even being displayed)
					return;
				}
				
				[__blockSelf showProgress:progress
								   status:status
									style:style
						   backgroundType:backgroundType
							   fullScreen:fullScreen
									 view:superview];
			});
			
			return;
		}
	}
	
	// We're going to create a new HUD
	self.waitingToChangeHUD = NO;
	self.progress = progress;
	self.status = [status copy];
	self.style = style;
	self.backgroundType = backgroundType;
	self.fullScreen = fullScreen;

	// If HUD is already added to the view we just update the UI
	if ([self.class isVisible]) {
		[UIView animateWithDuration:KVNLayoutAnimationDuration
						 animations:^{
							 [__blockSelf setupUI];
						 }];
		
		__blockSelf.showActionTrigerredDate = [NSDate date];
		[__blockSelf animateUI];
	} else {
		[self setupUI];
		
		if (superview) {
			[self addToView:superview];
		} else {
			[self addToCurrentWindow];
		}
		
		// FIXME: find a way to wait for the views to be added to the window before launching the animations
		// (Fix to make the animations work fine)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[__blockSelf animateUI];
			[__blockSelf animateAppearance];
		});
	}
	
	// If it's an auto-dismissable HUD
	if (self.style != KVNProgressStyleProgress) {
		NSTimeInterval delay;
		switch (self.style) {
			case KVNProgressStyleProgress:
				// should never happen
				return;
			case KVNProgressStyleSuccess:
				delay = KVNMinimumSuccessDisplayTime;
				break;
			case KVNProgressStyleError:
				delay = KVNMinimumErrorDisplayTime;
				break;
			case KVNProgressStyleHidden:
				// should never happen
				return;
		}
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[__blockSelf.class dismiss];
		});
	}
}

#pragma mark - Dimiss

+ (void)dismiss
{
	[self dismissWithCompletion:nil];
}

+ (void)dismissWithCompletion:(void (^)(void))completion
{
	if (![self isVisible]) {
		return;
	}
	
	[self sharedView].dismissing = YES;

	// FIXME: find a way to wait for the views to be added to the window before launching the animations
	// (Fix to make the dismiss work fine)
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		// If the view has changed or will change, the dismissing property is set back to NO so we don't dismiss
		// the (scheduled) new one
		if ([[self sharedView] isDismissing]) {
			[self dismissAnimatedWithCompletion:completion];
		}
	});
}

+ (void)dismissAnimatedWithCompletion:(void (^)(void))completion
{
	KVNProgress *progressView = [self sharedView];
	
	NSTimeInterval timeIntervalSinceShow = fabs([progressView.showActionTrigerredDate timeIntervalSinceNow]);
	NSTimeInterval delay = 0;
	
	if (timeIntervalSinceShow < KVNMinimumDisplayTime) {
		// The hud hasn't showed enough time
		delay = KVNMinimumDisplayTime - timeIntervalSinceShow;
	}

	[UIView animateWithDuration:KVNFadeAnimationDuration
						  delay:delay
						options:(UIViewAnimationOptionCurveEaseIn
								 | UIViewAnimationOptionAllowUserInteraction
								 | UIViewAnimationOptionBeginFromCurrentState)
					 animations:^{
						 if ([[self sharedView] isDismissing]) {
							 progressView.alpha = 0.0f;
						 }
					 } completion:^(BOOL finished) {
						 if(progressView.alpha == 0 || progressView.contentView.alpha == 0) {
							 if ([progressView isDismissing]) {
								 progressView.dismissing = NO;
								 
								 [progressView cancelCircleAnimation];
								 [progressView removeFromSuperview];
								 
								 progressView.style = KVNProgressStyleHidden;
								 
								 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
								 
								 // Tell the rootViewController to update the StatusBar appearance
								 UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
								 if ([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
									 [rootController setNeedsStatusBarAppearanceUpdate];
								 }
							 }
							 
							 if (completion) {
								 dispatch_async(dispatch_get_main_queue(), ^{
									 completion();
								 });
							 }
						 }
					 }];
}

#pragma mark - UI

- (void)setupUI
{
	[self setupConstraints];
	[self setupCircleProgressView];
	[self setupStatus:self.status];
	[self setupBackground];
}

- (void)setupConstraints
{
	CGFloat statusInset = (self.status.length > 0) ? KVNContentViewWithStatusInset : KVNContentViewWithoutStatusInset;
	CGFloat contentMargin = ([self isFullScreen]) ? KVNContentViewFullScreenModeLeadingAndTrailingSpaceConstraintConstant : KVNContentViewNotFullScreenModeLeadingAndTrailingSpaceConstraintConstant;
	
	if ([self isFullScreen]) {
		contentMargin = KVNContentViewFullScreenModeLeadingAndTrailingSpaceConstraintConstant;
	} else {
		CGFloat contentWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - (2 * KVNContentViewNotFullScreenModeLeadingAndTrailingSpaceConstraintConstant);
		
		if (contentWidth > KVNAlertViewWidth) {
			contentMargin = (CGRectGetWidth([UIScreen mainScreen].bounds) - KVNAlertViewWidth) / 2.0f;
		}
	}
	
	self.circleProgressViewTopToSuperViewConstraint.constant = statusInset;
	self.statusLabelBottomToSuperViewConstraint.constant = statusInset;
	
	self.contentViewLeadingToSuperviewConstraint.constant = contentMargin;
	self.contentViewTrailingToSuperviewConstraint.constant = contentMargin;
}

- (void)setupCircleProgressView
{
	// Constraints
	self.circleProgressViewWidthConstraint.constant = self.circleSize;
	self.circleProgressViewHeightConstraint.constant = self.circleSize;
	
	[self layoutIfNeeded];
	
	// Circle shape
	self.circleProgressView.layer.cornerRadius = (_circleSize / 2.0f);
	self.circleProgressView.layer.masksToBounds = YES;
	self.circleProgressView.backgroundColor = [UIColor clearColor];
	
	// Remove all previous added layers
	[self removeAllSubLayersOfLayer:self.circleProgressView.layer];
}

- (void)setupInfiniteCircle
{
	CGFloat radius = (self.circleSize / 2.0f);
	CGPoint center = CGPointMake(radius, radius);
	
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
															  radius:(radius - self.lineWidth)
														  startAngle:GLKMathDegreesToRadians(-45.0f)
															endAngle:GLKMathDegreesToRadians(275.0f)
														   clockwise:YES];
	
	self.circleProgressLineLayer = [CAShapeLayer layer];
	self.circleProgressLineLayer.path = circlePath.CGPath;
	self.circleProgressLineLayer.strokeColor = self.circleStrokeForegroundColor.CGColor;
	self.circleProgressLineLayer.fillColor = self.circleFillBackgroundColor.CGColor;
	self.circleProgressLineLayer.lineWidth = self.lineWidth;
	
	[self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
	
	[self.circleProgressLineLayer removeAllAnimations];
	[self.circleProgressView.layer removeAllAnimations];
	[self animateCircleWithInfiniteLoop];
}

- (void)setupProgressCircle
{
	CGFloat radius = (self.circleSize / 2.0f);
	CGPoint center = CGPointMake(radius, radius);
	
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
															  radius:(radius - self.lineWidth)
														  startAngle:GLKMathDegreesToRadians(-90.0f)
															endAngle:GLKMathDegreesToRadians(275.0f)
														   clockwise:YES];
	
	[self cancelCircleAnimation];
	
	self.circleProgressLineLayer = [CAShapeLayer layer];
	self.circleProgressLineLayer.path = circlePath.CGPath;
	self.circleProgressLineLayer.strokeColor = self.circleStrokeForegroundColor.CGColor;
	self.circleProgressLineLayer.fillColor = [UIColor clearColor].CGColor;
	self.circleProgressLineLayer.lineWidth = self.lineWidth;
	
	self.circleBackgroundLineLayer = [CAShapeLayer layer];
	self.circleBackgroundLineLayer.path = circlePath.CGPath;
	self.circleBackgroundLineLayer.strokeColor = self.circleStrokeBackgroundColor.CGColor;
	self.circleBackgroundLineLayer.fillColor = self.circleFillBackgroundColor.CGColor;
	self.circleBackgroundLineLayer.lineWidth = self.lineWidth;
	
	[self.circleProgressView.layer addSublayer:self.circleBackgroundLineLayer];
	[self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
	
	[self.circleProgressLineLayer removeAllAnimations];
	[self.circleProgressView.layer removeAllAnimations];
	
	[self updateProgress:self.progress
				animated:NO];
}

- (void)setupSuccessUI
{
	[self setupFullRoundCircleWithColor:self.successColor];
	
	UIBezierPath* checkmarkPath = [UIBezierPath bezierPath];
	[checkmarkPath moveToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.28f, CGRectGetHeight(self.circleProgressView.bounds) * 0.53f)];
	[checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.42f, CGRectGetHeight(self.circleProgressView.bounds) * 0.66f)];
	[checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.72f, CGRectGetHeight(self.circleProgressView.bounds) * 0.36f)];
	checkmarkPath.lineCapStyle = kCGLineCapSquare;
	
	self.checkmarkLayer = [CAShapeLayer layer];
	self.checkmarkLayer.path = checkmarkPath.CGPath;
	self.checkmarkLayer.fillColor = nil;
	self.checkmarkLayer.strokeColor = self.successColor.CGColor;
	self.checkmarkLayer.lineWidth = self.lineWidth;
	
	[self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
	[self.circleProgressView.layer addSublayer:self.checkmarkLayer];
	
	[self.circleProgressLineLayer removeAllAnimations];
	[self.circleProgressView.layer removeAllAnimations];
	[self.checkmarkLayer removeAllAnimations];
	[self animateSuccess];
}

- (void)setupErrorUI
{
	[self setupFullRoundCircleWithColor:self.errorColor];
	
	UIBezierPath* crossPath = [UIBezierPath bezierPath];
	[crossPath moveToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.72f, CGRectGetHeight(self.circleProgressView.bounds) * 0.27f)];
	[crossPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.27f, CGRectGetHeight(self.circleProgressView.bounds) * 0.72f)];
	[crossPath moveToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.27f, CGRectGetHeight(self.circleProgressView.bounds) * 0.27f)];
	[crossPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.72f, CGRectGetHeight(self.circleProgressView.bounds) * 0.72f)];
	crossPath.lineCapStyle = kCGLineCapSquare;
	
	self.crossLayer = [CAShapeLayer layer];
	self.crossLayer.path = crossPath.CGPath;
	self.crossLayer.fillColor = nil;
	self.crossLayer.strokeColor = self.errorColor.CGColor;
	self.crossLayer.lineWidth = self.lineWidth;
	
	[self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
	[self.circleProgressView.layer addSublayer:self.crossLayer];
	
	[self.circleProgressLineLayer removeAllAnimations];
	[self.circleProgressView.layer removeAllAnimations];
	[self.crossLayer removeAllAnimations];
	[self animateError];
}

- (void)setupFullRoundCircleWithColor:(UIColor *)color
{
	CGFloat radius = (self.circleSize / 2.0f);
	CGPoint center = CGPointMake(radius, radius);
	
	// Circle
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
															  radius:(radius - self.lineWidth)
														  startAngle:GLKMathDegreesToRadians(-90.0f)
															endAngle:GLKMathDegreesToRadians(275.0f)
														   clockwise:YES];
	
	self.circleProgressLineLayer = [CAShapeLayer layer];
	self.circleProgressLineLayer.path = circlePath.CGPath;
	self.circleProgressLineLayer.strokeColor = color.CGColor;
	self.circleProgressLineLayer.fillColor = self.circleFillBackgroundColor.CGColor;
	self.circleProgressLineLayer.lineWidth = self.lineWidth;
}

- (void)setupStatus:(NSString *)status
{
	self.status = status;
	
	BOOL showStatus = (self.status.length > 0);
	
	CATransition *animation = [CATransition animation];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.type = kCATransitionFade;
	animation.duration = KVNTextUpdateAnimationDuration;
	[self.statusLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
	
	self.statusLabel.text = self.status;
	self.statusLabel.textColor = self.statusColor;
	self.statusLabel.font = self.statusFont;
	self.statusLabel.hidden = !showStatus;
	
	self.circleProgressViewToStatusLabelVerticalSpaceConstraint.constant = (showStatus) ? KVNCircleProgressViewToStatusLabelVerticalSpaceConstraintConstant : 0.0f;
	
	CGSize maximumLabelSize = CGSizeMake(CGRectGetWidth(self.statusLabel.bounds), CGFLOAT_MAX);
	CGSize statusLabelSize = [self.statusLabel sizeThatFits:maximumLabelSize];
	self.statusLabelHeightConstraint.constant = statusLabelSize.height;
	
	[self layoutIfNeeded];
}

- (void)setupBackground
{
	if ([self.class isVisible]) {
		return; // No reload of background when view is showing
	}
	
	UIImage *backgroundImage = nil;
	UIColor *backgroundColor = nil;
	
	switch (self.backgroundType) {
		case KVNProgressBackgroundTypeSolid:
			backgroundImage = [UIImage emptyImage];
			backgroundColor = self.backgroundFillColor;
			break;
		case KVNProgressBackgroundTypeBlurred:
			backgroundImage = [self blurredScreenShot];
			backgroundColor = [UIColor clearColor];
			break;
	}
	
	if ([self isFullScreen])
	{
		self.backgroundImageView.image = backgroundImage;
		self.backgroundImageView.backgroundColor = backgroundColor;
		
		self.contentView.layer.cornerRadius = 0.0f;
		self.contentView.layer.masksToBounds = NO;
		self.contentView.image = [UIImage emptyImage];
		self.contentView.backgroundColor = [UIColor clearColor];
	}
	else
	{
		if (self.status.length == 0) {
			self.circleProgressViewTopToSuperViewConstraint.constant = KVNContentViewWithoutStatusInset;
			self.statusLabelBottomToSuperViewConstraint.constant = KVNContentViewWithoutStatusInset;
			
			CGFloat contentViewHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
			CGFloat screenSize = CGRectGetWidth([UIScreen mainScreen].bounds);
			CGFloat leadingAndTrailingConstraint = (screenSize - contentViewHeight) / 2.0f;
			self.contentViewLeadingToSuperviewConstraint.constant = leadingAndTrailingConstraint;
			self.contentViewTrailingToSuperviewConstraint.constant = leadingAndTrailingConstraint;
		}
		
		self.backgroundImageView.image = [UIImage emptyImage];
		self.backgroundImageView.backgroundColor = [UIColor colorWithWhite:0.0f
																	 alpha:0.35f];
		
		self.contentView.layer.cornerRadius = (self.status) ? KVNContentViewCornerRadius : KVNContentViewWithoutStatusCornerRadius;
		self.contentView.layer.masksToBounds = YES;
		self.contentView.contentMode = UIViewContentModeCenter;
		self.contentView.backgroundColor = self.backgroundFillColor;
		
		self.contentView.image = backgroundImage;
	}
	
	if ([self.contentView.motionEffects count] == 0) {
		[self setupMotionEffect];
	}
}

- (void)setupMotionEffect
{
	UIInterpolatingMotionEffect *xAxis = [self motionEffectWithType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis
															keyPath:@"center.x"];
	UIInterpolatingMotionEffect *yAxis = [self motionEffectWithType:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis
															keyPath:@"center.y"];
	UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
	group.motionEffects = @[xAxis, yAxis];
	
	[self.contentView addMotionEffect:group];
}

- (void)addToCurrentWindow
{
	UIWindow *currentWindow = nil;
	
	NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
	
	for (UIWindow *window in frontToBackWindows) {
		if (window.windowLevel == UIWindowLevelNormal) {
			currentWindow = window;
			break;
		}
	}
	
	if (self.superview != currentWindow) {
		[self addToView:currentWindow];
	}
}

- (void)addToView:(UIView *)superview
{
	if (self.superview) {
		[self.superview removeConstraints:self.constraintsToSuperview];
		[self removeFromSuperview];
	}
	
	[superview addSubview:self];
	[superview bringSubviewToFront:self];
	
	NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self(height)]|"
																		   options:0
																		   metrics:@{@"height" : @(CGRectGetHeight(superview.bounds))}
																			 views:@{@"self" : self}];
	NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self(width)]|"
																			 options:0
																			 metrics:@{@"width" : @(CGRectGetWidth(superview.bounds))}
																			   views:@{@"self" : self}];
	
	self.constraintsToSuperview = [verticalConstraints arrayByAddingObjectsFromArray:horizontalConstraints];
	
	self.translatesAutoresizingMaskIntoConstraints = NO;
	[superview addConstraints:verticalConstraints];
	[superview addConstraints:horizontalConstraints];
	
	[self layoutIfNeeded];
	
	self.alpha = 0.0f;
}

#pragma mark - Update

+ (void)updateStatus:(NSString*)status
{
	[[self sharedView] updateStatus:status];
}

- (void)updateStatus:(NSString *)status
{
	if ([self.class isVisible]) {
		[UIView animateWithDuration:KVNLayoutAnimationDuration
						 animations:^{
							 [self setupStatus:status];
						 }];
	} else {
		[self setupStatus:status];
	}
}

+ (void)updateProgress:(CGFloat)progress
			  animated:(BOOL)animated
{
	[[self sharedView] updateProgress:progress
							 animated:animated];
}

- (void)updateProgress:(CGFloat)progress
			  animated:(BOOL)animated
{
	if (self.style != KVNProgressStyleProgress) {
		return;
	}
	
	if ([self isIndeterminate]) {
		// was inderminate
		[self showProgress:progress
					status:self.status
					 style:self.style
			backgroundType:self.backgroundType
				fullScreen:self.fullScreen
					  view:self.superview];
		
		return;
	}
	
	// Boundry correctness
	progress = MIN(progress, 1.0f);
	progress = MAX(progress, 0.0f);
	
	if (animated) {
		CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		
		progressAnimation.duration = KVNProgressAnimationDuration;
		progressAnimation.removedOnCompletion = NO;
		progressAnimation.fillMode = kCAFillModeBoth;
		progressAnimation.fromValue = @(self.progress);
		progressAnimation.toValue = @(progress);
		progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		[self.circleProgressLineLayer addAnimation:progressAnimation
											forKey:@"strokeEnd"];
	} else {
		self.circleProgressLineLayer.strokeEnd = progress;
	}
	
	self.progress = progress;
}

#pragma mark - Animations

- (void)animateUI
{
	switch (self.style) {
		case KVNProgressStyleProgress: {
			if ([self isIndeterminate]) {
				[self setupInfiniteCircle];
			} else {
				[self setupProgressCircle];
			}
			
			break;
		}
		case KVNProgressStyleSuccess: {
			[self setupSuccessUI];
			break;
		}
		case KVNProgressStyleError: {
			[self setupErrorUI];
			break;
		}
		case KVNProgressStyleHidden: {
			// should enver happen
			break;
		}
	}
}

- (void)animateAppearance
{
	[UIView animateWithDuration:0.0f
						  delay:0.0f
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{}
					 completion:nil];
	
	self.alpha = 0.0f;
	self.contentView.transform = CGAffineTransformScale(self.contentView.transform, 1.2f, 1.2f);
	
	self.showActionTrigerredDate = [NSDate date];
	
	[UIView animateWithDuration:KVNFadeAnimationDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 self.alpha = 1.0f;
						 self.contentView.transform = CGAffineTransformIdentity;
					 } completion:^(BOOL finished) {
						 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
						 UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.status);
					 }];
}

- (void)animateCircleWithInfiniteLoop
{
	CABasicAnimation* rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.toValue = @(M_PI * 2.0f * KVNInfiniteLoopAnimationDuration);
	rotationAnimation.duration = KVNInfiniteLoopAnimationDuration;
	rotationAnimation.cumulative = YES;
	rotationAnimation.repeatCount = HUGE_VALF;
	
	[self.circleProgressView.layer addAnimation:rotationAnimation
										 forKey:@"rotationAnimation"];
}

- (void)cancelCircleAnimation
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	[self.circleProgressView.layer removeAllAnimations];
	[self.circleProgressLineLayer removeAllAnimations];
	[self.circleBackgroundLineLayer removeAllAnimations];
	
	self.circleProgressLineLayer.strokeEnd = 0.0f;
	self.circleBackgroundLineLayer.strokeEnd = 0.0f;
	
	if (self.circleProgressLineLayer.superlayer) {
		[self.circleProgressLineLayer removeFromSuperlayer];
	}
	if (self.circleBackgroundLineLayer.superlayer) {
		[self.circleBackgroundLineLayer removeFromSuperlayer];
	}
	
	self.circleProgressLineLayer = nil;
	self.circleBackgroundLineLayer = nil;
	
	[CATransaction commit];
}

- (void)animateSuccess
{
	[self animateFullCircleWithColor:self.successColor];
	
	CABasicAnimation *checkmarkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	checkmarkAnimation.duration = KVNCheckmarkAnimationDuration;
	checkmarkAnimation.removedOnCompletion = NO;
	checkmarkAnimation.fillMode = kCAFillModeBoth;
	checkmarkAnimation.fromValue = @(0);
	checkmarkAnimation.toValue = @(1);
	checkmarkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	[self.checkmarkLayer addAnimation:checkmarkAnimation
							   forKey:@"strokeEnd"];
}

- (void)animateError
{
	[self animateFullCircleWithColor:self.errorColor];
}

- (void)animateFullCircleWithColor:(UIColor *)color
{
	CABasicAnimation *circleAnimation;
	if (self.superview) {
		circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
		circleAnimation.duration = KVNCheckmarkAnimationDuration;
		circleAnimation.toValue = (id)color.CGColor;
		circleAnimation.fillMode = kCAFillModeBoth;
		circleAnimation.removedOnCompletion = NO;
	} else {
		circleAnimation = [CABasicAnimation animationWithKeyPath:@"alpha"];
		circleAnimation.duration = KVNCheckmarkAnimationDuration;
		circleAnimation.fromValue = @(0);
		circleAnimation.toValue = @(1);
		circleAnimation.fillMode = kCAFillModeBoth;
		circleAnimation.removedOnCompletion = NO;
	}
	
	[self.circleProgressLineLayer addAnimation:circleAnimation
										forKey:@"appearance"];
}

#pragma mark - Helpers

+ (NSDictionary *)baseHUDParametersWithStatus:(NSString *)status
{
	NSDictionary *fixedParameters = @{KVNProgressViewParameterBackgroundType: @(KVNProgressBackgroundTypeBlurred),
									  KVNProgressViewParameterFullScreen: @(NO)};
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:fixedParameters];
	
	if (status) {
		parameters[KVNProgressViewParameterStatus] = status;
	}
	
	return parameters;
}

- (void)removeAllSubLayersOfLayer:(CALayer *)layer
{
	for (CALayer *subLayer in [layer.sublayers copy]) {
		// Technical :
		// we use a copy of self.circleProgressView.layer.sublayers because this array will
		// change when we remove its sublayers
		[subLayer removeFromSuperlayer];
	}
}

- (UIImage *)blurredScreenShot
{
	return [self blurredScreenShotWithRect:[UIApplication sharedApplication].keyWindow.frame];
}

- (UIImage *)blurredScreenShotWithRect:(CGRect)rect
{
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
	
	[keyWindow drawViewHierarchyInRect:rect afterScreenUpdates:NO];
	UIImage *blurredScreenShot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	blurredScreenShot = [self applyTintEffectWithColor:self.backgroundTintColor
												 image:blurredScreenShot];
	
	return blurredScreenShot;
}

- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
								image:(UIImage *)image
{
	const CGFloat EffectColorAlpha = 0.6;
	UIColor *effectColor = tintColor;
	int componentCount = (int)CGColorGetNumberOfComponents(tintColor.CGColor);
	CGFloat tintAlpha = CGColorGetAlpha(tintColor.CGColor);
	
	if (tintAlpha == 0.0f) {
		return [image applyBlurWithRadius:10.0f
								tintColor:nil
					saturationDeltaFactor:1.0f
								maskImage:nil];
	}
	
	if (componentCount == 2) {
		CGFloat b;
		if ([tintColor getWhite:&b alpha:NULL]) {
			effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
		}
	}
	else {
		CGFloat r, g, b;
		if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
			effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
		}
	}
	
	return [image applyBlurWithRadius:10.0f
							tintColor:effectColor
				saturationDeltaFactor:1.0f
							maskImage:nil];
}

- (UIImage *)cropImage:(UIImage *)image
				  rect:(CGRect)cropRect
{
	// Create bitmap image from original image data,
	// using rectangle to specify desired crop area
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
	image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return image;
}

- (UIInterpolatingMotionEffect *)motionEffectWithType:(UIInterpolatingMotionEffectType)motionEffectType
											  keyPath:(NSString *)keypath
{
	UIInterpolatingMotionEffect *motionEffect = [[UIInterpolatingMotionEffect alloc]
												 initWithKeyPath:keypath
												 type:motionEffectType];
	motionEffect.minimumRelativeValue = @(-KVNMotionEffectRelativeValue);
	motionEffect.maximumRelativeValue = @(KVNMotionEffectRelativeValue);
	
	return motionEffect;
}

#pragma mark - Information

- (BOOL)isIndeterminate
{
	return (self.progress == KVNProgressIndeterminate);
}

+ (BOOL)isVisible
{
	return ([self sharedView].superview != nil);
}

#pragma mark - Appearance

- (UIColor *)backgroundFillColor
{
	UIColor *appearanceColor = [[[self class] appearance] backgroundFillColor];
	
	if (appearanceColor) {
		_backgroundFillColor = appearanceColor;
	}
	
	return _backgroundFillColor;
}

- (UIColor *)backgroundTintColor
{
	UIColor *appearanceColor = [[[self class] appearance] backgroundTintColor];
	
	if (appearanceColor) {
		_backgroundTintColor = appearanceColor;
	}
	
	return _backgroundTintColor;
}

- (UIColor *)circleStrokeForegroundColor
{
	UIColor *appearanceColor = [[[self class] appearance] circleStrokeForegroundColor];
	
	if (appearanceColor) {
		_circleStrokeForegroundColor = appearanceColor;
	}
	
	return _circleStrokeForegroundColor;
}

- (UIColor *)circleStrokeBackgroundColor
{
	UIColor *appearanceColor = [[[self class] appearance] circleStrokeBackgroundColor];
	
	if (appearanceColor) {
		_circleStrokeBackgroundColor = appearanceColor;
	}
	
	return _circleStrokeBackgroundColor;
}

- (UIColor *)circleFillBackgroundColor
{
	UIColor *appearanceColor = [[[self class] appearance] circleFillBackgroundColor];
	
	if (appearanceColor) {
		_circleFillBackgroundColor = appearanceColor;
	}
	
	return _circleFillBackgroundColor;
}

- (UIColor *)successColor
{
	UIColor *appearanceColor = [[[self class] appearance] successColor];
	
	if (appearanceColor) {
		_successColor = appearanceColor;
	}
	
	return _successColor;
}

- (UIColor *)errorColor
{
	UIColor *appearanceColor = [[[self class] appearance] errorColor];
	
	if (appearanceColor) {
		_errorColor = appearanceColor;
	}
	
	return _errorColor;
}

- (UIColor *)statusColor
{
	UIColor *appearanceColor = [[[self class] appearance] statusColor];
	
	if (appearanceColor) {
		_statusColor = appearanceColor;
	}
	
	return _statusColor;
}

- (UIFont *)statusFont
{
	UIFont *appearanceFont = [[[self class] appearance] statusFont];
	
	if (appearanceFont) {
		_statusFont = appearanceFont;
	}
	
	return _statusFont;
}

- (CGFloat)circleSize
{
	CGFloat appearanceCircleSize = [[[self class] appearance] circleSize];
	
	if (appearanceCircleSize != 0) {
		_circleSize = appearanceCircleSize;
	}
	
	if (_circleSize == 0) {
		_circleSize = ([self isFullScreen]) ? 90.0f : 75.0f;
	}
	
	return _circleSize;
}

- (CGFloat)lineWidth
{
	CGFloat appearanceLineWidth = [[[self class] appearance] lineWidth];
	
	if (appearanceLineWidth != 0) {
		_lineWidth = appearanceLineWidth;
	}
	
	return _lineWidth;
}

#pragma mark - HitTest

// Used to block interaction for all views behind
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	return (CGRectContainsPoint(self.frame, point)) ? self : nil;
}

@end
