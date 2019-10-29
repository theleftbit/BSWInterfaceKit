//
//  Created by Pierluigi Cifani on 02/08/15.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#include <TargetConditionals.h>

#if TARGET_OS_IOS

#import "BSWZoomImageTransition.h"


@interface BSWZoomImageTransition ()

@property (weak, nonatomic) id<BSWZoomImageTransitionDelegate> delegate;
@property (assign, nonatomic) BSWZoomTransitionType type;
@property (assign, nonatomic) NSTimeInterval duration;

@end

@implementation BSWZoomImageTransition

#pragma mark - Constructors

- (instancetype)initWithType:(BSWZoomTransitionType)type
                    duration:(NSTimeInterval)duration
                    delegate:(id<BSWZoomImageTransitionDelegate>)delegate {
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
    UIView *fromControllerView = [transitionContext viewForKey:UITransitionContextFromViewKey];
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
    UIImageView *startingView = [self.delegate zoomTransition:self startingViewFromViewController:fromViewController toViewController:toViewController];
    CGRect startFrame = [startingView convertRect:startingView.bounds toView:keyWindow];

    // Ask the delegate for the view where the animation will end
    UIImageView *targetView = [self.delegate zoomTransition:self targetViewFromViewController:fromViewController toViewController:toViewController];
    CGRect targetFrame = [targetView convertRect:targetView.bounds toView:keyWindow];

    // Now let's setup the animation hierarchy
    
    UIView *clipView = [UIView new];
    clipView.clipsToBounds = YES;
    clipView.frame = startFrame;
    clipView.backgroundColor = [UIColor redColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:startingView.image];
    imageView.contentMode = startingView.contentMode;
    imageView.clipsToBounds = YES;
    imageView.frame = clipView.bounds;
    [clipView addSubview:imageView];
    
    BOOL shouldAnimateCornerRadius = NO;
    switch (_type) {
        case BSWZoomTransitionTypePresenting:
        {
            if (startingView.layer.cornerRadius > 0) {
                shouldAnimateCornerRadius = YES;
                [clipView.layer setCornerRadius:startingView.layer.cornerRadius];
            }
        }
        break;
        
        case BSWZoomTransitionTypeDismissing:
        {
            if (targetView.layer.cornerRadius > 0) {
                shouldAnimateCornerRadius = YES;
                [clipView.layer setCornerRadius:targetView.layer.cornerRadius];
            }
        }
        break;
    }

    // The fade view will sit between the "from" snapshot and the target snapshot.
    // This is what is used to create the fade effect.
    UIView *fadeView;
    CGFloat fadeViewTargetAlpha;
    switch (_type) {
        case BSWZoomTransitionTypePresenting:
        {
            fadeView = [fromControllerView snapshotViewAfterScreenUpdates:YES];
            fadeView.backgroundColor = _fadeColor;
            fadeView.alpha = 1.0;
            fadeViewTargetAlpha = 0.0;
        }
        break;
        
        case BSWZoomTransitionTypeDismissing:
        {
            fadeView = [toControllerView snapshotViewAfterScreenUpdates:YES];
            fadeView.alpha = 0.0;
            fadeViewTargetAlpha = 1.0;
        }
        break;
    }

    // Assemble the hierarchy in the container
    [containerView addSubview:fadeView];
    [containerView addSubview:clipView];

    // Animate presentation
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Transform and move the "from" snapshot
                         clipView.frame = targetFrame;
                         if (self.type == BSWZoomTransitionTypePresenting) {
                             imageView.bounds = [self finalRectForImageSize:imageView.image.size constrainedToContentRect:targetFrame contentMode:targetView.contentMode];
                             imageView.center = clipView.center;
                         } else {
                             imageView.frame = CGRectMake(0, 0, targetFrame.size.width, targetFrame.size.height);
                         }
                         
                         // Fade
                         fadeView.alpha = fadeViewTargetAlpha;
                         
                         if (shouldAnimateCornerRadius) {
                             CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                             animation.duration = [self transitionDuration:transitionContext];
                             animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                             animation.toValue = @(targetView.layer.cornerRadius);
                             animation.fillMode = kCAFillModeForwards;
                             animation.removedOnCompletion = NO;
                             [clipView.layer addAnimation:animation forKey:@"setCornerRadius:"];
                         }
                         
                     } completion:^(BOOL finished) {
                         // Add "to" controller view
                         [containerView addSubview:toControllerView];
                         
                         // Cleanup our animation views
                         [backgroundView removeFromSuperview];
                         [clipView removeFromSuperview];
                         [fadeView removeFromSuperview];
                         
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         [transitionContext completeTransition:finished];
                     }];
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return _duration;
}

- (CGRect)finalRectForImageSize:(CGSize)imageSize
       constrainedToContentRect:(CGRect)contentRect
                    contentMode:(UIViewContentMode)contentMode
{
    //Handle 0x0 size images
    if(imageSize.height == 0 || imageSize.width == 0){
        imageSize.width = contentRect.size.width;
        imageSize.height = contentRect.size.height;
    }
    
    //Return final rect for current contentMode
    if(contentMode == UIViewContentModeScaleAspectFit){
        
        CGFloat scale = MIN(contentRect.size.width/imageSize.width, contentRect.size.height/imageSize.height);
        return CGRectIntegral(CGRectMake(0, 0, imageSize.width * scale, imageSize.height * scale));
        
    }else if(contentMode == UIViewContentModeScaleAspectFill){
        
        CGFloat scale = MAX(contentRect.size.width/imageSize.width, contentRect.size.height/imageSize.height);
        return CGRectIntegral(CGRectMake(0, 0, imageSize.width * scale, imageSize.height * scale));
        
    }else{
        //Other types not supported yet!
        return contentRect;
    }
}

@end
#endif
