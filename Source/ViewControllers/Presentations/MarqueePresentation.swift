//
//  MarqueePresentation.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//

import Foundation

public enum MarqueePresentation {
    
    public struct AnimationProperties {
        public let sizing: Sizing
        public let animationDuration: TimeInterval
        public let kind: Kind
        public let roundsCorners: Bool

        public enum Kind { // swiftlint:disable:this nesting
            case dismissal
            case presentation
        }

        public enum Sizing { // swiftlint:disable:this nesting
            case insetFromPresenter(UIEdgeInsets)
            case fixedSize(CGSize)
            case constrainingWidth(CGFloat)
        }

        public init(sizing: Sizing = .constrainingWidth(300), animationDuration: TimeInterval = 0.6, kind: Kind, roundsCorners: Bool = false) {
            self.sizing = sizing
            self.animationDuration = animationDuration
            self.kind = kind
            self.roundsCorners = roundsCorners
        }
    }
    
    /**
     This method will return a `UIViewControllerAnimatedTransitioning` with default `AnimationProperties`
     for the given `Kind`
     - Parameter kind: A value that represents the kind of transition you need.
     */
    static public func transitioningFor(kind: AnimationProperties.Kind) -> UIViewControllerAnimatedTransitioning {
        return transitioningFor(properties: MarqueePresentation.AnimationProperties(kind: kind))
    }
    
    /**
     This method will return a `UIViewControllerAnimatedTransitioning` with the given `AnimationProperties`
     - Parameter properties: The properties for the desired animation.
     */
    static public func transitioningFor(properties: AnimationProperties) -> UIViewControllerAnimatedTransitioning {
        switch properties.kind {
        case .dismissal:
            return MarqueeDismissController(properties: properties)
        case .presentation:
            return MarqueePresentationController(properties: properties)
        }
    }
}

fileprivate class MarqueePresentationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let properties: MarqueePresentation.AnimationProperties
    
    init(properties: MarqueePresentation.AnimationProperties) {
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
        let bgView = PresentationBackgroundView(frame: containerView.bounds)
        bgView.parentViewController = toViewController
        bgView.tag = Constants.BackgroundViewTag
        containerView.addSubview(bgView)
        
        // Add VC's view
        containerView.addSubview(toViewController.view)
        let vcView = toViewController.view!
        
        if self.properties.roundsCorners {
            vcView.roundCorners()
        }
        switch self.properties.sizing {
        case .fixedSize(let size):
            vcView.centerInSuperview()
            NSLayoutConstraint.activate([
                vcView.widthAnchor.constraint(equalToConstant: size.width),
                vcView.heightAnchor.constraint(equalToConstant: size.height),
                ])
        case .insetFromPresenter(let edges):
            vcView.pinToSuperview(withEdges: edges)
        case .constrainingWidth(let width):
            
            guard let calculable = toViewController as? IntrinsicSizeCalculable else {
                fatalError()
            }
            let intrinsicHeight = calculable.heightConstrainedTo(width: width)
            
            // This makes sure that the height of the
            // view fits in the current context
            let height = min(intrinsicHeight, containerView.bounds.height - 20)

            vcView.centerInSuperview()
            NSLayoutConstraint.activate([
                vcView.widthAnchor.constraint(equalToConstant: width),
                vcView.heightAnchor.constraint(equalToConstant: height),
                ])
        }
        
        toViewController.view.alpha = 0.0
        bgView.alpha = 0.0
        
        //Start slide up animation
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5 / 1.0,
                       options: [],
                       animations: {() -> Void in
                        toViewController.view.alpha = 1.0
                        bgView.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            transitionContext.completeTransition(true)
        })
    }
}

fileprivate class MarqueeDismissController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let properties: MarqueePresentation.AnimationProperties
    
    init(properties: MarqueePresentation.AnimationProperties) {
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
        
        UIView.animate(withDuration: properties.animationDuration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5 / 1.0,
                       options: [],
                       animations: {() -> Void in
                        bgView.alpha = 0.0
                        fromViewController.view.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

fileprivate enum Constants {
    static let BackgroundViewTag = 79
}
