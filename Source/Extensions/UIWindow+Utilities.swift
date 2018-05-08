//
//  Created by Pierluigi Cifani on 16/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public extension UIWindow {

    @objc(bsw_visibleViewController)
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    @objc(bsw_getVisibleViewControllerFrom:)
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
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

    @objc(bsw_showErrorMessage:error:)
    public func showErrorMessage(_ message: String, error: Error) {
        guard let rootViewController = self.visibleViewController else { return }
        rootViewController.showErrorMessage(message, error: error)
    }
}
