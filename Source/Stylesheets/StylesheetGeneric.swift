//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

class StylesheetGeneric: StylesheetConfigurable {
    
    static func typeface(typeface: Typeface) -> String {
        switch typeface {
        case .Regular:
            return "AvenirNext-Regular"
        case .DemiBold:
            return "AvenirNext-DemiBold"
        }
    }
    
    static func font(font: Font) -> UIFont {
        switch font {
        case .Display:
            return UIFont.font(type: typeface(.Regular), size: 32)
        case .Headline:
            return UIFont.font(type: typeface(.Regular), size: 20)
        case .Title:
            return UIFont.font(type: typeface(.DemiBold), size: 16)
        case .Body:
            return UIFont.font(type: typeface(.Regular), size: 16)
        case .Caption:
            return UIFont.font(type: typeface(.Regular), size: 14)
        case .ButtonText:
            return UIFont.font(type: typeface(.Regular), size: 18)
        }
    }
    
    static func margin(margin: Margin) -> Double {
        switch margin {
        case .Smallest:
            return 2.0
        case .Small:
            return 4.0
        case .Medium:
            return 8.0
        case .Big:
            return 12.0
        case .Bigger:
            return 20.0
        case .Biggest:
            return 32.0
        case .Huge:
            return 60.0
        }
    }

    static func colorState(color: ColorState) -> UIColor {
        switch color {
        case .Primary:
            return self.color(.Main)
        case .Negative:
            return self.color(.Negative)
        case .Positive:
            return self.color(.Positive)
        }
    }
}
