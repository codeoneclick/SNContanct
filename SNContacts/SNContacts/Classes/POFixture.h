//
//  POFixture.h
//  SNContacts
//
//  Created by Sergey Sergeev on 11/12/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POFixture;

@protocol POFixtureDelegate <NSObject>

- (void)onFixtureChanged:(POFixture*)fixture;

@end

@interface POFixture : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) id content;
@property (nonatomic, assign)   id<POFixtureDelegate> delegate;

- (id)initWithName:(NSString*)name;

@end
