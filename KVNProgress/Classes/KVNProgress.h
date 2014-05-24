//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

@import UIKit;

@interface KVNProgress : UIView

#pragma mark - Appearance

@property (nonatomic) UIColor *backgroundTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *loaderForegroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *loaderBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *statusColor UI_APPEARANCE_SELECTOR;

#pragma mark - Progress methods

+ (void)showProgress NS_AVAILABLE_IOS(6_0);
+ (void)showProgressWithStatus:(NSString *)status NS_AVAILABLE_IOS(6_0);
+ (void)hideProgress NS_AVAILABLE_IOS(6_0);

@end
