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
    CALayer *shadowLayer = [self bswShadowLayer];
    if (shadowLayer != nil) {
        shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius] CGPath];
    }
}

- (void)bsw_addShadow:(BSWShadowInformation *)shadowInfo {
    CALayer *shadowLayer = [CALayer new];
    shadowLayer.shadowColor = ([[UIColor blackColor] CGColor]);
    shadowLayer.shadowOffset = shadowInfo.offset;
    shadowLayer.shadowOpacity = shadowInfo.opacity;
    shadowLayer.shadowRadius = shadowInfo.radius;
    [self.layer insertSublayer:shadowLayer atIndex:0];
    [self setBSWShadowLayer:shadowLayer];
}

- (void)setBSWShadowLayer:(CALayer *)object {
     objc_setAssociatedObject(self, @selector(bswShadowLayer), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CALayer *)bswShadowLayer {
    return objc_getAssociatedObject(self, @selector(bswShadowLayer));
}

@end

@implementation BSWShadowInformation
@end

#endif
