//
//  Created by Pierluigi Cifani on 02/08/15.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BSWInterfaceKit/BSWZoomTransitionType.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BSWZoomImageTransitionDelegate;

@interface BSWZoomImageTransition : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithType:(BSWZoomTransitionType)type
                    duration:(NSTimeInterval)duration
                    delegate:(id<BSWZoomImageTransitionDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (strong, nonatomic) UIColor *fadeColor;
@property (readonly, nonatomic) BSWZoomTransitionType type;

@end

@protocol BSWZoomImageTransitionDelegate <NSObject>

@required

- (UIImageView *)zoomTransition:(BSWZoomImageTransition *)zoomTransition startingViewFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;
- (UIImageView *)zoomTransition:(BSWZoomImageTransition *)zoomTransition targetViewFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end

NS_ASSUME_NONNULL_END
