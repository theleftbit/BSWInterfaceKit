//
//  Created by Pierluigi Cifani on 12/07/2018.
//
#if canImport(UIKit)

import UIKit

@available(iOSApplicationExtension, unavailable)
extension UITextField {
    
    static func autolayoutTextFieldWith(textStyle style: UIFont.TextStyle, placeholderText: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = TextStyler.styler.fontForStyle(style)
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.placeholder = placeholderText
        return textField
    }
}

#endif
