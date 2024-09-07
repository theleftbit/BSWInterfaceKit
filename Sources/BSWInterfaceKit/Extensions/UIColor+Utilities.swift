//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit.UIColor)

import UIKit

public extension UIColor {
    
    #if os(watchOS)
    #else
    /**
     Initializes and returns a color given the current trait environment.
     
     - parameter light: The version of the color to use with `UIUserInterfaceStyle.light`.
     - parameter dark: The version of the color to use with `UIUserInterfaceStyle.dark`.
     */
    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        })
    }

    /// Returns the opposed color for the current interface style
    /// For example: on a `UIUserInterfaceStyle.light`, for
    /// `UIColor.systemBackground`  it'll return black.
    func invertedForUserInterfaceStyle() -> UIColor {
        UIColor { [unowned self] traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return self.resolvedColor(with: .init(userInterfaceStyle: .light))
            case .light:
                return self.resolvedColor(with: .init(userInterfaceStyle: .dark))
            case .unspecified:
                fallthrough
            @unknown default:
                return self
            }
        }
    }
    #endif
    /**
     Initializes and returns a color object using the specified opacity and RGB component values.
     
     - parameter r: The red component of the color object, specified as a value from 0 to 255.
     - parameter g: The green component of the color object, specified as a value from 0 to 255.
     - parameter b: The blue component of the color object, specified as a value from 0 to 255.
     
     - returns: An initialized color object. The color information represented by this object is in the device RGB colorspace.
     */
    convenience init(r: Int, g: Int, b: Int) {
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
    convenience init(h: Int, s: Int, b: Int) {
        self.init(
            hue: CGFloat(h)/360.0,
            saturation: CGFloat(s)/100.0,
            brightness: CGFloat(b)/100.0,
            alpha: 1
        )
    }

    convenience init(rgb: UInt, alphaVal: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alphaVal
        )
    }
    
    /// Creates a random color using `RandomColorFactory`
    /// - Returns: a `UIColor`
    class func randomColor() -> UIColor {
        return RandomColorFactory.randomColor()
    }
}

#elseif canImport(AppKit)

import AppKit

public extension NSColor {
    /// Creates a random color using `RandomColorFactory`
    /// - Returns: a `NSColor`
    class func randomColor() -> NSColor {
        return RandomColorFactory.randomColor()
    }
}

#endif
