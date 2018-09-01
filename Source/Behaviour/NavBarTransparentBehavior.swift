//
//  Created by Pierluigi Cifani on 05/01/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

public enum NavBarState {
    case regular, transparent
}

final public class NavBarTransparentBehavior: NSObject {
    
    fileprivate static let LimitOffsetTransparentNavBar: CGFloat = 100
    
    fileprivate weak var navBar: UINavigationBar!
    fileprivate var observation: NSKeyValueObservation!
    fileprivate var state: NavBarState!
    fileprivate let defaultBackgroundImage: UIImage?
    fileprivate let defaultShadowImage: UIImage?
    let shouldShowShadow: Bool
    
    public init(navBar: UINavigationBar, scrollView: UIScrollView, shouldShowShadow: Bool) {
        self.defaultBackgroundImage = navBar.backgroundImage(for: .default)
        self.defaultShadowImage = navBar.shadowImage
        self.navBar = navBar
        self.shouldShowShadow = shouldShowShadow
        super.init()
        observation = scrollView.observe(\.contentOffset) { [weak self] (scrollView, _) in
            self?.updateNavBar(forScrollView: scrollView)
        }
        updateNavBar(forScrollView: scrollView)
    }

    deinit {
        observation.invalidate()
    }
    
    public func setNavBar(toState state: NavBarState) {
        guard state != self.state else { return }
        UIView.setAnimationsEnabled(false)
        NavBarTransparentBehavior.animate(navBar)
        
        let backgroundImage: UIImage? = {
            switch state {
            case .regular:
                return self.defaultBackgroundImage
            case .transparent:
                if shouldShowShadow {
                    let size = CGSize(width: 1, height: navBar.frame.maxY)
                    return GradientFactory.transparentGradient(size: size, isHorizontal: false)
                } else {
                    return UIImage()
                }
            }
        }()
        
        let shadowImage: UIImage? = {
            switch state {
            case .regular:
                return self.defaultShadowImage
                
            case .transparent:
                return UIImage()
            }
        }()

        navBar.shadowImage = shadowImage
        navBar.setBackgroundImage(backgroundImage, for: .default)
        navBar.isTranslucent = true
        UIView.setAnimationsEnabled(true)
        
        self.state = state
    }

    fileprivate func updateNavBar(forScrollView scrollView: UIScrollView) {
        if scrollView.contentOffset.y < NavBarTransparentBehavior.LimitOffsetTransparentNavBar {
            setNavBar(toState: .transparent)
        }
        else {
            setNavBar(toState: .regular)
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
}

extension NavBarTransparentBehavior: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavBar(forScrollView: scrollView)
    }
}
