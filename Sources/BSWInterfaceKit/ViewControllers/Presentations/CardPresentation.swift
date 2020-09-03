//
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//  Created by Pierluigi Cifani.
//

#if canImport(UIKit)

import UIKit

/**
 This abstraction will create the appropiate `UIViewControllerAnimatedTransitioning`
 instance for a card-like modal animation.
 - Attention: To use it:
 ```
 extension FooVC: UIViewControllerTransitioningDelegate {
     public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
         let properties = CardPresentation.AnimationProperties(kind: .presentation(cardHeight: .intrinsicHeight), animationDuration: 2)
         return CardPresentation.transitioningFor(properties: properties)
     }
     
     public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
         let properties = CardPresentation.AnimationProperties(kind: .dismissal, animationDuration: 2)
         return CardPresentation.transitioningFor(properties: properties)
     }
 }
 ```
 - note: For an example on how it [looks](http://i.giphy.com/l0EwZqcEkc15D6XOo.gif)
 */

public enum CardPresentation {

    /**
     These are the properties you can edit of the card-like modal presentation.
     */
    public struct AnimationProperties: Equatable {
        public let kind: Kind
        public let animationDuration: TimeInterval
        public let presentationInsideSafeArea: Bool
        public let backgroundColor: UIColor
        public let shouldAnimateNewVCAlpha: Bool
        public let overridenTraits: UITraitCollection?
        public let roundCornerRadius: CGFloat?
        public let initialYOffset: CGFloat?

        public enum CardHeight: Equatable { // swiftlint:disable:this nesting
            case fixed(CGFloat)
            case intrinsicHeight
        }

        public enum Position: Equatable { // swiftlint:disable:this nesting
            case top
            case bottom
        }

        public enum Kind: Equatable { // swiftlint:disable:this nesting
            case dismissal
            case presentation(cardHeight: CardHeight = .intrinsicHeight, position: Position = .bottom)
        }

        public init(kind: Kind, animationDuration: TimeInterval = 0.6, presentationInsideSafeArea: Bool = false, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7), shouldAnimateNewVCAlpha: Bool = true, overridenTraits: UITraitCollection? = nil, roundCornerRadius: CGFloat? = nil, initialYOffset: CGFloat? = nil) {
            self.kind = kind
            self.animationDuration = animationDuration
            self.presentationInsideSafeArea = presentationInsideSafeArea
            self.backgroundColor = backgroundColor
            self.shouldAnimateNewVCAlpha = shouldAnimateNewVCAlpha
            self.overridenTraits = overridenTraits
            self.roundCornerRadius = roundCornerRadius
            self.initialYOffset = initialYOffset
        }
    }

    /**
     This method will return a `UIViewControllerAnimatedTransitioning` with default `AnimationProperties`
     for the given `Kind`
     - Parameter kind: A value that represents the kind of transition you need.
     */
    static public func transitioningFor(kind: AnimationProperties.Kind) -> UIViewControllerAnimatedTransitioning {
        return transitioningFor(properties: CardPresentation.AnimationProperties(kind: kind))
    }

    /**
     This method will return a `UIViewControllerAnimatedTransitioning` with the given `AnimationProperties`
     - Parameter properties: The properties for the desired animation.
     */
    static public func transitioningFor(properties: AnimationProperties) -> UIViewControllerAnimatedTransitioning {
        switch properties.kind {
        case .dismissal:
            return CardDismissAnimationController(properties: properties)
        case .presentation:
            return CardPresentAnimationController(properties: properties)
        }
    }
}

private class CardPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let properties: CardPresentation.AnimationProperties

    init(properties: CardPresentation.AnimationProperties) {
        self.properties = properties
        super.init()
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return properties.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard var fromViewController = transitionContext.viewController(forKey: .from) else { return }
        if let containerVC = fromViewController as? ContainerViewController {
            fromViewController = containerVC.containedViewController
        }
        if let tabBarController = fromViewController as? UITabBarController {
            fromViewController = tabBarController.selectedViewController ?? fromViewController
        }
        if let navController = fromViewController as? UINavigationController {
            fromViewController = navController.topViewController ?? fromViewController
        }
        guard case .presentation(let cardHeight, let position) = properties.kind else { fatalError() }

        let containerView = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)
        let safeAreaOffset: CGFloat = {
             guard properties.presentationInsideSafeArea else {
                 return 0
             }
             switch position {
             case .top:
                 return fromViewController.view.safeAreaInsets.top
             case .bottom:
                 return fromViewController.view.safeAreaInsets.bottom
             }
         }()

        /// Add background view
        let bgView = PresentationBackgroundView(frame: containerView.bounds)
        bgView.backgroundColor = properties.backgroundColor
        bgView.tag = Constants.BackgroundViewTag
        containerView.addSubview(bgView)
        bgView.context = .init(parentViewController: toViewController, position: position, offset: safeAreaOffset)
        if let radius = properties.roundCornerRadius {
            toViewController.view.roundCorners(radius: radius)
        }
        
        /// Add VC's view
        containerView.addAutolayoutSubview(toViewController.view)

        /// Override size classes if required
        toViewController.presentationController?.overrideTraitCollection = properties.overridenTraits
            
        /// Pin to the bottom or top
        let anchorConstraint: NSLayoutConstraint = {
             switch (position) {
             case .bottom:
                 return toViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: safeAreaOffset)
             case .top:
                 return toViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: safeAreaOffset)
             }
         }()
        NSLayoutConstraint.activate([
            toViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            anchorConstraint,
        ])
        
        /// If it's a fixed height, add that constraint
        switch cardHeight {
        case .fixed(let height):
            toViewController.view.heightAnchor.constraint(equalToConstant: height).isActive = true
        case .intrinsicHeight:
            break
        }

        /// Perform the first layout pass
        containerView.layoutIfNeeded()

        /// Now move this view offscreen
        let distanceToMove = toViewController.view.frame.height + safeAreaOffset
        let distanceToMoveWithPosition = (position == .bottom) ? distanceToMove : -distanceToMove
        let offScreenTransform = CGAffineTransform(translationX: 0, y: distanceToMoveWithPosition)
        toViewController.view.transform = offScreenTransform
        
        /// Prepare the alpha animation
        toViewController.view.alpha = properties.shouldAnimateNewVCAlpha ? 0.0 : 1.0
        bgView.alpha = 0.0

        /// And bring it back on screen
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
            toViewController.view.transform = {
                if let offset = self.properties.initialYOffset {
                    return CGAffineTransform(translationX: 0, y: offset)
                } else {
                    return .identity
                }
            }()
            toViewController.view.alpha = 1
            bgView.alpha = 1.0
        }
        animator.addCompletion { (position) in
            guard position == .end else { return }
            transitionContext.completeTransition(true)
        }
        animator.startAnimation()
    }
}

private class CardDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let properties: CardPresentation.AnimationProperties

    init(properties: CardPresentation.AnimationProperties) {
        self.properties = properties
        super.init()
    }

    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return properties.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let bgView = containerView.subviews.first(where: { $0.tag == Constants.BackgroundViewTag}) as? PresentationBackgroundView, let context = bgView.context else { fatalError() }
        
        let distanceToMove = fromViewController.view.frame.height + (context.offset ?? 0)
        let distanceToMoveWithPosition = (context.position == .bottom) ? distanceToMove : -distanceToMove
        let offScreenTransform = CGAffineTransform(translationX: 0, y: distanceToMoveWithPosition)

        /// And bring it off screen
        let animator = UIViewPropertyAnimator(duration: properties.animationDuration, dampingRatio: 1.0) {
            fromViewController.view.transform = offScreenTransform
            fromViewController.view.alpha = self.properties.shouldAnimateNewVCAlpha ? 0 : 1
            bgView.alpha = 0
        }
        animator.addCompletion { (position) in
            guard position == .end else { return }
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        animator.startAnimation()
    }
}

private enum Constants {
    static let BackgroundViewTag = 78
}
#endif
