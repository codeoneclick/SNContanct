//
//  PORuntimeDecoder.m
//  SNContacts
//
//  Created by Sergey Sergeev on 12/3/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "PORuntimeDecoder.h"

int decode_selector_setter_getter(const char* _encoding_attribute, NSMutableArray** _attributes, enum POAccessType _access)
{
	int memory_offset;
	char *selector_ptr;
	NSString *selector_name = nil;

	for(memory_offset = 0; *_encoding_attribute != ','; _encoding_attribute++, memory_offset++);
	if (memory_offset > 0)
    {
		selector_ptr = (char *)calloc(sizeof(char), memory_offset + 1);
		strncpy(selector_ptr, _encoding_attribute - memory_offset, memory_offset);
		if (_access == POAccessTypeGetter)
        {
			selector_name = [NSString stringWithFormat:@"getter=%s", selector_ptr];
		}
        else if(_access == POAccessTypeSetter)
        {
			selector_name = [NSString stringWithFormat:@"setter=%s", selector_ptr];
		}
		[*_attributes addObject:selector_name];
		free(selector_ptr);
	}
	return memory_offset;
}

int seek_character_ptr(const char *_ptr, const char _separater)
{
	int memory_point = 1;
	int memory_position = 0;
	char null_terminator = '\0';

	if(_separater == '{')
    {
		null_terminator = '}';
	}
    else if(_separater == '(')
    {
		null_terminator = ')';
	}

	while(YES)
    {
		if(*_ptr == _separater)
        {
			memory_point++;
		}
        else if(*_ptr == null_terminator)
        {
			memory_point--;
			if (memory_point == 0)
            {
				break;
			}
		}
		_ptr++;
		memory_position++;
	}
	return memory_position;
}

NSString * decode_array(const char *_ptr)
{
	const char *start_ptr = _ptr;
	NSString *array = nil;

	while((*_ptr >= '0') && (*_ptr <= '9'))
    {
		_ptr += 1;
	}
	array = [NSString stringWithFormat:@"%@[%d]", decode_type(_ptr), _ptr - start_ptr];
	return array;
}

NSString * decode_struct(const char *_ptr)
{
	int memory_offset;
	char *structure_name;
	NSString *structure = nil;

	for(memory_offset = 0; *_ptr != '='; _ptr++, memory_offset++);
	if (memory_offset > 0)
    {
		structure_name = (char *)calloc(sizeof(char), memory_offset + 1);
		strncpy(structure_name, _ptr - memory_offset, memory_offset);
		structure = [NSString stringWithCString:structure_name encoding:NSASCIIStringEncoding];
		free(structure_name);
		if ([structure isEqualToString:@"?"])
        {
            structure = @"UnknownType";
        }
	}
	return structure;
}

NSString * decode_class_name(const char* _encoding)
{
	int memory_offset;
	char* class_name;
	NSString* __class = nil;

	for(memory_offset = 0; *_encoding != '"'; _encoding++, memory_offset++);
	if (memory_offset > 0) {
		class_name = (char *)calloc(sizeof(char), memory_offset + 1);
		strncpy(class_name, _encoding - memory_offset, memory_offset);
		if (*class_name == '<')
        {
			__class = [NSString stringWithFormat:@"id%s", class_name];
		}
        else
        {
			__class = [NSString stringWithFormat:@"%s*", class_name];
		}

		free(class_name);
	}
	return __class;
}

NSString * decode_type(const char* _encoding)
{
	NSString *type = nil;

	switch (*_encoding)
    {
		case 'c':
			type = @"char";
			break;
		case 'i':
			type = @"int";
			break;
		case 's':
			type = @"short";
			break;
		case 'l':
			type = @"long";
			break;
		case 'q':
			type = @"long long";
			break;
		case 'C':
			type = @"unsigned char";
			break;
		case 'I':
			type = @"unsigned int";
			break;
		case 'S':
			type = @"unsigned short";
			break;
		case 'L':
			type = @"unsigned long";
			break;
		case 'Q':
			type = @"unsigned long long";
			break;
		case 'f':
			type = @"float";
			break;
		case 'd':
			type = @"double";
			break;
		case 'B':
			type = @"bool or _BOOL";
			break;
		case 'v':
			type = @"void";
			break;
		case '*':
			type = @"char *";
			break;
		case '@':
			if (*(_encoding + 1) == '"')
            {
				type = decode_class_name(_encoding + 2);
			} else {
				type = @"id";
			}
			break;
		case '#':
			type = @"Class";
			break;
		case ':':
			type = @"SEL";
			break;
		case '[':
			_encoding += 1;
			type = decode_array(_encoding);
			break;
		case '{':
			_encoding++;
			type = decode_array(_encoding);
			break;
		case '(':
			_encoding++;
			type = decode_struct(_encoding);
			break;
		case 'b':
			type = @"Bit";
			break;
		case '^':
			_encoding++;
			type = [NSString stringWithFormat:@"%@*", decode_type(_encoding)];
			break;
		case '?':
			type = @"Unknown pointer";
			break;
		default:
			break;
	}
	return type;
}


NSString * decode_property(objc_property_t _property)
{
    const char *attributes = property_getAttributes(_property);
	NSString *type = nil;
	NSMutableArray *decoded_attributes = [NSMutableArray array];
	NSMutableString *property = [NSMutableString string];
	BOOL isDynamic = NO;
	int i, count;

	while(*attributes)
    {
		switch (*attributes)
        {
			case 'T':
				attributes += 1;
				type = decode_type(attributes);
				if (*attributes == '{' || *attributes == '(') {
					attributes += seek_character_ptr(attributes + 1, *attributes);
				} else if (*attributes == '@' && *(attributes + 1) == '"') {
					attributes += [type length];
				} else if (*attributes == '@' && *(attributes + 2) == '<') {
					attributes += [type length] + 2;
				}
				attributes++;
				break;
			case 'R':
				[decoded_attributes addObject:@"readonly"];
				break;
			case 'C':
				[decoded_attributes addObject:@"copy"];
				break;
			case '&':
				[decoded_attributes addObject:@"strong"];
				break;
			case 'N':
				[decoded_attributes addObject:@"nonatomic"];
				break;
			case 'G':
				attributes++;
				attributes += decode_selector_setter_getter(attributes, &decoded_attributes, POAccessTypeGetter);
				break;
			case 'S':
				attributes++;
				attributes += decode_selector_setter_getter(attributes, &decoded_attributes, POAccessTypeSetter);
				break;
			case 'D':
				isDynamic = YES;
				break;
			case 'W':
				NSLog(@"__weak");
				break;
			case 'P':
				NSLog(@"GC");
				break;
			case ',':
			default:
				break;
		}
		attributes++;
	}

	[property appendString:(isDynamic ? @"@dynamic " : @"@property ")];

    bool is_weak = true;
    for(NSString* decoded_attribute in decoded_attributes)
    {
        if ([decoded_attribute rangeOfString:@"copy"].location != NSNotFound ||
            [decoded_attribute rangeOfString:@"strong"].location != NSNotFound ||
            [decoded_attribute rangeOfString:@"dynamic"].location != NSNotFound)
        {
            is_weak = false;
        }
    }
    if(is_weak)
    {
        [decoded_attributes insertObject:@"weak" atIndex:0];
    }

    count = [decoded_attributes count];
    
	if (count == 1)
    {
		[property appendFormat:@"(%@) ", [decoded_attributes objectAtIndex:0]];
	}
    else if (count > 1)
    {
		for(i = 0; i < count; i++)
        {
			if (i == 0)
            {
				[property appendFormat:@"(%@, ", [decoded_attributes objectAtIndex:i]];
			}
            else if (i == [decoded_attributes count] - 1)
            {
				[property appendFormat:@"%@) ", [decoded_attributes objectAtIndex:i]];
			}
            else
            {
				[property appendFormat:@"%@, ", [decoded_attributes objectAtIndex:i]];
			}
		}
	}

	if (type != nil) [property appendString:type];
	return property;
}

NSString* decode_method_signature(Method _method)
{
    NSString* signature = [NSString stringWithFormat:@"(%@)", decode_type(method_copyReturnType(_method))];
    signature = [signature stringByAppendingString:decode_method_name(_method)];
    unsigned int num_arguments = method_getNumberOfArguments(_method);
    for(unsigned int i = 2; i < num_arguments; ++i)
    {
        NSRange argument_halder_range = [signature  rangeOfString:@":"];
        NSString* argument_type = decode_type(method_copyArgumentType(_method, i));
        NSString* argument_name = [NSString stringWithFormat:@"arg_%i", i - 1];
        if(i == (num_arguments - 1))
        {
            signature = [signature stringByReplacingOccurrencesOfString:@":" withString:[NSString stringWithFormat:@"___(%@)%@", argument_type, argument_name] options:NSCaseInsensitiveSearch range:argument_halder_range];
        }
        else
        {
            signature = [signature stringByReplacingOccurrencesOfString:@":" withString:[NSString stringWithFormat:@"___(%@)%@ ", argument_type, argument_name] options:NSCaseInsensitiveSearch range:argument_halder_range];
        }
    }
    return [signature stringByReplacingOccurrencesOfString:@"___" withString:@":"];
}

NSString* decode_method_name(Method _method)
{
    return NSStringFromSelector(method_getName(_method));
}



