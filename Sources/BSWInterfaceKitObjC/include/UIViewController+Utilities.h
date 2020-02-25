//
//  Created by Pierluigi Cifani on 18/04/2019.
//

#include <TargetConditionals.h>

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Utilities)

- (void)viewInitialLayoutDidComplete;
- (void)addConstraintsForHorizontalCompactSizeClass:(NSArray<NSLayoutConstraint *>*)compactConstraints
                                   regularSizeClass:(NSArray<NSLayoutConstraint *>*)regularConstraints NS_SWIFT_NAME(addConstraintsForHorizontal(compactSizeClass:regularSizeClass:));

@end

NS_ASSUME_NONNULL_END

#endif
