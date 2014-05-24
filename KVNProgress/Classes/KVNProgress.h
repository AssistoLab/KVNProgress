//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVNProgress : NSObject

+ (void)showProgress NS_AVAILABLE_IOS(6_0);
+ (void)showProgressWithStatus:(NSString *)status NS_AVAILABLE_IOS(6_0);

@end
