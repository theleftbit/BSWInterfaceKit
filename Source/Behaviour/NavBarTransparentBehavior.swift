//
//  Created by Pierluigi Cifani on 05/01/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

enum NavBarState {
    case Regular, Transparent
    
    var backgroundImage: UIImage? {
        switch self {
        case .Regular:
            return nil
        case .Transparent:
            return NavBarTransparentBehavior.transparentGradientImage()
        }
    }
    
    var shadowImage: UIImage? {
        switch self {
        case .Regular:
            return nil
        case .Transparent:
            return UIImage()
        }
    }
}

final public class NavBarTransparentBehavior: NSObject {
    
    private static let heightOfNavBarAndStatusBar = 64
    private static let limitOffsetTransparentNavBar = 100
    
    private weak var navBar: UINavigationBar?

    init(navBar: UINavigationBar, scrollView: UIScrollView) {
        self.navBar = navBar
        super.init()
        scrollView.delegate = self
        
        updateNavBar(forScrollView: scrollView)
    }
    
    func setNavBar(toState state: NavBarState) {
        guard let navBar = navBar else { return }
        guard currentState(forNavBar: navBar) != state else { return }
        UIView.setAnimationsEnabled(false)
        NavBarTransparentBehavior.animate(navBar)
        navBar.shadowImage = state.shadowImage
        navBar.setBackgroundImage(state.backgroundImage, forBarMetrics: .Default)
        UIView.setAnimationsEnabled(true)
    }

    private func updateNavBar(forScrollView scrollView: UIScrollView) {
        guard let _ = navBar else { return }
        if scrollView.contentOffset.y < CGFloat(NavBarTransparentBehavior.limitOffsetTransparentNavBar) {
            setNavBar(toState: .Transparent)
        }
        else {
            setNavBar(toState: .Regular)
        }
    }
    
    private func currentState(forNavBar navBar: UINavigationBar) -> NavBarState {
        if navBar.backgroundImageForBarMetrics(.Default) != nil {
            return .Transparent
        }
        else {
            return .Regular
        }
    }
    
    private static func animate(navBar: UINavigationBar) {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        transition.duration = 0.3
        transition.removedOnCompletion = true
        navBar.layer.addAnimation(transition, forKey: nil)
    }
    
    private static func transparentGradientImage() -> UIImage {
        let colorTop = UIColor(white: 0.1, alpha: 0.5)
        let colorBottom = UIColor(white: 0.1, alpha: 0.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1, height: heightOfNavBarAndStatusBar)
        gradientLayer.colors = [colorTop, colorBottom].map{$0.CGColor}
        gradientLayer.locations = [0.0, 1.0]
        return UIImage.image(fromGradientLayer: gradientLayer)
    }
}

extension NavBarTransparentBehavior: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let _ = navBar else { return }
        updateNavBar(forScrollView: scrollView)
    }
}
