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

extern const struct POClassKeys
{
    __unsafe_unretained NSString* className;
    __unsafe_unretained NSString* superClassName;
    __unsafe_unretained NSString* properties;
    __unsafe_unretained NSString* classMethods;
    __unsafe_unretained NSString* instanceMethods;

} POClassKeys;

const struct POClassKeys POClassKeys =
{
    .className = @"class_name", 
    .superClassName = @"super_class_name",
    .properties = @"properties",
    .classMethods = @"class_methods",
    .instanceMethods = @"instance_methods",
};

static NSString* property_getType(objc_property_t property)
{
    @try
    {
        const char *attributes = property_getAttributes(property);
        char buffer[1 + strlen(attributes)];
        strcpy(buffer, attributes);
        char *state = buffer, *attribute;
        while ((attribute = strsep(&state, ",")) != NULL)
        {
            if (attribute[0] == 'T' && attribute[1] != '@')
            {
                NSString* result = [NSString stringWithFormat:@"%s", [[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes]];
                return result;
            }
            else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2)
            {
                return @"id";
            }
            else if (attribute[0] == 'T' && attribute[1] == '@')
            {
                NSString* result = [NSString stringWithFormat:@"%s", [[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes]];
                if ([result rangeOfString:@"<"].location != NSNotFound)
                {
                    result = [NSString stringWithFormat:@"id%@", result];
                }
                return result;
            }
        }
        return @"";
    }
    @catch (NSException *exception)
    {
        return @"";
    }
    @finally
    {
        
    }
}

const char * property_getRetentionMethod( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return (NULL);

    NSString* attributes = [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding];
    NSString* result = @"";
    if ([attributes rangeOfString:@",N,"].location != NSNotFound)
    {
        result = [NSString stringWithFormat:@"%@nonatomic", result];
    }
    else
    {
        result = [NSString stringWithFormat:@"%@atomic", result];
    }
    
    if ([attributes rangeOfString:@",R,"].location != NSNotFound)
    {
        result = [NSString stringWithFormat:@"%@, readonly", result];
    }
    
    if ([attributes rangeOfString:@",C,"].location != NSNotFound)
    {
        result = [NSString stringWithFormat:@"%@, copy", result];
    }
    else if ([attributes rangeOfString:@",&,"].location != NSNotFound)
    {
        result = [NSString stringWithFormat:@"%@, strong", result];
    }
    else
    {
        result = [NSString stringWithFormat:@"%@, weak", result];
    }

    return [result UTF8String];
}

static const char* method_returnValueType(Method method)
{
    char* type = method_copyReturnType(method);
    switch(type[0])
    {
        case 'c':
            return "char";
            break;
        case 'C':
            return "unsigned char";
            break;
        case 's':
            return "short";
            break;
        case 'S':
            return "unsigned short";
            break;
        case 'i':
            return "int";
            break;
        case 'I':
            return "unsigned int";
            break;
        case 'l':
            return "long";
            break;
        case 'L':
            return "unsigned long";
            break;
        case 'q':
            return "long long";
            break;
        case 'Q':
            return "unsigned long long";
            break;
        case 'f':
            return "float";
            break;
        case 'd':
            return "double";
            break;
        case 'v':
            return "void";
            break;
        case '@':
            return "id";
            break;
        case '#':
            return "Class";
            break;
        case ':':
            return "SEL";
            break;
        case '*':
            return "char*";
            break;
        case '?':
            return "unknown";
            break;
        case 'b':
            return "bit";
            break;
    }
    return "";
}

@implementation POPropertyMetaData

- (NSString*)description
{
    return [NSString stringWithFormat:@"POPropertyMetaData: \n property name %@ \n property type %@ \n", self.name, self.type];
}

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
                propertyMetaData.type = property_getType(property);
                propertyMetaData.attributes = [NSString stringWithCString:property_getRetentionMethod(property) encoding:NSStringEncodingConversionAllowLossy];
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
            methodMetaData.signature = methodSignature;
            methodMetaData.returnValue = [NSString stringWithCString:method_returnValueType(instanceMethods[i]) encoding:NSStringEncodingConversionAllowLossy];
            [instanceMethodsMetaDataList addObject:methodMetaData];
        }
        free(instanceMethods);


        unsigned int numClassMethods = 0;
        Method* classMethods = class_copyMethodList(object_getClass(__class), &numClassMethods);

        NSMutableArray* classMethodsMetaDataList = [NSMutableArray new];
        for(int i = 0; i < numClassMethods; ++i)
        {
            POMethodMetaData* methodMetaData = [POMethodMetaData new];
            methodMetaData.signature = NSStringFromSelector(method_getName(classMethods[i]));
            methodMetaData.returnValue = [NSString stringWithCString:method_returnValueType(classMethods[i]) encoding:NSStringEncodingConversionAllowLossy];
            [classMethodsMetaDataList addObject:methodMetaData];
        }
        free(classMethods);

        classMetaData.instanceMethods = [NSArray arrayWithArray:instanceMethodsMetaDataList];
        classMetaData.classMethods = [NSArray arrayWithArray:classMethodsMetaDataList];

        [metaData addObject:classMetaData];
    }

    NSMutableDictionary* classesToJson = [NSMutableDictionary new];
    NSMutableArray* classesList = [NSMutableArray new];
    for(POClassMetaData* classMetaData in metaData)
    {
        NSMutableArray* classMethods = [NSMutableArray new];
        for(POMethodMetaData* methodMetaData in classMetaData.classMethods)
        {
            [classMethods addObject:[NSString stringWithFormat:@"+ (%@) %@;", methodMetaData.returnValue, methodMetaData.signature]];
        }

        NSMutableArray* instanceMethods = [NSMutableArray new];
        for(POMethodMetaData* methodMetaData in classMetaData.instanceMethods)
        {
            [instanceMethods addObject:[NSString stringWithFormat:@"- (%@) %@;", methodMetaData.returnValue, methodMetaData.signature]];
        }

        NSMutableArray* properties = [NSMutableArray new];
        for(POPropertyMetaData* propertyMetaData in classMetaData.properties)
        {
            [properties addObject:[NSString stringWithFormat:@"(%@) %@ %@", propertyMetaData.attributes, propertyMetaData.type, propertyMetaData.name]];
        }
        
        NSDictionary* classToJson = [NSDictionary dictionaryWithObjectsAndKeys:
                                     classMetaData.name, POClassKeys.className,
                                     classMetaData.superClassName, POClassKeys.superClassName,
                                     classMethods, POClassKeys.classMethods,
                                     instanceMethods, POClassKeys.instanceMethods,
                                     properties, POClassKeys.properties,
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
