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
        public let animationDuration: TimeInterval
        public let kind: Kind
        public let backgroundColor: UIColor

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

        public init(kind: Kind, animationDuration: TimeInterval = 0.6, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7)) {
            self.kind = kind
            self.animationDuration = animationDuration
            self.backgroundColor = backgroundColor
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
        bgView.parentViewController = toViewController
        bgView.tag = Constants.BackgroundViewTag
        containerView.addSubview(bgView)

        // Add VC's view
        containerView.addAutolayoutSubview(toViewController.view)

        //Prepare Constraints
        let anchorConstraint: NSLayoutConstraint = {
            switch position {
            case .bottom:
                return toViewController.view.topAnchor.constraint(equalTo: containerView.bottomAnchor)
            case .top:
                return containerView.topAnchor.constraint(equalTo: toViewController.view.bottomAnchor)
            }
        }()
        NSLayoutConstraint.activate([
            toViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            anchorConstraint
        ])
        
        // Store this constraint somewhere so we can get it later
        bgView.anchorConstraint = anchorConstraint

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
        
        toViewController.view.alpha = 0.0
        bgView.alpha = 0.0
        containerView.layoutIfNeeded()

        // This is the change that animates this from the bottom
        anchorConstraint.constant = -toVCHeight
        
        // Start slide up animation
        let animator = UIViewPropertyAnimator.init(duration: duration, dampingRatio: 1.0) {
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

        bgView.anchorConstraint.constant = 0

        //Start slide up animation
        let animator = UIViewPropertyAnimator.init(duration: properties.animationDuration, dampingRatio: 1.0) {
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
