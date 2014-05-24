//
//  KVNProgress.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

#import "KVNProgress.h"

@interface KVNProgress ()

@property (nonatomic) UILabel *statusLabel;

@end

@implementation KVNProgress

#pragma mark - Life cycle

- (instancetype)init
{
    if (self = [super init]) {
        _statusLabel = [[UILabel alloc] init];
    }
	
    return self;
}

- (void)dealloc
{
	_statusLabel = nil;
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

#pragma mark - Private progress methods

- (void)showProgressWithStatus:(NSString *)status
{
	// Status
	BOOL showStatus = (status.length > 0);
	
	if (showStatus) {
		self.statusLabel.text = nil;
	}
	
	self.statusLabel.hidden = !showStatus;
}

#pragma mark - Manager

+ (KVNProgress *)progressManager
{
	static KVNProgress *progressManager = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		progressManager = [[KVNProgress alloc] init];
	});
	
	return progressManager;
}

@end
