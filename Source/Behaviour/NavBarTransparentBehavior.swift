//
//  Created by Pierluigi Cifani on 05/01/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

enum NavBarState {
    case regular, transparent
    
    var backgroundImage: UIImage? {
        switch self {
        case .regular:
            return nil
        case .transparent:
            return NavBarTransparentBehavior.transparentGradientImage()
        }
    }
    
    var shadowImage: UIImage? {
        switch self {
        case .regular:
            return nil
        case .transparent:
            return UIImage()
        }
    }
}

final public class NavBarTransparentBehavior: NSObject {
    
    fileprivate static let heightOfNavBarAndStatusBar = 64
    fileprivate static let limitOffsetTransparentNavBar = 100
    
    fileprivate weak var navBar: UINavigationBar!
    fileprivate var observation: NSKeyValueObservation!

    init(navBar: UINavigationBar, scrollView: UIScrollView) {
        self.navBar = navBar
        super.init()
        observation = scrollView.observe(\.contentOffset) { [weak self] (scrollView, _) in
            self?.updateNavBar(forScrollView: scrollView)
        }
        updateNavBar(forScrollView: scrollView)
    }

    deinit {
        observation.invalidate()
    }
    
    func setNavBar(toState state: NavBarState) {
        guard let navBar = navBar else { return }
        guard currentState(forNavBar: navBar) != state else { return }
        UIView.setAnimationsEnabled(false)
        NavBarTransparentBehavior.animate(navBar)
        navBar.shadowImage = state.shadowImage
        navBar.setBackgroundImage(state.backgroundImage, for: .default)
        UIView.setAnimationsEnabled(true)
    }

    fileprivate func updateNavBar(forScrollView scrollView: UIScrollView) {
        if scrollView.contentOffset.y < CGFloat(NavBarTransparentBehavior.limitOffsetTransparentNavBar) {
            setNavBar(toState: .transparent)
        }
        else {
            setNavBar(toState: .regular)
        }
    }
    
    fileprivate func currentState(forNavBar navBar: UINavigationBar) -> NavBarState {
        if navBar.backgroundImage(for: .default) != nil {
            return .transparent
        }
        else {
            return .regular
        }
    }
    
    fileprivate static func animate(_ navBar: UINavigationBar) {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.fade
        transition.duration = 0.3
        transition.isRemovedOnCompletion = true
        navBar.layer.add(transition, forKey: nil)
    }
    
    fileprivate static func transparentGradientImage() -> UIImage {
        let colorTop = UIColor(white: 0.1, alpha: 0.5)
        let colorBottom = UIColor(white: 0.1, alpha: 0.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1, height: heightOfNavBarAndStatusBar)
        gradientLayer.colors = [colorTop, colorBottom].map {$0.cgColor}
        gradientLayer.locations = [0.0, 1.0]
        return UIImage.image(fromGradientLayer: gradientLayer)
    }
}

extension NavBarTransparentBehavior: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavBar(forScrollView: scrollView)
    }
}
