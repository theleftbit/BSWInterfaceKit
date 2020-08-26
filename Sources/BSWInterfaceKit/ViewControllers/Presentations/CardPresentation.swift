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
    public struct AnimationProperties {
        public let kind: Kind
        public let animationDuration: TimeInterval
        public let backgroundColor: UIColor
        public let shouldAnimateNewVCAlpha: Bool
        public let overridenTraits: UITraitCollection?
        public let roundCornerRadius: CGFloat?
        
        public enum CardHeight { // swiftlint:disable:this nesting
            case fixed(CGFloat)
            case intrinsicHeight
        }

        public enum Position { // swiftlint:disable:this nesting
            case top
            case bottom
        }

        public enum Kind { // swiftlint:disable:this nesting
            case dismissal
            case presentation(cardHeight: CardHeight = .intrinsicHeight, position: Position = .bottom)
        }

        public init(kind: Kind, animationDuration: TimeInterval = 0.6, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7), shouldAnimateNewVCAlpha: Bool = true, overridenTraits: UITraitCollection? = nil, roundCornerRadius: CGFloat? = nil) {
            self.kind = kind
            self.animationDuration = animationDuration
            self.backgroundColor = backgroundColor
            self.shouldAnimateNewVCAlpha = shouldAnimateNewVCAlpha
            self.overridenTraits = overridenTraits
            self.roundCornerRadius = roundCornerRadius
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

        /// Add background view
        let bgView = PresentationBackgroundView(frame: containerView.bounds)
        bgView.backgroundColor = properties.backgroundColor
        bgView.position = position
        bgView.parentViewController = toViewController
        bgView.tag = Constants.BackgroundViewTag
        containerView.addSubview(bgView)

        if let radius = properties.roundCornerRadius {
            toViewController.view.roundCorners(radius: radius)
        }
        
        /// Add VC's view
        containerView.addAutolayoutSubview(toViewController.view)

        /// Override size classes if required
        toViewController.presentationController?.overrideTraitCollection = properties.overridenTraits
            
        /// Pin to the bottom
        NSLayoutConstraint.activate([
            toViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
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
        let distanceToMove = toViewController.view.frame.height
        let offScreenTransform = CGAffineTransform(translationX: 0, y: distanceToMove)
        toViewController.view.transform = offScreenTransform
        
        /// Prepare the alpha animation
        toViewController.view.alpha = properties.shouldAnimateNewVCAlpha ? 0.0 : 1.0
        bgView.alpha = 0.0

        /// And bring it back on screen
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
            toViewController.view.transform = .identity
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
        guard let bgView = containerView.subviews.first(where: { $0.tag == Constants.BackgroundViewTag}) as? PresentationBackgroundView else { fatalError() }

        let distanceToMove = fromViewController.view.frame.height
        let offScreenTransform = CGAffineTransform(translationX: 0, y: distanceToMove)

        /// And bring it off screen
        let animator = UIViewPropertyAnimator(duration: properties.animationDuration, dampingRatio: 1.0) {
            fromViewController.view.transform = offScreenTransform
            fromViewController.view.alpha = self.properties.shouldAnimateNewVCAlpha ? 1 : 0
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
