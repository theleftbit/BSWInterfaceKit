//
//  RootViewController.swift
//  Created by Pierluigi Cifani on 15/09/2018.
//
#if canImport(UIKit)

import UIKit
import Task

@objc(BSWRootViewController)
final public class RootViewController: ContainerViewController {}

@objc(BSWContainerViewController)
open class ContainerViewController: UIViewController {
    
    public enum LayoutMode {
        case pinToSuperview
        case pinToSafeArea
    }
    
    public enum Appereance {
        static public var BackgroundColor: UIColor = .clear
    }
    
    private(set) public var containedViewController: UIViewController
    private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    public var layoutMode = LayoutMode.pinToSuperview
    
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

    open func updateContainedViewController(_ newVC: UIViewController) {
        
        guard newVC != containedViewController else { return }
        
        /// Make sure that if a user calls `updateContainedViewController:`
        /// before the animation is completed, the view hierarchy is in sync with
        /// what the user's trying to achieve, even with a crappy animation
        if animator.isRunning {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
        }
        
        // Notify current VC that time is up
        self.containedViewController.willMove(toParent: nil)
        
        // Add new VC
        self.addChild(newVC)
        self.view.insertSubview(newVC.view, belowSubview: self.containedViewController.view)
        switch layoutMode {
        case .pinToSuperview:
            newVC.view.pinToSuperview()
        case .pinToSafeArea:
            newVC.view.pinToSuperviewSafeLayoutEdges()
        }
        newVC.didMove(toParent: self)
        
        newVC.view.alpha = 0
        animator.addAnimations {
            self.containedViewController.view.alpha = 0
            newVC.view.alpha = 1
        }
        
        animator.addCompletion { (_) in
            self.containedViewController.view.removeFromSuperview()
            self.containedViewController.removeFromParent()
            self.containedViewController = newVC
        }
        animator.startAnimation()
    }
}
#endif
