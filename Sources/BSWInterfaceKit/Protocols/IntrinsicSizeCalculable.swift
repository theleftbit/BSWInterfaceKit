//
//  IntrinsicSizing.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//

#if canImport(UIKit)

import UIKit

/// Describes a type where we can estimate it's height given a width.
public protocol IntrinsicSizeCalculable {
    /// Returns the `width` from a given `height`
    func heightConstrainedTo(width: CGFloat) -> CGFloat
}

public extension IntrinsicSizeCalculable where Self: UIView {
    func heightConstrainedTo(width: CGFloat) -> CGFloat {
        let estimatedSize = self.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return estimatedSize.height
    }
}

public extension IntrinsicSizeCalculable where Self: UICollectionViewCell {
    func heightConstrainedTo(width: CGFloat) -> CGFloat {
        let estimatedSize = self.contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return estimatedSize.height
    }
}

public extension IntrinsicSizeCalculable where Self: UIViewController {
    func heightConstrainedTo(width: CGFloat) -> CGFloat {
        let estimatedSize = self.view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return estimatedSize.height
    }
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

#endif
