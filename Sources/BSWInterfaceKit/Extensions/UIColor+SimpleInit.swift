//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import UIKit

extension UIColor {
    
    /**
     Initializes and returns a color given the current trait environment, but if,
     iOS 13 is not available it'll return the light color.
     
     - parameter light: The version of the color to use with `UIUserInterfaceStyle.light`.
     - parameter dark: The version of the color to use with `UIUserInterfaceStyle.dark`.
     */
    convenience init(light: UIColor, dark: UIColor) {
        if #available(iOS 13.0, *) {
            self.init(dynamicProvider: { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return dark
                default:
                    return light
                }
            })
        } else {
            self.init(cgColor: light.cgColor)
        }
    }

    /**
     Initializes and returns a color object using the specified opacity and RGB component values.
     
     - parameter r: The red component of the color object, specified as a value from 0 to 255.
     - parameter g: The green component of the color object, specified as a value from 0 to 255.
     - parameter b: The blue component of the color object, specified as a value from 0 to 255.
     
     - returns: An initialized color object. The color information represented by this object is in the device RGB colorspace.
     */
    convenience public init(r: Int, g: Int, b: Int) {
        self.init(
            red: CGFloat(r)/255.0,
            green: CGFloat(g)/255.0,
            blue: CGFloat(b)/255.0,
            alpha:1
        )
    }
    
    /**
     Initializes and returns a color object using the specified opacity and HSB component values.
     
     - parameter h: The hue component of the color object, specified as a value from 0 to 360.
     - parameter s: The saturation component of the color object, specified as a value from 0 to 100.
     - parameter b: The brightness component of the color object, specified as a value from 0 to 100.
     
     - returns: An initialized color object. The color information represented by this object is in the device HSB colorspace.
     */
    convenience public init(h: Int, s: Int, b: Int) {
        self.init(
            hue: CGFloat(h)/360.0,
            saturation: CGFloat(s)/100.0,
            brightness: CGFloat(b)/100.0,
            alpha: 1
        )
    }

    convenience public init(rgb: UInt, alphaVal: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alphaVal
        )
    }

    public class func randomColor() -> UIColor {
        return RandomColorFactory.randomColor()
    }
}

#endif
