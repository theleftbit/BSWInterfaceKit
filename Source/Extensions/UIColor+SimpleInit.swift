//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension UIColor {
    
    /**
     Initializes and returns a color object using the specified opacity and RGB component values.
     
     - parameter r: The red component of the color object, specified as a value from 0 to 255.
     - parameter g: The green component of the color object, specified as a value from 0 to 255.
     - parameter b: The blue component of the color object, specified as a value from 0 to 255.
     
     - returns: An initialized color object. The color information represented by this object is in the device RGB colorspace.
     */
    convenience init(r: Int, g: Int, b: Int) {
        self.init(
            red:CGFloat(r)/255.0,
            green:CGFloat(g)/255.0,
            blue:CGFloat(b)/255.0,
            alpha:1)
    }
    
    /**
     Initializes and returns a color object using the specified opacity and HSB component values.
     
     - parameter h: The hue component of the color object, specified as a value from 0 to 360.
     - parameter s: The saturation component of the color object, specified as a value from 0 to 100.
     - parameter b: The brightness component of the color object, specified as a value from 0 to 100.
     
     - returns: An initialized color object. The color information represented by this object is in the device HSB colorspace.
     */
    convenience init(h: Int, s: Int, b: Int) {
        self.init(
            hue:CGFloat(h)/360.0,
            saturation:CGFloat(s)/100.0,
            brightness:CGFloat(b)/100.0,
            alpha: 1)
    }
}
