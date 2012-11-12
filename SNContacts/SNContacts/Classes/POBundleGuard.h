//
//  POBundleGuard.h
//
//  Created by Sergey Sergeev on 10/3/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POBundleGuard;
@protocol POBundleGuardProtocol <NSObject>

- (void)onContentChanged:(POBundleGuard*)bundleGuard;

@end

@interface POBundleGuard : NSObject

@property (nonatomic, weak) id<POBundleGuardProtocol> delegate;

- (id)initWithName:(NSString*)name;

@end
