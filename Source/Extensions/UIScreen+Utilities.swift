//
//  UIScreen+Utilities.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//

import UIKit

public extension UIScreen {
    var isSmallScreen: Bool {
        return self.bounds.width == 320
    }
}
