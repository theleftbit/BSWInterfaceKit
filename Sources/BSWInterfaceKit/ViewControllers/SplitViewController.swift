
#if canImport(UIKit)

import UIKit

/// Saner implementation of `UISplitViewController` that manages navigation stacks for you.
/// To set a detail VC, call `showDetailViewController()` from any contained
/// viewController and it will be set as the detail (clearing out any shown detail if visible).
/// It will automatically add all the VCs  from the detail navigation stack onto the master
/// navigation stack when transitioning  to a compact environment.
@objc(BSWSplitViewController)
open class SplitViewController: UIViewController {
    
    public let masterNavigationController: UINavigationController
    public let detailNavigationController: UINavigationController
    private let emptyVC = EmptyViewController()
    
    public init(masterViewController: UIViewController) {
        self.masterNavigationController = MasterNavigationController(rootViewController: masterViewController)
        self.detailNavigationController = DetailNavigationController(rootViewController: emptyVC)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        let separatorView = UIView()
        if #available(iOS 13.0, *) {
            separatorView.backgroundColor = .separator
        } else {
            separatorView.backgroundColor = .black
        }

        addChild(masterNavigationController)
        addChild(detailNavigationController)
        view.addAutolayoutSubview(masterNavigationController.view)
        view.addAutolayoutSubview(detailNavigationController.view)
        view.addAutolayoutSubview(separatorView)
        
        let idealWidthConstraint = masterNavigationController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3) // To be customized
        idealWidthConstraint.priority = .defaultHigh
        
        let minWidthConstraint = masterNavigationController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 320) // To be customized
        minWidthConstraint.priority = .required

        addConstraintsForHorizontal(
            compactSizeClass: [
                masterNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                masterNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
                masterNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                masterNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ],
            regularSizeClass: [
                masterNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                masterNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
                masterNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                masterNavigationController.view.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor),

                separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                separatorView.topAnchor.constraint(equalTo: view.topAnchor),
                separatorView.trailingAnchor.constraint(equalTo: detailNavigationController.view.leadingAnchor),
                separatorView.widthAnchor.constraint(equalToConstant: 1),

                detailNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
                detailNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                detailNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                idealWidthConstraint,
                minWidthConstraint
            ]
        )
        masterNavigationController.didMove(toParent: self)
        detailNavigationController.didMove(toParent: self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Master VC will always be compact.
        setOverrideTraitCollection(
            UITraitCollection(horizontalSizeClass: .compact),
            forChild: masterNavigationController
        )
        
        /// As of the Detail VC, I've found that on the smallest iPad, even in portrait
        /// the view is more than 440pts in width. I think that's enough to handle
        /// regular layouts https://i.imgur.com/i7bvrKg.jpg
        /// If that's not the case, any VC can customize this, calling `setOverrideTraitCollection`
    }
    
    override public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        switch (traitCollection.horizontalSizeClass, newCollection.horizontalSizeClass) {
        case (.regular, .compact):
            let detailVCs = detailNavigationController.viewControllers
            guard detailVCs != [emptyVC] else { return }
            detailNavigationController.setViewControllers([emptyVC], animated: false)
            detailVCs.forEach {
                masterNavigationController.pushViewController($0, animated: false)
            }
        case (.compact, .regular):
            if let detailVCs = masterNavigationController.popToRootViewController(animated: false) {
                detailNavigationController.setViewControllers(detailVCs, animated: false)
            }
        default:
            break
        }
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        if traitCollection.horizontalSizeClass == .regular {
            detailNavigationController.setViewControllers([vc], animated: false)
        } else {
            masterNavigationController.show(vc, sender: sender)
        }
    }

    public class DetailNavigationController: UINavigationController { }
    
    public class MasterNavigationController: UINavigationController {
        override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
            if let splitVC = parent as? SplitViewController {
                splitVC.showDetailViewController(vc, sender: sender)
            } else {
                show(vc, sender: sender)
            }
        }
    }
    
    public class EmptyViewController: UIViewController {
        override public func loadView() {
            view = UIView()
            if #available(iOS 13.0, *) {
                view.backgroundColor = .systemBackground
            } else {
                view.backgroundColor = .white
            }
        }
    }
}

public extension UIViewController {
    var bswSplitViewController: SplitViewController? {
        return (next() as SplitViewController?)
    }
}

#endif
