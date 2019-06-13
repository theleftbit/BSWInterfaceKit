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
        [self swizzle:@selector(viewDidLayoutSubviews)
           withCustom:@selector(bsw_viewDidLayoutSubviews)];

        [self swizzle:@selector(viewWillTransitionToSize:withTransitionCoordinator:)
           withCustom:@selector(bsw_viewWillTransitionToSize:withTransitionCoordinator:)];
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

#pragma mark viewWillTransitionToSize:withTransitionCoordinator:

- (void)bsw_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [self bsw_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UIView *loadedView = [self viewIfLoaded];
    if (loadedView == nil) {
        return;
    }
    UIView *firstView = [[loadedView subviews] firstObject];
    if (![firstView isKindOfClass:[UICollectionView class]]) {
        return;
    }
    UICollectionView *collectionView = (UICollectionView *)firstView;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [[collectionView collectionViewLayout] invalidateLayout];
        [collectionView reloadData];
    } completion:nil];
}

#pragma mark viewDidLayoutSubviews
    
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
