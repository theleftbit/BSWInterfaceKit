//
//  Created by Pierluigi Cifani on 01/10/2018.
//  Copyright © 2018 TheLeftBit. All rights reserved.
//

import UIKit

@available(iOS 11.0, *) @objc(BSWBottomContainerViewController)
open class BottomContainerViewController: UIViewController {
    
    public let containedViewController: UIViewController
    public var button: UIButton? {
        guard case .button(let button, _) = bottomViewKind else {
            return nil
        }
        return button
    }
    public var bottomController: UIViewController? {
        guard case .controller(let controller) = bottomViewKind else {
            return nil
        }
        return controller
    }
    private let bottomViewKind: BottomViewKind
    private var buttonContainer: UIViewController!
    private var bottomConstraint: NSLayoutConstraint!
    
    private enum BottomViewKind {
        case button(UIButton, UIEdgeInsets)
        case controller(UIViewController)
    }
    
    public init(containedViewController: UIViewController, button: UIButton, margins: UIEdgeInsets = .zero) {
        self.containedViewController = containedViewController
        self.bottomViewKind = .button(button, margins)
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(containedViewController: UIViewController, bottomViewController: UIViewController) {
        self.containedViewController = containedViewController
        self.bottomViewKind = .controller(bottomViewController)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        view = UIView()
        
        addChild(containedViewController)
        view.addAutolayoutSubview(containedViewController.view)
        
        switch self.bottomViewKind {
        case .button(let button, let margins):
            buttonContainer = ButtonContainerViewController(button: button, margins: margins)
        case .controller(let controller):
            buttonContainer = controller
        }
        addChild(buttonContainer)
        view.addAutolayoutSubview(buttonContainer.view)
        bottomConstraint = buttonContainer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            containedViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            containedViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containedViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containedViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonContainer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            ])
        containedViewController.didMove(toParent: self)
        buttonContainer.didMove(toParent: self)
    }
    
    open override func viewInitialLayoutDidComplete() {
        super.viewInitialLayoutDidComplete()
        let safeAreaFrame = self.view.safeAreaLayoutGuide.layoutFrame
        let inset = safeAreaFrame.origin.y + safeAreaFrame.size.height - buttonContainer.view.frame.minY
        containedViewController.additionalSafeAreaInsets = UIEdgeInsets(dictionaryLiteral: (.bottom, inset))
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return containedViewController.preferredStatusBarStyle
    }
    
    open override var navigationItem: UINavigationItem {
        return containedViewController.navigationItem
    }
    
    open override var title: String? {
        get {
            return containedViewController.title
        } set {
            containedViewController.title = newValue
        }
    }
    
    // Normally, this VC is embedded in a container like SplitVC or NavVC.
    // In that case,  we should forward all actions to it so it can handle
    // stuff like `showViewController:sender:` or `showDetailViewController:sender:`
    // If that's not the case, we forward the method to the containedVC (the top one)
    // which should handle it.
    open override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        
        // Actions should be forwarded from smaller
        // container to bigger container, that's why
        // if we have a navVC, that's who should handle
        // it **before** we let splitVC have a say
        if let navVC = navigationController {
            return navVC
        } else if let splitVC = splitViewController {
            return splitVC
        } else {
            return containedViewController
        }
    }

    @objc(BSWButtonContainerViewController)
    private class ButtonContainerViewController: UIViewController {
        
        let button: UIButton
        let margins: UIEdgeInsets
        
        init(button: UIButton, margins: UIEdgeInsets) {
            self.button = button
            self.margins = margins
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addAutolayoutSubview(button)
            button.pinToSuperview(withEdges: margins)
        }
    }
}

extension BottomContainerViewController: IntrinsicSizeCalculable {
    
    public func heightConstrainedTo(width: CGFloat) -> CGFloat {
        self.loadViewIfNeeded()
        let children = [self.containedViewController, self.buttonContainer!]
        return children.reduce(0) { value, childVC -> CGFloat in
            if let childVC = childVC as? IntrinsicSizeCalculable {
                return value + childVC.heightConstrainedTo(width: width)
            }
            return value + childVC.view.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel).height
        }
    }
}


@available(iOS 11.0, *)
public extension UIViewController {
    var bottomContainerViewController: BottomContainerViewController? {
        return self.parent as? BottomContainerViewController
    }
}

//MARK: Animations

public extension BottomContainerViewController {
    
    enum Animation {
        case custom(spacing: CGFloat)
        case hideBottomController
        case showBottomController
    }
    
    func performAnimation(_ animation: Animation, animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 3, curve: .easeInOut, animations: nil)) {

        switch animation {
        case .hideBottomController:
            bottomConstraint.constant = buttonContainer.view.frame.height
        case .showBottomController:
            bottomConstraint.constant = 0
        case .custom(let spacing):
            bottomConstraint.constant = spacing
        }
        animator.addAnimations {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
