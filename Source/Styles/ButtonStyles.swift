//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension UIButton {
    func configureAsCheckbox() {
        self.contentMode = .ScaleAspectFit
        self.setImage(UIImage(named: "ic_checkbox"), forState: .Normal)
        self.setImage(UIImage(named: "ic_checkbox_selected"), forState: .Selected)
    }
}

// TODO: Structure pending to be confirmed

protocol ButtonStyleTemplate {
    var font: UIFont { get }
    var backgroundColor: UIColor { get }
}

enum ButtonStyle: ButtonStyleTemplate {
    case Primary, Secondary, Negative
    
    var font: UIFont { return currentButton.font }
    var backgroundColor: UIColor { return currentButton.backgroundColor }
    
    var currentButton: ButtonStyleTemplate {
        switch self {
        case .Primary:
            return buttonPrimary()
        case .Secondary:
            return buttonSecondary()
        case .Negative:
            return buttonNegative()
        }
    }
}

struct buttonPrimary: ButtonStyleTemplate {
    var font: UIFont = Stylesheet.font(.ButtonText)
    var backgroundColor: UIColor = Stylesheet.colorState(.Primary)
}

struct buttonSecondary: ButtonStyleTemplate {
    var font: UIFont = Stylesheet.font(.ButtonText)
    var backgroundColor: UIColor = Stylesheet.color(.Grey5)
}

struct buttonNegative: ButtonStyleTemplate {
    var font: UIFont = Stylesheet.font(.ButtonText)
    var backgroundColor: UIColor = Stylesheet.colorState(.Negative)
}
