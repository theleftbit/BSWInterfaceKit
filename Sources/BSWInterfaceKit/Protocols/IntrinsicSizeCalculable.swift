//
//  IntrinsicSizing.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//

import UIKit

public protocol IntrinsicSizeCalculable {
    func heightConstrainedTo(width: CGFloat) -> CGFloat
}

@objc extension UINavigationController: IntrinsicSizeCalculable {
    public func heightConstrainedTo(width: CGFloat) -> CGFloat {
        guard let rootVC = self.viewControllers.first as? IntrinsicSizeCalculable else {
            fatalError()
        }
        let estimatedSize = rootVC.heightConstrainedTo(width: width)
        return estimatedSize + navigationBar.bounds.height
    }
}
