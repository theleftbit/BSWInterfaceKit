//
//  UIScreen+Utilities.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//
#if canImport(UIKit.UIScreen)

import UIKit

public extension UIScreen {
    var isSmallScreen: Bool {
        return self.bounds.width == 320
    }
    var isTallScreen: Bool {
        return self.bounds.height >= 800
    }
}
#endif
