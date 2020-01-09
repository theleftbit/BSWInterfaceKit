//
//  Created by Pierluigi Cifani on 09/01/2020.
//
#if canImport(UIKit)

import UIKit

public extension UIButton {
    func setPrefersImageOnTheRight() {
        semanticContentAttribute = .forceRightToLeft
    }
}

#endif
