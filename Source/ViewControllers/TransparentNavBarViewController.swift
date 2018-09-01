//
//  Created by Pierluigi Cifani on 20/07/2018.
//  Copyright © 2018 Dada. All rights reserved.
//

import UIKit

open class TransparentNavBarViewController: UIViewController {
    
    open var shouldShowNavBarShadow: Bool = true
    public var navBarBehaviour: NavBarTransparentBehavior?
    public let scrollableStackView = ScrollableStackView()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let containerView = HostView()
        view.addSubview(containerView)
        containerView.pinToSuperview()
        
        containerView.addSubview(scrollableStackView)
        scrollableStackView.pinToSuperview()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navController = self.navigationController else {
            fatalError()
        }
        navBarBehaviour = NavBarTransparentBehavior(navBar: navController.navigationBar, scrollView: scrollableStackView, shouldShowShadow: shouldShowNavBarShadow)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navBarBehaviour?.setNavBar(toState: .regular)
        navBarBehaviour = nil
    }
}

extension TransparentNavBarViewController {
    
    // This prevents UIKit to layout the
    // subviews below the navBar
    @objc(BSWTransparentNavBarViewHost)
    private class HostView: UIView {
        @available(iOS 11.0, *)
        override fileprivate var safeAreaInsets: UIEdgeInsets {
            let superSafeArea = super.safeAreaInsets
            return UIEdgeInsets(top: 0, left: superSafeArea.left, bottom: superSafeArea.bottom, right: superSafeArea.right)
        }
    }
    
}
