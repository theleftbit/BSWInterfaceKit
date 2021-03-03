//
//  UIViewController+States.swift
//  Created by Pierluigi Cifani on 15/09/2018.
//
#if canImport(UIKit)

import UIKit

// MARK: - Error and Loading
@nonobjc
extension UIViewController {
    
    public enum StateViewLayout {
        case pinToSuperview
        case pinToSuperviewLayoutMargins
        case setFrame(CGRect)
    }
    
    // MARK: - Loaders
    public func showLoadingView(_ loadingView: UIView, animated: Bool = true, stateViewLayout: StateViewLayout = .pinToSuperview) {
        self.addStateView(loadingView, animated: animated, stateViewLayout: stateViewLayout)
    }
    
    public func showLoader(stateViewLayout: StateViewLayout = .pinToSuperview, animated: Bool = true) {
        self.showLoadingView(LoadingView(), animated: animated, stateViewLayout: stateViewLayout)
    }
    
    public func hideLoader(stateViewFrame: CGRect? = nil, animated: Bool = true) {
        self.removeStateView(animated: animated)
    }
    
    public func showErrorView(_ errorView: UIView, animated: Bool = true, stateViewLayout: StateViewLayout = .pinToSuperview) {
        self.addStateView(errorView, animated: animated, stateViewLayout: stateViewLayout)
    }
    
    public func showErrorMessage(_ message: String, error: Error, retryButton: ButtonConfiguration? = nil, animated: Bool = true, stateViewFrame: CGRect? = nil) {
        
        let errorMessage: String = {
            if UIViewController.enhancedErrorAlertMessage {
                return "\(message) \nError code: \(error.localizedDescription)"
            } else {
                return message
            }
        }()
        
        let styler = TextStyler.styler
        let errorView = ErrorView(
            title: styler.attributedString("Error").bolded,
            message: styler.attributedString(errorMessage),
            buttonConfiguration: retryButton
        )
        showErrorView(errorView, animated: animated)
    }
    
    public func hideError(animated: Bool = true) {
        self.removeStateView(animated: animated)
    }
    
    private func addStateView(_ stateView: UIView, animated: Bool = true, stateViewLayout: StateViewLayout) {
        let stateVC = StateContainerViewController(
            stateView: stateView,
            backgroundColor: self.view.backgroundColor ?? .clear
        )
        if let containerVC = self as? ContainerViewController {
            containerVC.updateContainedViewController(stateVC)
            return
        }
        removeStateView(animated: animated)
        addChild(stateVC)
        view.addSubview(stateVC.view)
        switch stateViewLayout {
        case .pinToSuperview:
            stateVC.view.pinToSuperview()
        case .pinToSuperviewLayoutMargins:
            stateVC.view.pinToSuperviewLayoutMargins()
        case .setFrame(let frame):
            stateVC.view.frame = frame
        }
        stateVC.didMove(toParent: self)
        guard animated, let animator = StateContainerAppereance.transitionConfiguration?.animator else { return }
        stateVC.view.alpha = 0
        animator.addAnimations {
            stateVC.view.alpha = 1
        }
        animator.startAnimation()
    }
    
    private func removeStateView(animated: Bool = true) {
        guard let stateContainer = self.stateContainer else { return }
        guard animated, let animator = StateContainerAppereance.transitionConfiguration?.animator else {
            removeContainedViewController(stateContainer)
            return
        }
        stateContainer.willMove(toParent: nil)
        stateContainer.removeFromParent()
        stateContainer.view.alpha = 1
        animator.addAnimations {
            stateContainer.view.alpha = 0
        }
        animator.addCompletion { (_) in
            stateContainer.view.removeFromSuperview()
        }
        animator.startAnimation()
    }
    
    
    private var stateContainer: StateContainerViewController? {
        return self.children.compactMap({ return $0 as? StateContainerViewController }).first
    }
}

public enum StateContainerAppereance {
    public static var padding: CGFloat = 20
    public static var transitionConfiguration: TransitionConfiguration?

    public struct TransitionConfiguration {
        public let duration: TimeInterval
        public let curve: UIView.AnimationCurve

        public init(duration: TimeInterval, curve: UIView.AnimationCurve) {
            self.duration = duration
            self.curve = curve
        }

        public static func simple() -> TransitionConfiguration {
            return .init(duration: 0.3, curve: .easeInOut)
        }
        
        public var animator: UIViewPropertyAnimator {
            return .init(duration: duration, curve: curve)
        }
    }
}

@objc(BSWStateContainerViewController)
private class StateContainerViewController: UIViewController {
    
    let stateView: UIView
    let backgroundColor: UIColor
    init(stateView: UIView, backgroundColor: UIColor) {
        self.stateView = stateView
        self.backgroundColor = backgroundColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc(BSWStateContainerView)
    private class StateContainerView: UIView {}
    
    override func loadView() {
        view = StateContainerView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = self.backgroundColor
        view.addAutolayoutSubview(stateView)
        stateView.centerInSuperview()
        NSLayoutConstraint.activate([
                stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: StateContainerAppereance.padding),
                stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -StateContainerAppereance.padding),
            ])
    }
}
#endif
