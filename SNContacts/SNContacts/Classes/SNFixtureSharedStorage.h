//
//  SNFixtureSharedStorage.h
//  SNContacts
//
//  Created by Sergey Sergeev on 11/12/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFixtureTest @"/Users/sergey.sergeev/Documents/Hobby/SNContact/SNContanct/SNContacts/fixtures.bundle/fixture.json"

@class SNFixtureSharedStorage;
@protocol SNFixtureSharedStorageProtocol <NSObject>

- (void)onFixtureChanged:(SNFixtureSharedStorage*)fixtureStorage;

@end


@interface SNFixtureSharedStorage : NSObject

@property(nonatomic, readonly) NSMutableDictionary* storage;
@property(nonatomic, assign) id<SNFixtureSharedStorageProtocol> delegate;

+ (SNFixtureSharedStorage*)sharedInstance;

@end
