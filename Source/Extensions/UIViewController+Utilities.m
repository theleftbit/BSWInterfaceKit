//
//  UIViewController+Utilities.m
//  Created by Pierluigi Cifani on 18/04/2019.
//

#import "UIViewController+Utilities.h"
#import <objc/runtime.h>

@implementation UIViewController (Utilities)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewDidLayoutSubviews);
        SEL swizzledSelector = @selector(bsw_viewDidLayoutSubviews);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)bsw_viewDidLayoutSubviews {
    [self bsw_viewDidLayoutSubviews];
    NSNumber *originalFirstLayoutPassed = [self bsw_firstLayoutPassed];
    [self setBSWFirstLayoutPassed:@YES];
    if (originalFirstLayoutPassed == nil) {
        [self viewInitialLayoutDidComplete];
    }
}

- (void)setBSWFirstLayoutPassed:(NSNumber *)firstLayoutPassed {
    objc_setAssociatedObject(self, @selector(bsw_firstLayoutPassed), firstLayoutPassed, OBJC_ASSOCIATION_COPY);
}

- (NSNumber *)bsw_firstLayoutPassed {
    return objc_getAssociatedObject(self, @selector(bsw_firstLayoutPassed));
}

- (void)viewInitialLayoutDidComplete {
    // To be overriden by subclasses
}

@end
