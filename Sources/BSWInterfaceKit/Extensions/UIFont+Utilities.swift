//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public extension UIFont {
        
    var bolded: UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: pointSize)
    }
}
