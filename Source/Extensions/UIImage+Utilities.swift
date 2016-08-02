//
//  UIImage+InterfaceKit.swift
//  Created by Pierluigi Cifani on 22/04/16.
//

import Foundation

extension UIImage {

    public class func interfaceKitImageNamed(name: String, compatibleWithTraitCollection: UITraitCollection? = nil) -> UIImage? {
        return UIImage(
            named: name,
            inBundle: NSBundle.interfaceKitBundle(),
            compatibleWithTraitCollection: compatibleWithTraitCollection
        )
    }

    public enum Template: String {
        case Plus = "Plus"
        case Close = "Close"
    }
    
    public class func templateImage(template: Template) -> UIImage {
        return UIImage.interfaceKitImageNamed(template.rawValue)!
    }
    
    /**
     Generates an UIImage from a CAGradientLayer
     
     - parameter gradientLayer: The defined gradient layer
     
     - returns: The UIImage based on the gradient layer
     */
    static public func image(fromGradientLayer gradientLayer: CAGradientLayer) -> UIImage {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
