//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

enum Margin {
    case smallest
    case small
    case medium
    case big
    case bigger
    case biggest
    case huge
}

enum ColorState {
    case primary
    case negative
    case positive
}

protocol StylesheetConfigurable {

    /**
     Returns the Double value for the specified Margin
     
     - parameter margin: The Margin type
     
     - returns: The margin value based on the specified Margin
     */
    static func margin(_ margin: Margin) -> Double
}

extension StylesheetConfigurable {
    /**
     Returns the CGFloat value for the specified Margin
     
     - parameter margin: The Margin type
     
     - returns: The margin value based on the specified Margin
     */
    static func margin(_ margin: Margin) -> CGFloat {
        return CGFloat(self.margin(margin))
    }
}

/// Returns the current stylesheet
var Stylesheet: StylesheetConfigurable.Type {
    return StylesheetGeneric.self
}
