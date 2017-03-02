//
//  Copyright © 2017 Blurred Software SL. All rights reserved.
//  Created by Pierluigi Cifani.
//

import UIKit

/**
 This abstraction will create the appropiate `UIViewControllerAnimatedTransitioning`
 instance for a card-like modal animation.
 - Attention: To use it:
 ```
 extension FooViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardPresentation.transitioningFor(kind: .presentation)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardPresentation.transitioningFor(kind: .dismissal)
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
        public let cardHeight: CGFloat
        public let animationDuration: TimeInterval
        public let kind: Kind

        public enum Kind { // swiftlint:disable:this nesting
            case dismissal
            case presentation
        }

        public init(cardHeight: CGFloat = 400, animationDuration: TimeInterval = 0.6, kind: Kind) {
            self.cardHeight = cardHeight
            self.animationDuration = animationDuration
            self.kind = kind
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

fileprivate class CardPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let properties: CardPresentation.AnimationProperties

    init(properties: CardPresentation.AnimationProperties) {
        self.properties = properties
        super.init()
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if NSClassFromString("XCTest") != nil {
            return TimeInterval(CGFloat.leastNonzeroMagnitude)
        } else {
            return properties.animationDuration
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)

        // Add background view
        let bgView = CardViewControllerBackgroundView(frame: containerView.bounds)
        bgView.parentViewController = toViewController
        bgView.tag = Constants.BackgroundViewTag
        containerView.addSubview(bgView)

        bgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        bgView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

        // Add VC's view
        containerView.addSubview(toViewController.view)

        let frame = containerView.frame
        let cardTopInset = frame.size.height - max(0.0, properties.cardHeight)

        let initialFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsets(top: containerView.bounds.height, left:0.0, bottom:0.0, right:0.0))
        let finalFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsets(top: cardTopInset, left: 0.0, bottom: 0.0, right: 0.0))

        toViewController.view.frame = initialFrame
        toViewController.view.alpha = 0.0
        bgView.alpha = 0.0

        //Start slide up animation
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5 / 1.0,
                       options: [],
                       animations: {() -> Void in
                        toViewController.view.frame = finalFrame
                        toViewController.view.alpha = 1.0
                        bgView.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            transitionContext.completeTransition(true)
        })
    }
}

fileprivate class CardDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let properties: CardPresentation.AnimationProperties

    init(properties: CardPresentation.AnimationProperties) {
        self.properties = properties
        super.init()
    }

    // MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if NSClassFromString("XCTest") != nil {
            return TimeInterval(CGFloat.leastNonzeroMagnitude)
        } else {
            return properties.animationDuration
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let bgView = containerView.subviews.first(where: { $0.tag == Constants.BackgroundViewTag}) else { return }

        let frame = containerView.frame
        let finalFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsets(top: containerView.bounds.height, left: 0.0, bottom: 0.0, right: 0.0))

        UIView.animate(withDuration: properties.animationDuration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5 / 1.0,
                       options: [],
                       animations: {() -> Void in
                        fromViewController.view.frame = finalFrame
                        bgView.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

fileprivate class CardViewControllerBackgroundView: UIView {
    weak var parentViewController: UIViewController?
    weak var singleFingerTap: UITapGestureRecognizer?

    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        self.setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func setUp() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap))
        self.singleFingerTap = singleFingerTap
        self.addGestureRecognizer(singleFingerTap)
        translatesAutoresizingMaskIntoConstraints = false
    }

    func handleSingleTap(_ sender: Any) {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
}

fileprivate enum Constants {
    static let BackgroundViewTag = 78
}
