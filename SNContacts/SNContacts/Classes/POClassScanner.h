//
//  POClassAnalyst.h
//  SNContacts
//
//  Created by Sergey Sergeev on 11/30/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POPropertyMetaData  : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSArray* attributes;

@end

@interface POMethodMetaData : NSObject

@property (strong, nonatomic) NSString* signature;
@property (strong, nonatomic) NSString* returnValue;

@end

@interface POProtocolMetaData : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSArray* properties;
@property (strong, nonatomic) NSArray* methods;

@end

@interface POClassMetaData : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* superClassName;
@property (strong, nonatomic) NSArray* protocols;
@property (strong, nonatomic) NSArray* properties;
@property (strong, nonatomic) NSArray* classMethods;
@property (strong, nonatomic) NSArray* instanceMethods;

@end


@interface POClassScanner : NSObject

+ (POClassScanner*)sharedInstance;

- (void)scanWithPredicate:(NSPredicate*)predicate;


@end
