//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension UIFont {
    
    /**
     Returns a font using a custom type and a font size.
     This method is a workaround to avoid return an optional font. #solid
     
     - parameter fontType: The custom font type (as string)
     - parameter fontSize: The size (in points) to which the font is scaled.
     
     - returns: A font object of the specified name and size.
     */
    static func font(type fontType: String, size fontSize: Double) -> UIFont {
        if let font = UIFont(name: fontType, size: CGFloat(fontSize)) {
            return font
        } else {
            return UIFont.systemFontOfSize(CGFloat(fontSize))
        }
    }
}
