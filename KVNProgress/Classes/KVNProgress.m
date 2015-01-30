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

#define KVNBlockSelf __blockSelf
#define KVNPrepareBlockSelf() __weak typeof(self) KVNBlockSelf = self
#define KVNIpad UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define KVNSystemVersionGreaterOrEqual_iOS_8 ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)
#define KVNRadiansToDegress(radians) ((radians) * (180.0 / M_PI))

typedef NS_ENUM(NSUInteger, KVNProgressStyle) {
    KVNProgressStyleHidden,
    KVNProgressStyleProgress,
    KVNProgressStyleSuccess,
    KVNProgressStyleError
};

typedef NS_ENUM(NSUInteger, KVNProgressState) {
    KVNProgressStateHidden,
    KVNProgressStateAppearing,
    KVNProgressStateShowed,
    KVNProgressStateDismissing
};

static CGFloat const KVNFadeAnimationDuration = 0.3f;
static CGFloat const KVNLayoutAnimationDuration = 0.3f;
static CGFloat const KVNTextUpdateAnimationDuration = 0.5f;
static CGFloat const KVNCheckmarkAnimationDuration = 0.5f;
static CGFloat const KVNInfiniteLoopAnimationDuration = 1.0f;
static CGFloat const KVNProgressAnimationDuration = 0.25f;
static CGFloat const KVNProgressIndeterminate = CGFLOAT_MAX;
static CGFloat const KVNCircleProgressViewToStatusLabelVerticalSpaceConstraintConstant = 20.0f;
static CGFloat const KVNContentViewFullScreenModeLeadingAndTrailingSpaceConstraintConstant = 0.0f;
static CGFloat const KVNContentViewNotFullScreenModeLeadingAndTrailingSpaceConstraintConstant = 25.0f;
static CGFloat const KVNContentViewWithStatusInset = 10.0f;
static CGFloat const KVNContentViewWithoutStatusInset = 20.0f;
static CGFloat const KVNContentViewCornerRadius = 8.0f;
static CGFloat const KVNContentViewWithoutStatusCornerRadius = 15.0f;
static CGFloat const KVNAlertViewWidth = 270.0f;
static CGFloat const KVNMotionEffectRelativeValue = 10.0f;

static KVNProgressConfiguration *configuration;

@interface KVNProgress ()

// Dispatch
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;

// Configuration
@property (nonatomic) CGFloat progress;
@property (nonatomic) KVNProgressBackgroundType backgroundType;
@property (nonatomic) NSString *status;
@property (nonatomic) KVNProgressStyle style;
@property (nonatomic) KVNProgressConfiguration *configuration;
@property (nonatomic) NSDate *showActionTrigerredDate;
@property (nonatomic, getter = isFullScreen) BOOL fullScreen;
@property (nonatomic) KVNProgressState state;

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
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *circleProgressViewToStatusLabelVerticalSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *circleProgressViewTopToSuperViewConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *statusLabelBottomToSuperViewConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;

@property (nonatomic) NSArray *constraintsToSuperview;

+ (void)synchronousDismissWithCompletion:(KVNCompletionBlock)completion;

@end

@implementation KVNProgress

#pragma mark - Shared

+ (KVNProgress *)sharedView
{
    static KVNProgress *sharedView = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        UINib *nib = [UINib nibWithNibName:@"KVNProgressView"
                                    bundle:[NSBundle bundleForClass:[self class]]];
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
        self.queue = dispatch_queue_create("KVNProgressDispatch", NULL);
        self.semaphore = dispatch_semaphore_create(0);
        
        if (!configuration) {
            configuration = [KVNProgressConfiguration defaultConfiguration];
        }
        
        _configuration = configuration;
        
        [self registerForNotifications];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationDidChange:(NSNotification *)notification {
    if (![self.class isVisible]) {
        return;
    }
    
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        KVNPrepareBlockSelf();
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [KVNBlockSelf updateUIForOrientation];
                         }];
    } else {
        [self updateUIForOrientation];
    }
}

#pragma mark - Loading

+ (void)show
{
    [self showWithStatus:nil];
}

+ (void)showWithStatus:(NSString *)status
{
    [self showWithStatus:status
                  onView:nil];
}

+ (void)showWithStatus:(NSString *)status
                onView:(UIView *)superview
{
    [self showHUDWithProgress:KVNProgressIndeterminate
                        style:KVNProgressStyleProgress
                       status:status
                    superview:superview
                   completion:nil];
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
                status:status
                onView:nil];
}

+ (void)showProgress:(CGFloat)progress
              status:(NSString *)status
              onView:(UIView *)superview
{
    [self showHUDWithProgress:progress
                        style:KVNProgressStyleProgress
                       status:status
                    superview:superview
                   completion:nil];
}

#pragma mark - Success

+ (void)showSuccess
{
    [self showSuccessWithStatus:nil];
}

+ (void)showSuccessWithCompletion:(KVNCompletionBlock)completion
{
    [self showSuccessWithStatus:nil
                     completion:completion];
}

+ (void)showSuccessWithStatus:(NSString *)status
{
    [self showSuccessWithStatus:status
                         onView:nil];
}

+ (void)showSuccessWithStatus:(NSString *)status
                   completion:(KVNCompletionBlock)completion
{
    [self showSuccessWithStatus:status
                         onView:nil
                     completion:completion];
}

+ (void)showSuccessWithStatus:(NSString *)status
                       onView:(UIView *)superview
{
    [self showSuccessWithStatus:status
                         onView:superview
                     completion:nil];
}

+ (void)showSuccessWithStatus:(NSString *)status
                       onView:(UIView *)superview
                   completion:(KVNCompletionBlock)completion
{
    [self showHUDWithProgress:KVNProgressIndeterminate
                        style:KVNProgressStyleSuccess
                       status:status
                    superview:superview
                   completion:completion];
}

#pragma mark - Error

+ (void)showError
{
    [self showErrorWithStatus:nil];
}

+ (void)showErrorWithCompletion:(KVNCompletionBlock)completion
{
    [self showErrorWithStatus:nil
                   completion:completion];
}

+ (void)showErrorWithStatus:(NSString *)status
{
    [self showErrorWithStatus:status
                       onView:nil];
}

+ (void)showErrorWithStatus:(NSString *)status
                 completion:(KVNCompletionBlock)completion
{
    [self showErrorWithStatus:status
                       onView:nil
                   completion:completion];
}

+ (void)showErrorWithStatus:(NSString *)status
                     onView:(UIView *)superview
{
    [self showErrorWithStatus:status
                       onView:superview
                   completion:nil];
}

+ (void)showErrorWithStatus:(NSString *)status
                     onView:(UIView *)superview
                 completion:(KVNCompletionBlock)completion
{
    [self showHUDWithProgress:KVNProgressIndeterminate
                        style:KVNProgressStyleError
                       status:status
                    superview:superview
                   completion:completion];
}

#pragma mark - Show

+ (void)showHUDWithProgress:(CGFloat)progress
                      style:(KVNProgressStyle)style
                     status:(NSString *)status
                  superview:(UIView *)superview
                 completion:(KVNCompletionBlock)completion
{
    [[self sharedView] showProgress:progress
                             status:status
                              style:style
                     backgroundType:configuration.backgroundType
                         fullScreen:configuration.fullScreen
                               view:superview
                         completion:completion];
}

- (void)showProgress:(CGFloat)progress
              status:(NSString *)status
               style:(KVNProgressStyle)style
      backgroundType:(KVNProgressBackgroundType)backgroundType
          fullScreen:(BOOL)fullScreen
                view:(UIView *)superview
          completion:(KVNCompletionBlock)completion
{
    KVNPrepareBlockSelf();
    
    dispatch_async(self.queue, ^{
        
        BOOL styleDidChange = self.style != style;
        
        // We're going to create a new HUD
        self.progress = progress;
        self.status = [status copy];
        self.style = style;
        self.backgroundType = backgroundType;
        self.fullScreen = fullScreen;
        
        switch (self.state) {
            case KVNProgressStateHidden: {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    KVNBlockSelf.state = KVNProgressStateAppearing;
                    
                    if (superview) {
                        [KVNBlockSelf addToView:superview];
                    } else {
                        [KVNBlockSelf addToCurrentWindow];
                    }
                    
                    [KVNBlockSelf setupUI];
                    [KVNBlockSelf animateUI];
                    [KVNBlockSelf animateAppearance];
                });
                
                // We need a strong reference to get the semaphore
                KVNProgress *strongSelf = KVNBlockSelf;
                
                // Wait until the ui animation end before we have appeared
                dispatch_semaphore_wait(strongSelf.semaphore, DISPATCH_TIME_FOREVER);
                
                strongSelf.state = KVNProgressStateShowed;
            }
                break;
                
            case KVNProgressStateAppearing:
            case KVNProgressStateDismissing: {
                // Should never see these states.
            }
                break;
                
            case KVNProgressStateShowed: {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:KVNLayoutAnimationDuration
                                     animations:^{
                                         [KVNBlockSelf setupUI];
                                     }];
                    
                    KVNBlockSelf.showActionTrigerredDate = [NSDate date];
                    [KVNBlockSelf animateUI];
                });
            }
                break;
                
            default:
                break;
        }
        
        if (styleDidChange) {
            NSTimeInterval delay;
            switch (self.style) {
                case KVNProgressStyleProgress:
                    delay = self.configuration.minimumDisplayTime;
                    break;
                case KVNProgressStyleSuccess:
                    delay = self.configuration.minimumSuccessDisplayTime;
                    break;
                case KVNProgressStyleError:
                    delay = self.configuration.minimumErrorDisplayTime;
                    break;
                case KVNProgressStyleHidden:
                    // Should not happen
                    delay = 0;
                    break;
            }
            
            // Ok, now wait for our minimum time
            [NSThread sleepForTimeInterval:delay];
            
            // If it's an auto-dismissable HUD
            switch (self.style) {
                case KVNProgressStyleProgress:
                    // Do nothing.
                    break;
                    
                case KVNProgressStyleSuccess:
                case KVNProgressStyleError: {
                    [KVNBlockSelf.class synchronousDismissWithCompletion:completion];
                }
                    break;
                    
                case KVNProgressStyleHidden:
                    // should never happen
                    break;
            }
        }
    });
}

#pragma mark - Dismiss

+ (void)dismiss
{
    [self dismissWithCompletion:nil];
}

/**
 Since this method synchronously dispatches to the main thread it
 can *not* be called from it. If it does, deadlock.
 */
+ (void)synchronousDismissWithCompletion:(KVNCompletionBlock)completion
{
    switch ([self sharedView].state) {
        case KVNProgressStateShowed: {
            [self sharedView].state = KVNProgressStateDismissing;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self dismissAnimatedWithCompletion:completion];
            });
            
            dispatch_semaphore_wait([self sharedView].semaphore, DISPATCH_TIME_FOREVER);
            
            [self sharedView].state = KVNProgressStateHidden;
        }
            break;
            
        case KVNProgressStateAppearing:
        case KVNProgressStateDismissing: {
            // Should not see these states.
        }
            break;
            
        case KVNProgressStateHidden: {
            // Do nothing
        }
            break;
            
        default:
            break;
    }
}

+ (void)dismissWithCompletion:(KVNCompletionBlock)completion
{
    dispatch_async([self sharedView].queue, ^{
        
        [self synchronousDismissWithCompletion:completion];
    });
}

+ (void)dismissAnimatedWithCompletion:(KVNCompletionBlock)completion
{
    KVNProgress *progressView = [self sharedView];
    
    NSTimeInterval timeIntervalSinceShow = fabs([progressView.showActionTrigerredDate timeIntervalSinceNow]);
    NSTimeInterval delay = 0;
    
    if (timeIntervalSinceShow < progressView.configuration.minimumDisplayTime) {
        // The hud hasn't showed enough time
        delay = progressView.configuration.minimumDisplayTime - timeIntervalSinceShow;
    }
    
    [UIView animateWithDuration:KVNFadeAnimationDuration
                          delay:delay
                        options:(UIViewAnimationOptionCurveEaseIn
                                 | UIViewAnimationOptionAllowUserInteraction
                                 | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         if ([self sharedView].state == KVNProgressStateDismissing) {
                             progressView.alpha = 0.0f;
                         }
                     } completion:^(BOOL finished) {
                         if(progressView.alpha == 0 || progressView.contentView.alpha == 0) {
                             [self endDismissWithCompletion:completion];
                         }
                     }];
}

+ (void)endDismissWithCompletion:(KVNCompletionBlock)completion
{
    KVNProgress *progressView = [self sharedView];
    
    if (progressView.state == KVNProgressStateDismissing) {
        [self sharedView].state = KVNProgressStateHidden;
        
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
    
    // Notify the dismiss block that the dismiss action is finished.
    dispatch_semaphore_signal(progressView.semaphore);
}

#pragma mark - UI

- (void)setupUI
{
    [self setupGestures];
    [self setupConstraints];
    [self setupCircleProgressView];
    [self setupStatus:self.status];
    [self setupBackground];
}

- (void)setupGestures
{
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:gestureRecognizer];
    }
    
    if (self.configuration.tapBlock) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTapBlock)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
}

- (void)setupConstraints
{
    CGRect bounds = [self correctedBounds];
    CGFloat statusInset = (self.status.length > 0) ? KVNContentViewWithStatusInset : KVNContentViewWithoutStatusInset;
    CGFloat contentWidth;
    
    if (!KVNSystemVersionGreaterOrEqual_iOS_8 && [self.superview isKindOfClass:UIWindow.class]) {
        self.transform = CGAffineTransformMakeRotation([self rotationForStatusBarOrientation]);
    } else {
        self.transform = CGAffineTransformIdentity;
    }
    
    if ([self isFullScreen]) {
        contentWidth = CGRectGetWidth(bounds) - (2 * KVNContentViewFullScreenModeLeadingAndTrailingSpaceConstraintConstant);
    } else {
        if (KVNIpad) {
            contentWidth = KVNAlertViewWidth;
        } else {
            contentWidth = CGRectGetWidth(bounds) - (2 * KVNContentViewNotFullScreenModeLeadingAndTrailingSpaceConstraintConstant);
            
            if (contentWidth > KVNAlertViewWidth) {
                contentWidth = KVNAlertViewWidth;
            }
        }
    }
    
    self.circleProgressViewTopToSuperViewConstraint.constant = statusInset;
    self.statusLabelBottomToSuperViewConstraint.constant = statusInset;
    self.contentViewWidthConstraint.constant = contentWidth;
    
    [self layoutIfNeeded];
}

- (void)setupCircleProgressView
{
    // Constraints
    self.circleProgressViewWidthConstraint.constant = self.configuration.circleSize;
    self.circleProgressViewHeightConstraint.constant = self.configuration.circleSize;
    
    [self layoutIfNeeded];
    
    // Circle shape
    self.circleProgressView.layer.cornerRadius = (self.configuration.circleSize / 2.0f);
    self.circleProgressView.layer.masksToBounds = YES;
    self.circleProgressView.backgroundColor = [UIColor clearColor];
    
    // Remove all previous added layers
    [self removeAllSubLayersOfLayer:self.circleProgressView.layer];
}

- (void)setupInfiniteCircle
{
    CGFloat radius = (self.configuration.circleSize / 2.0f);
    CGPoint center = CGPointMake(radius, radius);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:(radius - self.configuration.lineWidth)
                                                          startAngle:GLKMathDegreesToRadians(-45.0f)
                                                            endAngle:GLKMathDegreesToRadians(275.0f)
                                                           clockwise:YES];
    
    self.circleProgressLineLayer = [CAShapeLayer layer];
    self.circleProgressLineLayer.path = circlePath.CGPath;
    self.circleProgressLineLayer.strokeColor = self.configuration.circleStrokeForegroundColor.CGColor;
    self.circleProgressLineLayer.fillColor = self.configuration.circleFillBackgroundColor.CGColor;
    self.circleProgressLineLayer.lineWidth = self.configuration.lineWidth;
    
    [self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
    
    [self.circleProgressLineLayer removeAllAnimations];
    [self.circleProgressView.layer removeAllAnimations];
    [self animateCircleWithInfiniteLoop];
}

- (void)setupProgressCircle
{
    CGFloat radius = (self.configuration.circleSize / 2.0f);
    CGPoint center = CGPointMake(radius, radius);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:(radius - self.configuration.lineWidth)
                                                          startAngle:GLKMathDegreesToRadians(-90.0f)
                                                            endAngle:GLKMathDegreesToRadians(275.0f)
                                                           clockwise:YES];
    
    [self cancelCircleAnimation];
    
    self.circleProgressLineLayer = [CAShapeLayer layer];
    self.circleProgressLineLayer.path = circlePath.CGPath;
    self.circleProgressLineLayer.strokeColor = self.configuration.circleStrokeForegroundColor.CGColor;
    self.circleProgressLineLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleProgressLineLayer.lineWidth = self.configuration.lineWidth;
    
    self.circleBackgroundLineLayer = [CAShapeLayer layer];
    self.circleBackgroundLineLayer.path = circlePath.CGPath;
    self.circleBackgroundLineLayer.strokeColor = self.configuration.circleStrokeBackgroundColor.CGColor;
    self.circleBackgroundLineLayer.fillColor = self.configuration.circleFillBackgroundColor.CGColor;
    self.circleBackgroundLineLayer.lineWidth = self.configuration.lineWidth;
    
    [self.circleProgressView.layer addSublayer:self.circleBackgroundLineLayer];
    [self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
    
    [self.circleProgressLineLayer removeAllAnimations];
    [self.circleProgressView.layer removeAllAnimations];
    
    [self updateProgress:self.progress
                animated:NO];
}

- (void)setupSuccessUI
{
    [self setupFullRoundCircleWithColor:self.configuration.successColor];
    
    UIBezierPath* checkmarkPath = [UIBezierPath bezierPath];
    [checkmarkPath moveToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.28f, CGRectGetHeight(self.circleProgressView.bounds) * 0.53f)];
    [checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.42f, CGRectGetHeight(self.circleProgressView.bounds) * 0.66f)];
    [checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.72f, CGRectGetHeight(self.circleProgressView.bounds) * 0.36f)];
    checkmarkPath.lineCapStyle = kCGLineCapSquare;
    
    self.checkmarkLayer = [CAShapeLayer layer];
    self.checkmarkLayer.path = checkmarkPath.CGPath;
    self.checkmarkLayer.fillColor = nil;
    self.checkmarkLayer.strokeColor = self.configuration.successColor.CGColor;
    self.checkmarkLayer.lineWidth = self.configuration.lineWidth;
    
    [self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
    [self.circleProgressView.layer addSublayer:self.checkmarkLayer];
    
    [self.circleProgressLineLayer removeAllAnimations];
    [self.circleProgressView.layer removeAllAnimations];
    [self.checkmarkLayer removeAllAnimations];
    [self animateSuccess];
}

- (void)setupErrorUI
{
    [self setupFullRoundCircleWithColor:self.configuration.errorColor];
    
    UIBezierPath* crossPath = [UIBezierPath bezierPath];
    [crossPath moveToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.72f, CGRectGetHeight(self.circleProgressView.bounds) * 0.27f)];
    [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.27f, CGRectGetHeight(self.circleProgressView.bounds) * 0.72f)];
    [crossPath moveToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.27f, CGRectGetHeight(self.circleProgressView.bounds) * 0.27f)];
    [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(self.circleProgressView.bounds) * 0.72f, CGRectGetHeight(self.circleProgressView.bounds) * 0.72f)];
    crossPath.lineCapStyle = kCGLineCapSquare;
    
    self.crossLayer = [CAShapeLayer layer];
    self.crossLayer.path = crossPath.CGPath;
    self.crossLayer.fillColor = nil;
    self.crossLayer.strokeColor = self.configuration.errorColor.CGColor;
    self.crossLayer.lineWidth = self.configuration.lineWidth;
    
    [self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
    [self.circleProgressView.layer addSublayer:self.crossLayer];
    
    [self.circleProgressLineLayer removeAllAnimations];
    [self.circleProgressView.layer removeAllAnimations];
    [self.crossLayer removeAllAnimations];
    [self animateError];
}

- (void)setupFullRoundCircleWithColor:(UIColor *)color
{
    CGFloat radius = (self.configuration.circleSize / 2.0f);
    CGPoint center = CGPointMake(radius, radius);
    
    // Circle
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:(radius - self.configuration.lineWidth)
                                                          startAngle:GLKMathDegreesToRadians(-90.0f)
                                                            endAngle:GLKMathDegreesToRadians(275.0f)
                                                           clockwise:YES];
    
    self.circleProgressLineLayer = [CAShapeLayer layer];
    self.circleProgressLineLayer.path = circlePath.CGPath;
    self.circleProgressLineLayer.strokeColor = color.CGColor;
    self.circleProgressLineLayer.fillColor = self.configuration.circleFillBackgroundColor.CGColor;
    self.circleProgressLineLayer.lineWidth = self.configuration.lineWidth;
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
    self.statusLabel.textColor = self.configuration.statusColor;
    self.statusLabel.font = self.configuration.statusFont;
    self.statusLabel.hidden = !showStatus;
    
    [self updateStatusConstraints];
}

- (void)setupBackground
{
    if ([self.class isVisible]) {
        return; // No reload of background when view is showing
    }
    
    [self updateBackground];
    
    KVNPrepareBlockSelf();
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [KVNBlockSelf setupMotionEffect];
    });
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
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"self" : self}];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"self" : self}];
    
    self.constraintsToSuperview = [verticalConstraints arrayByAddingObjectsFromArray:horizontalConstraints];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [superview addConstraints:verticalConstraints];
    [superview addConstraints:horizontalConstraints];
    
    [self layoutIfNeeded];
    
    self.alpha = 0.0f;
}

#pragma mark - Update

- (void)updateUIForOrientation
{
    [self setupConstraints];
    [self updateStatusConstraints];
    [self updateBackgroundConstraints];
}

- (void)updateBackground
{
    UIImage *backgroundImage = nil;
    UIColor *backgroundColor = nil;
    
    switch (self.backgroundType) {
        case KVNProgressBackgroundTypeSolid:
            backgroundImage = [UIImage emptyImage];
            backgroundColor = self.configuration.backgroundFillColor;
            break;
        case KVNProgressBackgroundTypeBlurred:
            backgroundImage = [self blurredScreenShot];
            backgroundColor = [UIColor clearColor];
            break;
    }
    
    if (!KVNSystemVersionGreaterOrEqual_iOS_8
        && !CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity))
    {
        CIImage *transformedCIImage = backgroundImage.CIImage;
        
        if (!transformedCIImage) {
            transformedCIImage = [CIImage imageWithCGImage:backgroundImage.CGImage];
        }
        
        transformedCIImage = [transformedCIImage imageByApplyingTransform:self.transform];
        backgroundImage = [UIImage imageWithCIImage:transformedCIImage];
    }
    
    [self updateBackgroundConstraints];
    
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
        self.backgroundImageView.image = [UIImage emptyImage];
        self.backgroundImageView.backgroundColor = [UIColor colorWithWhite:0.0f
                                                                     alpha:0.35f];
        
        self.contentView.layer.cornerRadius = (self.status) ? KVNContentViewCornerRadius : KVNContentViewWithoutStatusCornerRadius;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.contentMode = UIViewContentModeCenter;
        self.contentView.backgroundColor = self.configuration.backgroundFillColor;
        
        self.contentView.image = backgroundImage;
    }
}

- (void)updateBackgroundConstraints
{
    if (![self isFullScreen] && self.status.length == 0) {
        self.circleProgressViewTopToSuperViewConstraint.constant = KVNContentViewWithoutStatusInset;
        self.statusLabelBottomToSuperViewConstraint.constant = KVNContentViewWithoutStatusInset;
        
        // We sets the width as the height to have a square
        CGSize fittingSize = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.contentViewWidthConstraint.constant = fittingSize.height;
    }
}

+ (void)updateStatus:(NSString*)status
{
    dispatch_async([self sharedView].queue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[self sharedView] updateStatus:status];
        });
    });
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

- (void)updateStatusConstraints
{
    BOOL showStatus = (self.status.length > 0);
    
    self.circleProgressViewToStatusLabelVerticalSpaceConstraint.constant = (showStatus) ? KVNCircleProgressViewToStatusLabelVerticalSpaceConstraintConstant : 0.0f;
    
    CGSize maximumLabelSize = CGSizeMake(CGRectGetWidth(self.statusLabel.bounds), CGFLOAT_MAX);
    CGSize statusLabelSize = [self.statusLabel sizeThatFits:maximumLabelSize];
    self.statusLabelHeightConstraint.constant = statusLabelSize.height;
    
    [self layoutIfNeeded];
}

+ (void)updateProgress:(CGFloat)progress
              animated:(BOOL)animated
{
    dispatch_async([self sharedView].queue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[self sharedView] updateProgress:progress
                                     animated:animated];
        });
    });
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
                      view:self.superview
                completion:nil];
        
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
    
    KVNPrepareBlockSelf();
    [UIView animateWithDuration:KVNFadeAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         KVNBlockSelf.alpha = 1.0f;
                         KVNBlockSelf.contentView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                         UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, KVNBlockSelf.status);
                         
                         // Notify the show block that the appearance animation is completed.
                         KVNProgress *strongSelf = KVNBlockSelf;
                         if (strongSelf) {
                             dispatch_semaphore_signal(strongSelf.semaphore);
                         }
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
    [self animateFullCircleWithColor:self.configuration.successColor];
    
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
    [self animateFullCircleWithColor:self.configuration.errorColor];
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
    
    blurredScreenShot = [self applyTintEffectWithColor:self.configuration.backgroundTintColor
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

- (CGFloat)rotationForStatusBarOrientation {
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return -M_PI_2;
        case UIInterfaceOrientationLandscapeRight:
            return M_PI_2;
        case UIInterfaceOrientationPortraitUpsideDown:
            return M_PI;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationUnknown:
            return 0;
    }
}

- (CGRect)correctedBounds
{
    return [self correctedBoundsForBounds:self.bounds];
}

- (CGRect)correctedBoundsForBounds:(CGRect)boundsToCorrect
{
    CGRect bounds = (CGRect){CGPointZero, boundsToCorrect.size};
    
    if (!KVNSystemVersionGreaterOrEqual_iOS_8 && [self.superview isKindOfClass:UIWindow.class])
    {
        // landscape orientation but width is smaller than height
        // or portrait orientation but width is larger than height
        if ((UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
             && CGRectGetWidth(bounds) < CGRectGetHeight(bounds))
            || (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
                && CGRectGetWidth(bounds) > CGRectGetHeight(bounds))) {
                bounds = (CGRect){CGPointZero, {bounds.size.height, bounds.size.width}};
            }
    }
    
    return bounds;
}

#pragma mark - Configuration

+ (KVNProgressConfiguration *)configuration
{
    return configuration;
}

+ (void)setConfiguration:(KVNProgressConfiguration *)newConfiguration
{
    configuration = newConfiguration;
    [self sharedView].configuration = configuration;
}

#pragma mark - Information

- (BOOL)isIndeterminate
{
    return (self.progress == KVNProgressIndeterminate);
}

+ (BOOL)isVisible
{
    return ([self sharedView].superview != nil && [self sharedView].alpha > 0.0f);
}

#pragma mark - Tap Block

- (void)performTapBlock {
    if (self.configuration.tapBlock) {
        KVNPrepareBlockSelf();
        self.configuration.tapBlock(KVNBlockSelf);
    }
}

#pragma mark - HitTest

// Used to block interaction for all views behind
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.configuration.allowUserInteraction && ![self isFullScreen]) {
        return nil;
    } else {
        return (CGRectContainsPoint(self.frame, point)) ? self : nil;
    }
}

@end