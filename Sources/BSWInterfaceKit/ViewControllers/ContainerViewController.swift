//
//  RootViewController.swift
//  Created by Pierluigi Cifani on 15/09/2018.
//
#if canImport(UIKit.UIViewController)

import UIKit

/// Use this `UIViewController` subclass as the `rootViewController` of your `UIWindow` in order to transition between states of your app with more ease.
@objc(BSWRootViewController)
final public class RootViewController: ContainerViewController {}

/// Use this `UIViewController` in order to transition between states of your view with more ease.
@objc(BSWContainerViewController)
open class ContainerViewController: UIViewController {
    
    /// Describes how the `containedViewController` will be layed out.
    public enum LayoutMode {
        case pinToSuperview
        case pinToSafeArea
    }
    
    @MainActor
    public enum Appereance {
        static public var BackgroundColor: UIColor = .clear
    }
    
    private(set) public var containedViewController: UIViewController
    private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    public var layoutMode = LayoutMode.pinToSuperview
    
    /// Initializes this class with an empty `UIViewController`
    public convenience init() {
        self.init(containedViewController: UIViewController())
    }
    
    /// Initializes this class with the given `UIViewController`
    public init(containedViewController: UIViewController) {
        self.containedViewController = containedViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appereance.BackgroundColor
        containViewController(containedViewController)
    }
    
    open override var childForStatusBarStyle: UIViewController? { containedViewController }
    open override var childForStatusBarHidden: UIViewController? { containedViewController }
    open override var childForHomeIndicatorAutoHidden: UIViewController? { containedViewController }
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? { containedViewController }
    open override var navigationItem: UINavigationItem {
        return containedViewController.navigationItem
    }
    open override var isModalInPresentation: Bool {
        get {
            containedViewController.isModalInPresentation
        } set {
            containedViewController.isModalInPresentation = newValue
        }
    }

    /// Changes the displayed `UIViewController`.
    /// - Parameters:
    ///   - newVC: The new `UIViewController` to display
    ///   - animated: If the change should be animated
    open func updateContainedViewController(_ newVC: UIViewController, animated: Bool = true) {
        
        guard newVC != containedViewController else { return }
        
        /// Make sure that if a user calls `updateContainedViewController:`
        /// before the animation is completed, the view hierarchy is in sync with
        /// what the user's trying to achieve, even with a crappy animation
        if animator.isRunning {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
        }
        
        // Notify current VC that time is up
        let oldVC = self.containedViewController
        oldVC.willMove(toParent: nil)
        
        /// Store a reference to the new guy in town
        self.containedViewController = newVC
        
        // Add new VC
        self.addChild(newVC)
        self.view.insertSubview(newVC.view, belowSubview: oldVC.view)
        switch layoutMode {
        case .pinToSuperview:
            newVC.view.pinToSuperview()
        case .pinToSafeArea:
            newVC.view.pinToSuperviewSafeLayoutEdges()
        }
        newVC.didMove(toParent: self)
        
        let completion = {
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
        
        if (animated) {
            newVC.view.alpha = 0
            animator.addAnimations {
                oldVC.view.alpha = 0
                newVC.view.alpha = 1
            }
            
            animator.addCompletion { _ in
                completion()
            }
            animator.startAnimation()
        } else {
            completion()
        }
        
        /// This is a workaround for an issue where the `containedViewController`'s navigationItem wasn't
        /// being correctly synced with the contents of the navigation bar. This will make sure to force an update to
        /// it, making the contents of the navigationBar correct after every `updateContainedViewController`.
        if let navBarHidden = self.navigationController?.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(!navBarHidden, animated: false)
            self.navigationController?.setNavigationBarHidden(navBarHidden, animated: false)
        }
    }
}
#endif
