//
//  POBundleGuard.m
//
//  Created by Sergey Sergeev on 10/3/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#include "POBundleGuard.h"
#include <sys/event.h>
#include <sys/time.h> 
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

@interface POBundleGuard()
{
    CFFileDescriptorRef _kqRef;
}

@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* name;

@end

@implementation POBundleGuard

#pragma mark - Init Methods

- (id)initWithName:(NSString*)name;
{
    self = [super init];
    if (self) 
    {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"fixtures" ofType:@"plist"];
        NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
        self.path = [NSString stringWithFormat:@"%@", [plist objectForKey:@"FIXTURE_PATH"]];
        self.name = name;
        [self bindTracking];
    }
    return self;
}

#pragma mark - Private methods

- (void)kqueueFired
{
    int             kq;
    struct kevent   event;
    struct timespec timeout = { 0, 0 };
    int             eventCount;
    
    kq = CFFileDescriptorGetNativeDescriptor(self->_kqRef);
    assert(kq >= 0);
    
    eventCount = kevent(kq, NULL, 0, &event, 1, &timeout);
    assert( (eventCount >= 0) && (eventCount < 2) );

    NSString* name = (__bridge NSString*)event.udata;
    assert([name isKindOfClass:[NSString class]]);

    if([name isEqualToString:self.name])
    {
        [self.delegate onContentChanged:self];
    }
    CFFileDescriptorEnableCallBacks(self->_kqRef, kCFFileDescriptorReadCallBack);
}

static void KQCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info)
{
    POBundleGuard *object;
    object = (__bridge POBundleGuard *) info;
    assert([object isKindOfClass:[POBundleGuard class]]);
    assert(kqRef == object->_kqRef);
    assert(callBackTypes == kCFFileDescriptorReadCallBack);
    [object kqueueFired];
}

- (void)bindTracking
{
    int                     dirFD;
    int                     kq;
    int                     retVal;
    struct kevent           eventToAdd;
    CFFileDescriptorContext context = { 0, (__bridge_retained void *)self, NULL, NULL, NULL };
    CFRunLoopSourceRef      rls;
    
    dirFD = open([self.path fileSystemRepresentation], O_EVTONLY);
    assert(dirFD >= 0);
    
    kq = kqueue();
    assert(kq >= 0);
    
    eventToAdd.ident  = dirFD;
    eventToAdd.filter = EVFILT_VNODE;
    eventToAdd.flags  = EV_ADD | EV_CLEAR;
    eventToAdd.fflags = NOTE_WRITE;
    eventToAdd.data   = 0;
    eventToAdd.udata  = (__bridge void *)(self.name);
    
    retVal = kevent(kq, &eventToAdd, 1, NULL, 0, NULL);
    assert(retVal == 0);
    
    assert(self->_kqRef == NULL);
    
    self->_kqRef = CFFileDescriptorCreate(NULL, kq, true, KQCallback, &context);
    assert(self->_kqRef != NULL);
    
    rls = CFFileDescriptorCreateRunLoopSource(NULL, self->_kqRef, 0);
    assert(rls != NULL);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    
    CFRelease(rls);
    
    CFFileDescriptorEnableCallBacks(self->_kqRef, kCFFileDescriptorReadCallBack);
}

@end
