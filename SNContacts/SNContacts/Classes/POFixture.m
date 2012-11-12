//
//  POFixture.m
//  SNContacts
//
//  Created by Sergey Sergeev on 11/12/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "POFixture.h"
#import "POBundleGuard.h"

@interface POFixture()<POBundleGuardProtocol>

@property (nonatomic, strong) POBundleGuard* guard;

@end

@implementation POFixture

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        self.guard = [[POBundleGuard alloc] initWithName:name];
        self.guard.delegate = self;
        _name = name;
        _content = [NSString stringWithContentsOfFile:name encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (void)onContentChanged:(POBundleGuard *)bundleGuard
{
    _content = [NSString stringWithContentsOfFile:self.name encoding:NSUTF8StringEncoding error:nil];
    [self.delegate onFixtureChanged:self];
}

@end
