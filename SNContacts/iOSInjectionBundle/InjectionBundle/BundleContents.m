/*
    Generated for Injection of class implementations
*/

#define INJECTION_NOIMPL
#define INJECTION_BUNDLE InjectionBundle2

#undef _injectable
#define _injectable( _className ) _className(INJECTION_BUNDLE)
#undef _injectable_category
#define _injectable_category( _className, _category ) _className(InjectionBundle2##_##_category)

#undef _INCLASS
#define _INCLASS( _className ) _className(INJECTION_BUNDLE)
#undef _INCATEGORY
#define _INCATEGORY( _className, _category ) _className(InjectionBundle2##_##_category)

#undef _instatic
#define _instatic extern

#undef _inglobal
#define _inglobal extern

#undef _inval
#define _inval( _val... ) /* = _val */

#import "/Applications/Injection Plugin.app/Contents/Resources/BundleInjection.h"

#import "TmpSNViewController.m"



@interface InjectionBundle2 : NSObject {}
@end
@implementation InjectionBundle2

+ (void)load {
    [BundleInjection loaded];
}

@end

