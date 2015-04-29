//
//  KVNProgressTests.m
//  KVNProgressTests
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>

#import "KVNProgress.h"

SpecBegin(KVNProgress)

describe(@"appearance", ^{

    beforeEach(^{
        waitUntil(^(DoneCallback done) {
            if ([KVNProgress isVisible]) {
                [KVNProgress dismissWithCompletion:^{
                    done();
                }];
            } else {
                done();
            }
        });
    });

    it(@"shows the basic progress view", ^{
        [KVNProgress show];
        expect([KVNProgress isVisible]).after(1).to.beTruthy();
    });

    it(@"shows then hides the basic progress view", ^{
        [KVNProgress show];
        expect([KVNProgress isVisible]).after(1).to.beTruthy();
        [KVNProgress dismiss];
        expect([KVNProgress isVisible]).after(1).to.beFalsy();
    });

    it(@"shows progress and status", ^{
        // TODO
//        [KVNProgress showProgress:0.50 status:@"Testing"];
//        UIView *v = [[UIApplication sharedApplication] keyWindow];
//        expect(v).after(3).to.recordSnapshot();
//        expect(v).after(3).to.haveValidSnapshot();
    });
});


describe(@"notifications", ^{

    it(@"calls the tap handler when the KVNProgress is tapped", ^{

        [KVNProgress setConfiguration:[KVNProgressConfiguration defaultConfiguration]];
        KVNProgressConfiguration *configuration = [KVNProgressConfiguration defaultConfiguration];
        configuration.tapBlock = ^(KVNProgress *progressView) {
            // TODO
        };

        [KVNProgress show];
    });
});

describe(@"can be customised via KVNProgressConfiguration", ^{
    // TODO
});


SpecEnd