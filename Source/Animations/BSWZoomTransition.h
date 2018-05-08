//
//  Created by Pierluigi Cifani on 02/08/15.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BSWZoomTransitionDelegate;

typedef NS_ENUM(NSInteger, BSWZoomTransitionType) {
    BSWZoomTransitionTypePresenting,
    BSWZoomTransitionTypeDismissing
};

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

- (UIView *)zoomTransition:(BSWZoomTransition *)zoomTransition startingViewFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

- (UIView *)zoomTransition:(BSWZoomTransition *)zoomTransition targetViewFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end
