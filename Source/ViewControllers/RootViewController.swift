//
//  RootViewController.swift
//  Created by Pierluigi Cifani on 15/09/2018.
//

@available(iOS 11.0, *) @objc(BSWRootViewController)
final public class RootViewController: ContainerViewController {}

@available(iOS 11.0, *) @objc(BSWContainerViewController)
open class ContainerViewController: UIViewController {
    
    public enum Appereance {
        static public var BackgroundColor: UIColor = .clear
    }
    
    private(set) public var containedViewController: UIViewController
    private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    
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
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return containedViewController.preferredStatusBarStyle
    }
    
    open func updateContainedViewController(_ newVC: UIViewController) {
        
        // Notify current VC that time is up
        self.containedViewController.willMove(toParent: nil)
        
        // Add new VC
        self.addChild(newVC)
        self.view.insertSubview(newVC.view, belowSubview: self.containedViewController.view)
        newVC.view.pinToSuperview()
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
