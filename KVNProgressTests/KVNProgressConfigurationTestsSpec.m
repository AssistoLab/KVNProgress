//
//  KVNProgressConfigurationTestsSpec.m
//  KVNProgress
//
//  Created by Louis Tur on 4/18/15.
//  Copyright 2015 Pinch. All rights reserved.
//

#import "Specta.h"
#import <Expecta/Expecta.h>
#import "KVNProgressConfiguration.h"


SpecBegin(KVNProgressConfigurationTests)

describe(@"defaultConfiguration", ^{
    __block KVNProgressConfiguration *testConfiguration;
    
    it(@"Default configuration should not return nil instance", ^{
        testConfiguration = [KVNProgressConfiguration defaultConfiguration];
        
        expect(testConfiguration).toNot.beNil;
    });

});

describe(@"default properties should not be nil", ^{
    
    __block KVNProgressConfiguration *testConfiguration;
    beforeAll(^{
        testConfiguration = [KVNProgressConfiguration defaultConfiguration];
    });
    
    it(@"Should have it's default color and size properties set", ^{
        
        expect(testConfiguration.backgroundFillColor).to.equal ([UIColor colorWithWhite:1.0f alpha:0.85f]);
        
        expect(testConfiguration.backgroundType).to.equal(KVNProgressBackgroundTypeBlurred);
        
        expect(testConfiguration.circleStrokeForegroundColor).to.equal([UIColor darkGrayColor]);
        
        expect(testConfiguration.circleStrokeBackgroundColor).to.equal([testConfiguration.circleStrokeForegroundColor colorWithAlphaComponent:0.3f]);
        
        expect(testConfiguration.circleFillBackgroundColor).to.equal([UIColor clearColor]);
        
        expect(testConfiguration.circleSize).to.beGreaterThan(0.0);
    });
    
    it(@"Should have minimum values for HUD display times", ^{
        expect(testConfiguration.minimumDisplayTime).to.beGreaterThan(0.0);
        expect(testConfiguration.minimumErrorDisplayTime).to.beGreaterThan(0.0);
        expect(testConfiguration.minimumSuccessDisplayTime).to.beGreaterThan(0.0);
    });
    
    it(@"Should not be fullscreen", ^{
        expect(testConfiguration.fullScreen).to.beFalsy;
    });
    
    it(@"Should not allow user interaction", ^{
        expect(testConfiguration.allowUserInteraction).to.beFalsy;
    });
});

describe(@"Should have a different address than its copy", ^{
    
    __block KVNProgressConfiguration *testConfiguration;
    __block KVNProgressConfiguration *testConfigurationCopy;
    beforeAll(^{
        testConfiguration = [KVNProgressConfiguration defaultConfiguration];
        testConfigurationCopy = testConfiguration.copy;
    });
    
    it(@"Should not have the same memory address", ^{
        expect(testConfiguration).toNot.beIdenticalTo(testConfigurationCopy);
    });
    
    it(@"Should have the same values for its properties", ^{
        
        expect(testConfiguration.backgroundFillColor).to.equal(testConfigurationCopy.backgroundFillColor);
        expect(testConfigurationCopy.backgroundTintColor).to.equal(testConfigurationCopy.backgroundTintColor);
    });
    
});

SpecEnd
