//
//  KVNProgress.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

#import "KVNProgress.h"

#import "UIImage+ImageEffects.h"

static CGFloat const KVNFadeAnimationDuration = 0.3f;

@interface KVNProgress ()

// UI
@property (nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation KVNProgress

#pragma mark - Life cycle

- (instancetype)init
{
    if (self = [super init]) {
		// Appearance
		_backgroundTintColor = [UIColor whiteColor];
		_loaderForegroundColor = [UIColor darkGrayColor];
		_loaderBackgroundColor = [UIColor clearColor];
		_statusColor = [UIColor blackColor];
    }
	
    return self;
}

- (void)dealloc
{
	_statusLabel = nil;
}

#pragma mark - UIView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_statusLabel.textColor = _statusColor;
	_backgroundImageView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Public progress methods

+ (void)showProgress
{
	[self showProgressWithStatus:nil];
}

+ (void)showProgressWithStatus:(NSString *)status
{
	[[self progressManager] showProgressWithStatus:status];
}

+ (void)hideProgress
{
	KVNProgress *progressView = [self progressManager];
	
	[UIView animateWithDuration:KVNFadeAnimationDuration
					 animations:^{
						 progressView.alpha = 0.0f;
					 } completion:^(BOOL finished) {
						[progressView removeFromSuperview];
					 }];
}

#pragma mark - Private progress methods

- (void)showProgressWithStatus:(NSString *)status
{
	[self updateStatus:status];
	[self updateBackground];
	
	[self addViewToViewHierarchyIfNeeded];
}

#pragma mark - UI

- (void)updateStatus:(NSString *)status
{
	BOOL showStatus = (status.length > 0);
	
	if (showStatus) {
		self.statusLabel.text = status;
	}
	
	self.statusLabel.hidden = !showStatus;
}

- (void)updateBackground
{
	self.backgroundImageView.image = [self blurredScreenShot];
}

- (void)addViewToViewHierarchyIfNeeded
{
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	
	if (![self isVisible]) {
		[keyWindow addSubview:self];
		self.alpha = 0.0f;
		
		[UIView animateWithDuration:KVNFadeAnimationDuration
						 animations:^{
							 self.alpha = 1.0f;
						 }];
	}
	
	[keyWindow bringSubviewToFront:self];
}

#pragma mark - Helpers

- (UIImage *)blurredScreenShot
{
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	
	UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, NO, 0);
	
	[keyWindow drawViewHierarchyInRect:keyWindow.bounds afterScreenUpdates:NO];
	UIImage *blurredScreenShot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	blurredScreenShot = [blurredScreenShot applyTintEffectWithColor:self.backgroundTintColor];
	
	return blurredScreenShot;
}

#pragma mark - Getters

- (BOOL)isVisible
{
	return (self.superview != nil);
}

#pragma mark - Manager

+ (KVNProgress *)progressManager
{
	static KVNProgress *progressManager = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		UINib *nib = [UINib nibWithNibName:@"KVNProgressView"
							 bundle:nil];
		NSArray *nibViews = [nib instantiateWithOwner:self
											  options:kNilOptions];
		
		progressManager = nibViews[0];
	});
	
	return progressManager;
}

@end
