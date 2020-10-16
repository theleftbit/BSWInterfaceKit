//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import UIKit

public extension UIFont {
        
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    func bolded() -> UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: pointSize)
    }
}

#endif
