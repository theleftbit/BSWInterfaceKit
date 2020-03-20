//
//  Created by Pierluigi Cifani on 09/01/2020.
//
#if canImport(UIKit)

import UIKit

public extension UIButton {
    func setPrefersImageOnTheRight() {
        semanticContentAttribute = .forceRightToLeft
    }
    
    func prepareForMultiline(maxWidth: CGFloat, horizontalAlignment: UIControl.ContentHorizontalAlignment = .left) {
        guard let label = titleLabel else { return }
        heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.preferredMaxLayoutWidth = maxWidth
        contentHorizontalAlignment = horizontalAlignment
    }

}

#endif
