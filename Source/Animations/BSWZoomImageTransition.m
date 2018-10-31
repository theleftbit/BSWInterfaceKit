//
//  Created by Pierluigi Cifani on 02/08/15.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

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
    
    // The fade view will sit between the "from" snapshot and the target snapshot.
    // This is what is used to create the fade effect.
    UIView *fadeView = [[UIView alloc] initWithFrame:containerView.bounds];
    fadeView.backgroundColor = _fadeColor;
    
    // Assemble the hierarchy in the container
    [containerView addSubview:fadeView];
    [containerView addSubview:clipView];

    if (_type == BSWZoomTransitionTypePresenting) {

        fadeView.alpha = 0.0;

        // Animate presentation
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // Transform and move the "from" snapshot
                             clipView.frame = targetFrame;
                             imageView.bounds = [self finalRectForImageSize:imageView.image.size constrainedToContentRect:targetFrame contentMode:targetView.contentMode];
                             
                             imageView.center = clipView.center;
                             // Fade
                             fadeView.alpha = 1.0;
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
    else {


        // Animate dismissal
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // Transform and move the "from" snapshot
                             clipView.frame = targetFrame;
                             imageView.bounds = [self finalRectForImageSize:targetView.image.size constrainedToContentRect:targetFrame contentMode:targetView.contentMode];
                             NSLog(@"%@", NSStringFromCGRect(imageView.bounds));
                             imageView.center = clipView.center;

                             // Fade
                             fadeView.alpha = 1.0;

                         } completion:^(BOOL finished) {
                             
                             // Add "to" controller view
                             [containerView addSubview:toControllerView];
                             
                             // Cleanup our animation views
                             [backgroundView removeFromSuperview];
                             [imageView removeFromSuperview];
                             [fadeView removeFromSuperview];
                             [clipView removeFromSuperview];
                             
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             
                             [transitionContext completeTransition:finished];
                         }];
    }
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
