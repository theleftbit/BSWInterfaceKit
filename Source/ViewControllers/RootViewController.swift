//
//  RootViewController.swift
//  Created by Pierluigi Cifani on 15/09/2018.
//

import UIKit

public class RootViewController: UIViewController {

    public var containedViewController: UIViewController
    
    public init(containedViewController: UIViewController) {
        self.containedViewController = containedViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addChild(containedViewController)
        view.addAutolayoutSubview(containedViewController.view)
        containedViewController.view.pinToSuperview()
        containedViewController.didMove(toParent: self)
    }
    
    public func updateContainerViewController(_ newVC: UIViewController) {
        
        UIView.transition(
            with: self.view,
            duration: 0.45,
            options: [.transitionFlipFromLeft],
            animations: {
                self.containedViewController.willMove(toParent: nil)
                self.containedViewController.view.removeFromSuperview()
                self.containedViewController.removeFromParent()
                
                self.addChild(newVC)
                self.view.addAutolayoutSubview(newVC.view)
                newVC.view.pinToSuperview()
                newVC.didMove(toParent: self)
                
                self.containedViewController = newVC
        },
            completion: { (_) in

        })
    }
}
