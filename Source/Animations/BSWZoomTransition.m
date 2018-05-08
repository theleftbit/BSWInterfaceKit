//
//  Created by Pierluigi Cifani on 02/08/15.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
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

    // Ask the delegate for the view where the animation will begin
    UIView *startingView = [self.delegate zoomTransition:self startingViewFromViewController:fromViewController toViewController:toViewController];
    CGRect startFrame = [startingView convertRect:startingView.bounds toView:keyWindow];

    // Ask the delegate for the view where the animation will end
    UIView *targetView = [self.delegate zoomTransition:self targetViewFromViewController:fromViewController toViewController:toViewController];
    CGRect targetFrame = [targetView convertRect:targetView.bounds toView:keyWindow];

    // Do the math to see how much the view has to grow
    CGFloat scaleFactor;
    switch (_type) {
        case BSWZoomTransitionTypePresenting:
            scaleFactor = targetFrame.size.width / startFrame.size.width;
            break;

        case BSWZoomTransitionTypeDismissing:
            scaleFactor = startFrame.size.width / targetFrame.size.width;
            break;
    }
    // Make sure that we're accounting for the translucency in the navBar
    CGFloat contentOffsetY = fromControllerView.frame.origin.y;
    CGFloat contentOffsetYScaled = contentOffsetY*scaleFactor;

    if (_type == BSWZoomTransitionTypePresenting) {
        // The "from" snapshot
#if TARGET_IPHONE_SIMULATOR
        UIView *fromControllerSnapshot = [[UIImageView alloc] initWithImage:[fromControllerView bsw_snapshot]];
#else
        UIView *fromControllerSnapshot = [fromControllerView snapshotViewAfterScreenUpdates:NO];
#endif
        fromControllerSnapshot.frame = CGRectMake(0, contentOffsetY, fromControllerSnapshot.frame.size.width, fromControllerSnapshot.frame.size.height);

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

        // Calculate the ending origin point for the "from" snapshot taking into account the scale transformation
        CGPoint endPoint = CGPointMake((-startFrame.origin.x * scaleFactor) + targetFrame.origin.x, (-startFrame.origin.y * scaleFactor) + targetFrame.origin.y + contentOffsetYScaled);

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
        UIView *toControllerSnapshot = [[UIImageView alloc] initWithImage:[toControllerView bsw_snapshot]];

        // Used to perform the fade, just like when presenting
        UIView *fadeView = [[UIView alloc] initWithFrame:containerView.bounds];
        fadeView.backgroundColor = _fadeColor;
        fadeView.alpha = 1.0;

        // The star of the show again, this time with the old snapshot API
        UIImageView *targetSnapshot = [[UIImageView alloc] initWithImage:[startingView bsw_snapshot]];
        targetSnapshot.frame = startFrame;

        // This is also the same equation used when presenting and will result in the same point,
        // except this time it's the start point for the animation
        CGPoint startPoint = CGPointMake((-targetFrame.origin.x * scaleFactor) + startFrame.origin.x, (-targetFrame.origin.y * scaleFactor) + startFrame.origin.y + contentOffsetYScaled);

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
