//
//  PORuntimeDecoder.h
//  SNContacts
//
//  Created by Sergey Sergeev on 12/3/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

#ifndef PORuntimeDecoderClass
#define PORuntimeDecoderClass

enum POAccessType
{
	POAccessTypeGetter,
	POAccessTypeSetter,
};

int seek_character_ptr(const char *_ptr, const char _separater);
int decode_selector_setter_getter(const char* _encoding_attribute, NSMutableArray** _attributes, enum POAccessType _access);
NSString* decode_array(const char *_ptr);
NSString* decode_struct(const char *_ptr);
NSString* decode_class_name(const char* _encoding);
NSString* decode_type(const char* _encoding);
NSString* decode_property(objc_property_t _property);
NSString* decode_method_signature(Method _method);
NSString* decode_method_name(Method _method);

#endif
