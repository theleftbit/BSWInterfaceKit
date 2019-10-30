//
//  Created by Pierluigi Cifani on 02/08/15.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#include <TargetConditionals.h>

#if TARGET_OS_IOS

@import UIKit;

#import "BSWZoomTransitionType.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BSWZoomTransitionDelegate;

@interface BSWZoomTransition : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithType:(BSWZoomTransitionType)type
                    duration:(NSTimeInterval)duration
                    delegate:(id<BSWZoomTransitionDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (strong, nonatomic) UIColor *fadeColor;
@property (readonly, nonatomic) BSWZoomTransitionType type;

@end

@protocol BSWZoomTransitionDelegate <NSObject>

@required

- (nullable UIView *)zoomTransition:(BSWZoomTransition *)zoomTransition startingViewFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

- (nullable UIView *)zoomTransition:(BSWZoomTransition *)zoomTransition targetViewFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end

NS_ASSUME_NONNULL_END
#endif
