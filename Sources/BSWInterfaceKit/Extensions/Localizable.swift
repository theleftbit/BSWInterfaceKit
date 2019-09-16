
import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: Bundle.interfaceKitBundle(), comment: "")
    }
}
