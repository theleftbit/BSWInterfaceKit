//
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//  Created by Pierluigi Cifani.
//

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
        public let presentationInsideSafeArea: Bool
        public let backgroundColor: UIColor
        public let shouldAnimateNewVCAlpha: Bool
        
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

        public init(kind: Kind, animationDuration: TimeInterval = 0.6, presentationInsideSafeArea: Bool = false, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7), shouldAnimateNewVCAlpha: Bool = true) {
            self.kind = kind
            self.animationDuration = animationDuration
            self.presentationInsideSafeArea = presentationInsideSafeArea
            self.backgroundColor = backgroundColor
            self.shouldAnimateNewVCAlpha = shouldAnimateNewVCAlpha
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
        guard case .presentation(let cardHeight, let position) = properties.kind else { fatalError() }

        let containerView = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)

        // Add background view
        let bgView = PresentationBackgroundView(frame: containerView.bounds)
        bgView.backgroundColor = properties.backgroundColor
        bgView.position = position
        bgView.parentViewController = toViewController
        bgView.tag = Constants.BackgroundViewTag
        containerView.addSubview(bgView)

        // Add VC's view
        containerView.addAutolayoutSubview(toViewController.view)

        // Calculate the height of the new VC to prepare animate it
        let toVCHeight: CGFloat = {
            switch cardHeight {
            case .fixed(let height): return height
            case .intrinsicHeight:
                return toViewController.view.systemLayoutSizeFitting(
                    CGSize(width: containerView.frame.width, height: UIView.layoutFittingCompressedSize.height),
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                ).height
            }
        }()

        //Prepare Constraints
        let anchorConstraint: NSLayoutConstraint = {
            switch (position, properties.presentationInsideSafeArea) {
            case (.bottom, false):
                return toViewController.view.topAnchor.constraint(equalTo: containerView.bottomAnchor)
            case (.top, false):
                return containerView.topAnchor.constraint(equalTo: toViewController.view.bottomAnchor)
            case (.bottom, true):
                return toViewController.view.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
            case (.top, true):
                return containerView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: toViewController.view.bottomAnchor)
            }
        }()
        NSLayoutConstraint.activate([
            toViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            anchorConstraint
        ])
        
        if #available(iOS 13, *) {
            toViewController.view.heightAnchor.constraint(equalToConstant: toVCHeight).isActive = true
        }
        
        // Store this constraint somewhere so we can get it later
        bgView.anchorConstraint = anchorConstraint
        
        toViewController.view.alpha = properties.shouldAnimateNewVCAlpha ? 0.0 : 1.0
        bgView.alpha = 0.0
        containerView.layoutIfNeeded()

        // This is the change that animates this from the bottom
        let extraPadding: CGFloat = {
            guard properties.presentationInsideSafeArea,
                let fromVC = transitionContext.viewController(forKey: .from) else {
                return 0
            }
            switch position {
            case .top:
                if let navVC = fromVC as? UINavigationController, let containerInsets = navVC.topViewController?.view?.safeAreaInsets {
                    return containerInsets.top
                } else {
                    return containerView.safeAreaInsets.top
                }
            case .bottom:
                if let tabVC = fromVC as? UITabBarController, let containerInsets = tabVC.selectedViewController?.view.safeAreaInsets {
                    return containerInsets.bottom
                } else {
                    return containerView.safeAreaInsets.bottom
                }
            }
        }()
        anchorConstraint.constant = -(toVCHeight + extraPadding)
        
        // Start slide up animation
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
            containerView.layoutIfNeeded()
            toViewController.view.alpha = 1.0
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

        let extraPadding: CGFloat = {
            guard properties.presentationInsideSafeArea else {
                return 0
            }
            switch bgView.position! {
            case .top:
                return containerView.safeAreaInsets.top
            case .bottom:
                return containerView.safeAreaInsets.bottom
            }
        }()

        bgView.anchorConstraint.constant = extraPadding + 0

        //Start slide up animation
        let animator = UIViewPropertyAnimator(duration: properties.animationDuration, dampingRatio: 1.0) {
            containerView.layoutIfNeeded()
            bgView.alpha = 0.0
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
