//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

class StylesheetGeneric: StylesheetConfigurable {
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
}
