//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

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
