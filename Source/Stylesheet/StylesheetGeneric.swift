//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

class StylesheetGeneric: StylesheetConfigurable {
    static func margin(_ margin: Margin) -> Double {
        switch margin {
        case .smallest:
            return 2.0
        case .small:
            return 4.0
        case .medium:
            return 8.0
        case .big:
            return 12.0
        case .bigger:
            return 20.0
        case .biggest:
            return 32.0
        case .huge:
            return 60.0
        }
    }
}
