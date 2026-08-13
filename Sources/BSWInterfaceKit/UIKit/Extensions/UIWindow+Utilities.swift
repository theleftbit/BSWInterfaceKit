//
//  Created by Pierluigi Cifani on 16/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit.UIWindow)

import UIKit
import BSWFoundation

public extension UIWindow {

    @objc(bsw_visibleViewController)
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    @objc(bsw_getVisibleViewControllerFrom:)
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }

    @objc(bsw_showErrorAlert:error:)
    func showErrorAlert(_ message: String, error: Error) {
        guard let rootViewController = self.visibleViewController else { return }
        rootViewController.showErrorAlert(message, error: error)
    }
}

#endif
