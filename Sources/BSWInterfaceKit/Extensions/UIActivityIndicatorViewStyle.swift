//
//  Created by Pierluigi Cifani on 30/10/2019.
//
#if canImport(UIKit)

import UIKit

public extension UIActivityIndicatorView.Style {
    static var defaultStyle: UIActivityIndicatorView.Style {
        return .medium
        #if os(tvOS)
        return .whiteLarge
        #endif
    }
}
#endif
