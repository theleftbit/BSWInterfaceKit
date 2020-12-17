
#if canImport(UIKit)

import UIKit

@available(macCatalyst, unavailable)
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

#endif
