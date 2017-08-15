//
//  Created by Pierluigi Cifani on 02/08/15.
//  Copyright © 2015 Blurred Software SL. All rights reserved.
//

#import "BSWZoomTransition.h"

@interface UIView (BSWSnapshot)

/**
 *
 * NOTE: The iOS simulator always uses this category over snapshotViewAfterScreenUpdates:
 * due to inconsistencies with the iOS10 simulators.
 *
 */
- (UIImage *)bsw_snapshot;

@end

@implementation UIView (BSWSnapshot)

- (UIImage *)bsw_snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

@end

@interface BSWZoomTransition ()

@property (weak, nonatomic) id<BSWZoomTransitionDelegate> delegate;
@property (assign, nonatomic) BSWZoomTransitionType type;
@property (assign, nonatomic) NSTimeInterval duration;

@end

@implementation BSWZoomTransition

#pragma mark - Constructors

- (instancetype)initWithType:(BSWZoomTransitionType)type
                    duration:(NSTimeInterval)duration
                    delegate:(id<BSWZoomTransitionDelegate>)delegate {
    self = [super init];
    if (self) {
        self.type = type;
        self.duration = duration;
        self.delegate = delegate;
        self.fadeColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    UIView *containerView = [transitionContext containerView];

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromControllerView = [transitionContext viewForKey:UITransitionContextFromViewKey];;
    UIView *toControllerView = [transitionContext viewForKey:UITransitionContextToViewKey];

    BOOL isShowingOpaqueBar = toViewController.navigationController && !toViewController.navigationController.navigationBar.isTranslucent;

    // Setup a background view to prevent content from peeking through while our
    // animation is in progress
    UIView *backgroundView = [[UIView alloc] initWithFrame:containerView.bounds];
    backgroundView.backgroundColor = _fadeColor;
    [containerView addSubview:backgroundView];

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

    if (_type == BSWZoomTransitionTypePresenting) {
        // Make sure the "to view" has been laid out if we're presenting. This needs
        // to be done before we ask the delegate for frames.
        toControllerView.frame = [transitionContext finalFrameForViewController:toViewController];
        [toControllerView setNeedsLayout];
        [toControllerView layoutIfNeeded];
    }

    UIView *startingView = [self.delegate zoomTransition:self startingViewFromViewController:fromViewController toViewController:toViewController];
    // Ask the delegate for the target view's starting frame
    CGRect startFrame = [startingView convertRect:startingView.bounds toView:(isShowingOpaqueBar ? keyWindow : fromControllerView)];

    // Ask the delegate for the target view's finishing frame
    UIView *targetView = [self.delegate zoomTransition:self targetViewFromViewController:fromViewController toViewController:toViewController];
    CGRect targetFrame = [targetView convertRect:targetView.bounds toView:(isShowingOpaqueBar ? keyWindow : toControllerView)];

    if (_type == BSWZoomTransitionTypePresenting) {
        // The "from" snapshot
#if TARGET_IPHONE_SIMULATOR
        UIView *fromControllerSnapshot = isShowingOpaqueBar ? [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO] : [[UIImageView alloc] initWithImage:[fromControllerView bsw_snapshot]];
#else
        UIView *fromControllerSnapshot = isShowingOpaqueBar ? [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO] : [fromControllerView snapshotViewAfterScreenUpdates:NO];
#endif

        // The fade view will sit between the "from" snapshot and the target snapshot.
        // This is what is used to create the fade effect.
        UIView *fadeView = [[UIView alloc] initWithFrame:containerView.bounds];
        fadeView.backgroundColor = _fadeColor;
        fadeView.alpha = 0.0;
        
        // The star of the show
#if TARGET_IPHONE_SIMULATOR
        UIView *targetSnapshot = [[UIImageView alloc] initWithImage:[startingView bsw_snapshot]];
#else
        UIView *targetSnapshot = [startingView snapshotViewAfterScreenUpdates:NO];
#endif
        targetSnapshot.frame = startFrame;
        
        // Assemble the hierarchy in the container
        [containerView addSubview:fromControllerSnapshot];
        [containerView addSubview:fadeView];
        [containerView addSubview:targetSnapshot];

        // Determine how much we need to scale
        CGFloat scaleFactor = targetFrame.size.width / startFrame.size.width;
        
        // Calculate the ending origin point for the "from" snapshot taking into account the scale transformation
        CGPoint endPoint = CGPointMake((-startFrame.origin.x * scaleFactor) + targetFrame.origin.x, (-startFrame.origin.y * scaleFactor) + targetFrame.origin.y);
        
        // Animate presentation
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // Transform and move the "from" snapshot
                             fromControllerSnapshot.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
                             if (!isnan(endPoint.x) && !isnan(endPoint.y)) {
                                 fromControllerSnapshot.frame = CGRectMake(endPoint.x, endPoint.y, fromControllerSnapshot.frame.size.width, fromControllerSnapshot.frame.size.height);

                                 // Fade
                                 fadeView.alpha = 1.0;

                                 // Move our target snapshot into position
                                 targetSnapshot.frame = targetFrame;
                             }
                         } completion:^(BOOL finished) {
                             // Add "to" controller view
                             [containerView addSubview:toControllerView];

                             // Cleanup our animation views
                             [backgroundView removeFromSuperview];
                             [fromControllerSnapshot removeFromSuperview];
                             [fadeView removeFromSuperview];
                             [targetSnapshot removeFromSuperview];
                             
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             [transitionContext completeTransition:finished];
                         }];
    }
    else {
        // Since the "to" controller isn't currently part of the view hierarchy, we need to use the
        // old snapshot API
        targetView.hidden = YES;
        UIView *toControllerSnapshot = [[UIImageView alloc] initWithImage:[toControllerView bsw_snapshot]];

        // Used to perform the fade, just like when presenting
        UIView *fadeView = [[UIView alloc] initWithFrame:containerView.bounds];
        fadeView.backgroundColor = _fadeColor;
        fadeView.alpha = 1.0;
        
        // The star of the show again, this time with the old snapshot API
        UIImageView *targetSnapshot = [[UIImageView alloc] initWithImage:[startingView bsw_snapshot]];
        targetSnapshot.frame = startFrame;
        

        // We're switching the values such that the scale factor returns the same result
        // as when we were presenting
        CGFloat scaleFactor = startFrame.size.width / targetFrame.size.width;
        
        // This is also the same equation used when presenting and will result in the same point,
        // except this time it's the start point for the animation
        CGPoint startPoint = CGPointMake((-targetFrame.origin.x * scaleFactor) + startFrame.origin.x, (-targetFrame.origin.y * scaleFactor) + startFrame.origin.y);
        
        // Apply the transformation and set the origin before the animation begins
        toControllerSnapshot.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
        if (!isnan(startPoint.x) && !isnan(startPoint.y)) {
            toControllerSnapshot.frame = CGRectMake(startPoint.x, startPoint.y, toControllerSnapshot.frame.size.width, toControllerSnapshot.frame.size.height);
        }

        // Assemble the view hierarchy in the container
        [containerView addSubview:toControllerSnapshot];
        [containerView addSubview:fadeView];
        [containerView addSubview:targetSnapshot];


        // Animate dismissal
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // Put the "to" snapshot back to it's original state
                             toControllerSnapshot.transform = CGAffineTransformIdentity;
                             toControllerSnapshot.frame = toControllerView.frame;

                             // Fade
                             fadeView.alpha = 0.0;

                             // Move the target snapshot into place
                             targetSnapshot.frame = targetFrame;
                         } completion:^(BOOL finished) {
                             targetView.hidden = NO;

                             // Add "to" controller view
                             [containerView addSubview:toControllerView];

                             // Cleanup our animation views
                             [backgroundView removeFromSuperview];
                             [toControllerSnapshot removeFromSuperview];
                             [fadeView removeFromSuperview];
                             [targetSnapshot removeFromSuperview];

                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             
                             [transitionContext completeTransition:finished];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return _duration;
}

@end
