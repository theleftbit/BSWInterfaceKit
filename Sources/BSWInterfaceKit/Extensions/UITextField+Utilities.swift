//
//  Created by Pierluigi Cifani on 12/07/2018.
//

import UIKit

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
