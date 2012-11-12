//
//  SNFixtureSharedStorage.m
//  SNContacts
//
//  Created by Sergey Sergeev on 11/12/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "SNFixtureSharedStorage.h"
#import "POFixture.h"

@interface SNFixtureSharedStorage()<POFixtureDelegate>

@property (nonatomic, readonly) NSBundle* bundle;

@end

@implementation SNFixtureSharedStorage

+ (SNFixtureSharedStorage*)sharedInstance
{
    static SNFixtureSharedStorage* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SNFixtureSharedStorage new];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        if (TARGET_IPHONE_SIMULATOR)
        {
            NSString* path = [[NSBundle mainBundle] pathForResource:@"fixtures" ofType:@"plist"];
            NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
            _bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@", [plist objectForKey:@"FIXTURE_PATH"]]];
        }
        else
        {
            NSString* path = [[NSBundle mainBundle] pathForResource:@"fixtures" ofType:@"bundle"];
            _bundle = [NSBundle bundleWithPath:path];
        }

        NSAssert(_bundle != nil, @"Cannot load bundle");

        _storage = [NSMutableDictionary new];
        NSArray* paths = [_bundle pathsForResourcesOfType:@"json" inDirectory:nil];
        for (NSString* fixtureName in paths)
        {
            POFixture* fixture = [[POFixture alloc] initWithName:fixtureName];
            fixture.delegate = self;
            [_storage setObject:fixture forKey:fixture.name];
        }
    }
    return self;
}

- (void)onFixtureChanged:(POFixture *)fixture
{
    [self.storage setObject:fixture forKey:fixture.name];
    [self.delegate onFixtureChanged:self];
}

@end
