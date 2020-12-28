//
//  UIViewController+Utilities.m
//  Created by Pierluigi Cifani on 18/04/2019.
//

#include <TargetConditionals.h>

#if TARGET_OS_IOS

#import "UIView+Utilities.h"
#import <objc/runtime.h>

@implementation UIView (Utilities)
    
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzle:@selector(layoutSubviews)
           withCustom:@selector(bsw_layoutSubviews)];
    });
}
    
+ (void)swizzle:(SEL)originalSelector withCustom:(SEL)customSelector {
    
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, customSelector);
    
    BOOL didAddMethod =
    class_addMethod(self,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            customSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)bsw_layoutSubviews {
    [self bsw_layoutSubviews];
    BSWShadowInformation *shadowInfo = [self bsw_shadowInfo];
    if (shadowInfo != nil) {
        self.layer.shadowColor = ([[UIColor blackColor] CGColor]);
        self.layer.shadowOffset = shadowInfo.offset;
        self.layer.shadowOpacity = shadowInfo.opacity;
        self.layer.shadowRadius = shadowInfo.radius;
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius] CGPath];
        self.layer.masksToBounds = NO;
    }
}

@dynamic bsw_shadowInfo;

- (void)setBsw_shadowInfo:(BSWShadowInformation *)object {
     objc_setAssociatedObject(self, @selector(bswShadowInformation), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BSWShadowInformation *)bsw_shadowInfo {
    return objc_getAssociatedObject(self, @selector(bswShadowInformation));
}

@end

@implementation BSWShadowInformation
@end

#endif
