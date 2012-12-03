//
//  POClassAnalyst.m
//  SNContacts
//
//  Created by Sergey Sergeev on 11/30/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "POClassScanner.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PORuntimeDecoder.h"

extern const struct POClassKeys
{
    __unsafe_unretained NSString* className;
    __unsafe_unretained NSString* superClassName;
    __unsafe_unretained NSString* properties;
    __unsafe_unretained NSString* classMethods;
    __unsafe_unretained NSString* instanceMethods;
    __unsafe_unretained NSString* protocols;
    __unsafe_unretained NSString* protocolName;
    __unsafe_unretained NSString* protocolProperties;
    __unsafe_unretained NSString* protocolMandatoryMethods;
    __unsafe_unretained NSString* protocolOptionalMethods;

} POClassKeys;

const struct POClassKeys POClassKeys =
{
    .className = @"class_name", 
    .superClassName = @"super_class_name",
    .properties = @"properties",
    .classMethods = @"class_methods",
    .instanceMethods = @"instance_methods",
    .protocols = @"protocols",
    .protocolName = @"protocol_name",
    .protocolProperties = @"protocol_properties",
    .protocolMandatoryMethods = @"protocol_mandatory_methods",
    .protocolOptionalMethods = @"protocol_optional_methods",
};

@implementation POPropertyMetaData


@end

@implementation POMethodMetaData

- (NSString*)description
{
    return [NSString stringWithFormat:@"POMethodMetaData: \n method signature %@ \n", self.signature];
}

@end

@implementation POProtocolMetaData

@end

@implementation POClassMetaData

- (NSString*)description
{
    NSString* propertiesDescription = @"";
    for(POPropertyMetaData* property in self.properties)
    {
        propertiesDescription = [NSString stringWithFormat:@"%@%@", propertiesDescription, [property description]];
    }

    NSString* classMethodDescription = @"";
    for(POMethodMetaData* method in self.classMethods)
    {
        classMethodDescription = [NSString stringWithFormat:@"%@%@", classMethodDescription, [method description]];
    }

    NSString* instanceMethodDescription = @"";
    for(POMethodMetaData* method in self.instanceMethods)
    {
        instanceMethodDescription = [NSString stringWithFormat:@"%@%@", instanceMethodDescription, [method description]];
    }
   
    return [NSString stringWithFormat:@"POClassMetaData: \n class name %@ \n super class name %@ \n%@ \n%@ \n%@", self.name, self.superClassName, propertiesDescription, classMethodDescription, instanceMethodDescription];
}

@end


@interface POClassScanner()

@property (strong, nonatomic) NSDictionary* result;

@end

@implementation POClassScanner

+ (POClassScanner*)sharedInstance
{
    static POClassScanner *instance = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        instance = [self new];
    });

    return instance;
}

- (void)scanWithPredicate:(NSPredicate *)predicate
{
    int numClasses;
    Class *classes = NULL;

    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);

    NSMutableArray *classList = [NSMutableArray new];
    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {

            [classList addObject: [NSString stringWithCString:class_getName(classes[i]) encoding:NSStringEncodingConversionAllowLossy]];
        }
        free(classes);
        [classList filterUsingPredicate:predicate];
    }

    NSMutableArray* metaData = [NSMutableArray new];

    for(NSString* className in classList)
    {
        Class __class = objc_getClass([className UTF8String]);
        POClassMetaData* classMetaData = [POClassMetaData new];
        classMetaData.name = [NSString stringWithCString:class_getName(__class) encoding:NSStringEncodingConversionAllowLossy];
        Class __superClass = class_getSuperclass(__class);
        classMetaData.superClassName = [NSString stringWithCString:class_getName(__superClass) encoding:NSStringEncodingConversionAllowLossy];

        NSMutableArray* propertiesMetaDataList = [NSMutableArray new];
        unsigned int numProperties;
        objc_property_t *properties = class_copyPropertyList(__class, &numProperties);
        for(int i = 0; i < numProperties; ++i)
        {
            objc_property_t property = properties[i];
            POPropertyMetaData* propertyMetaData = [POPropertyMetaData new];
            
            if(property_getName(property))
            {
                propertyMetaData.name = [NSString stringWithCString:property_getName(property) encoding:NSStringEncodingConversionAllowLossy];
                propertyMetaData.attributes = decode_property(property);
            }
            
            [propertiesMetaDataList addObject:propertyMetaData];
        }
        free(properties);
        classMetaData.properties = [NSArray arrayWithArray:propertiesMetaDataList];

        unsigned int numInstanceMethods = 0;
        Method* instanceMethods = class_copyMethodList(__class, &numInstanceMethods);

        NSMutableArray* instanceMethodsMetaDataList = [NSMutableArray new];
        for(int i = 0; i < numInstanceMethods; ++i)
        {
            NSString* methodSignature = NSStringFromSelector(method_getName(instanceMethods[i]));
            BOOL isGetterSetterMethod = NO;
            for(POPropertyMetaData* propertyMetaData in classMetaData.properties)
            {
                if ([[methodSignature lowercaseString] rangeOfString:[propertyMetaData.name lowercaseString]].location != NSNotFound)
                {
                    isGetterSetterMethod = YES;
                    break;
                }
            }

            if(isGetterSetterMethod == YES || [methodSignature rangeOfString:@".cxx_destruct"].location != NSNotFound)
            {
                continue;
            }
            
            POMethodMetaData* methodMetaData = [POMethodMetaData new];
            methodMetaData.signature = decode_method_signature(instanceMethods[i]);
            [instanceMethodsMetaDataList addObject:methodMetaData];
        }
        free(instanceMethods);

        unsigned int numClassMethods = 0;
        Method* classMethods = class_copyMethodList(object_getClass(__class), &numClassMethods);

        NSMutableArray* classMethodsMetaDataList = [NSMutableArray new];
        for(int i = 0; i < numClassMethods; ++i)
        {
            POMethodMetaData* methodMetaData = [POMethodMetaData new];
            methodMetaData.signature = decode_method_signature(classMethods[i]);
            [classMethodsMetaDataList addObject:methodMetaData];

        }
        free(classMethods);

        classMetaData.instanceMethods = [NSArray arrayWithArray:instanceMethodsMetaDataList];
        classMetaData.classMethods = [NSArray arrayWithArray:classMethodsMetaDataList];

        unsigned int numProtocols;
        __unsafe_unretained Protocol **protocols = class_copyProtocolList(object_getClass(__class), &numProtocols);

        NSMutableArray* protocolsMetaDataList = [NSMutableArray new];
        for (int i = 0; i < numProtocols; ++i)
        {
            Protocol *protocol = *(protocols + i);
            POProtocolMetaData* protocolMetaData = [POProtocolMetaData new];
            protocolMetaData.name = [NSString stringWithCString:protocol_getName(protocol) encoding:NSStringEncodingConversionAllowLossy];

            unsigned int numMandatoryMethods = 0;
            struct objc_method_description* mandatoryMethods = protocol_copyMethodDescriptionList(protocol, YES, YES, &numMandatoryMethods);

            NSMutableArray* mandatoryMethodsMetaDataList = [NSMutableArray new];
            for(int i = 0; i < numMandatoryMethods; ++i)
            {
                POMethodMetaData* methodMetaData = [POMethodMetaData new];
                methodMetaData.signature = NSStringFromSelector(mandatoryMethods[i].name);
                [mandatoryMethodsMetaDataList addObject:methodMetaData];
            }

            unsigned int numOptionalMethods = 0;
            struct objc_method_description* optionalMethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &numOptionalMethods);

            NSMutableArray* optionalMethodsMetaDataList = [NSMutableArray new];
            for(int i = 0; i < numOptionalMethods; ++i)
            {
                POMethodMetaData* methodMetaData = [POMethodMetaData new];
                methodMetaData.signature = NSStringFromSelector(optionalMethods[i].name);
                [optionalMethodsMetaDataList addObject:methodMetaData];
            }

            protocolMetaData.mandatoryMethods = mandatoryMethodsMetaDataList;
            protocolMetaData.optionalMethods = optionalMethodsMetaDataList;
            [protocolsMetaDataList addObject:protocolMetaData];
        }
        free(protocols);

        classMetaData.protocols = protocolsMetaDataList;

        [metaData addObject:classMetaData];

    }

    NSMutableDictionary* classesToJson = [NSMutableDictionary new];
    NSMutableArray* classesList = [NSMutableArray new];
    for(POClassMetaData* classMetaData in metaData)
    {
        NSMutableArray* classMethods = [NSMutableArray new];
        for(POMethodMetaData* methodMetaData in classMetaData.classMethods)
        {
            [classMethods addObject:[NSString stringWithFormat:@"+ %@;", methodMetaData.signature]];
        }

        NSMutableArray* instanceMethods = [NSMutableArray new];
        for(POMethodMetaData* methodMetaData in classMetaData.instanceMethods)
        {
            [instanceMethods addObject:[NSString stringWithFormat:@"- %@;", methodMetaData.signature]];
        }

        NSMutableArray* properties = [NSMutableArray new];
        for(POPropertyMetaData* propertyMetaData in classMetaData.properties)
        {
            [properties addObject:[NSString stringWithFormat:@"%@ %@", propertyMetaData.attributes, propertyMetaData.name]];
        }

        NSMutableArray* protocols = [NSMutableArray new];
        for(POProtocolMetaData* protocolMetaData in classMetaData.protocols)
        {
            NSMutableArray* mandatoryMethods = [NSMutableArray new];
            for(POMethodMetaData* methodMetaData in protocolMetaData.mandatoryMethods)
            {
                [mandatoryMethods addObject:[NSString stringWithFormat:@"- (void) %@;", methodMetaData.signature]];
            }

            NSMutableArray* optionalMethods = [NSMutableArray new];
            for(POMethodMetaData* methodMetaData in protocolMetaData.optionalMethods)
            {
                [optionalMethods addObject:[NSString stringWithFormat:@"- (void) %@;", methodMetaData.signature]];
            }
            
            NSDictionary* protocolToJson = [NSDictionary dictionaryWithObjectsAndKeys:
                                            protocolMetaData.name, POClassKeys.protocolName,
                                            mandatoryMethods, POClassKeys.protocolMandatoryMethods,
                                            optionalMethods, POClassKeys.protocolOptionalMethods,
                                            nil];
            [protocols addObject:protocolToJson];
        }
        
        NSDictionary* classToJson = [NSDictionary dictionaryWithObjectsAndKeys:
                                     classMetaData.name, POClassKeys.className,
                                     classMetaData.superClassName, POClassKeys.superClassName,
                                     classMethods, POClassKeys.classMethods,
                                     instanceMethods, POClassKeys.instanceMethods,
                                     properties, POClassKeys.properties,
                                     protocols, POClassKeys.protocols,
                                     nil];
        
        [classesList addObject:classToJson];
    }

    [classesToJson setObject:classesList forKey:@"classes"];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:classesToJson options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
}

@end
