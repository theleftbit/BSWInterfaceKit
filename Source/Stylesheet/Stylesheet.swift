//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

enum Typeface {
    case Regular
    case DemiBold
}

enum Font {
    case Display
    case Headline
    case Title
    case Body
    case Caption
    case ButtonText
}

enum Margin {
    case Smallest
    case Small
    case Medium
    case Big
    case Bigger
    case Biggest
    case Huge
}

enum ColorState {
    case Primary
    case Negative
    case Positive
}

protocol StylesheetConfigurable {
    /**
     Returns the typo name (as String) for the specified Typeface
     
     - parameter typeface: The Typo type
     
     - returns: The typo name based on the specified Typeface
     */
    static func typeface(typeface: Typeface) -> String
    
    /**
     Returns the UIFont object for the specified Font
     
     - parameter font: The Font type
     
     - returns: The UIFont object based on the specified Font
     */
    static func font(font: Font) -> UIFont

    /**
     Returns the Double value for the specified Margin
     
     - parameter margin: The Margin type
     
     - returns: The margin value based on the specified Margin
     */
    static func margin(margin: Margin) -> Double
}

extension StylesheetConfigurable {
    /**
     Returns the CGFloat value for the specified Margin
     
     - parameter margin: The Margin type
     
     - returns: The margin value based on the specified Margin
     */
    static func margin(margin: Margin) -> CGFloat {
        return CGFloat(self.margin(margin))
    }
}

/// Returns the current stylesheet
var Stylesheet: StylesheetConfigurable.Type {
    return StylesheetGeneric.self
}
