//
//  UIImage+InterfaceKit.swift
//  Created by Pierluigi Cifani on 22/04/16.
//

import Foundation

extension UIImage {

    public class func interfaceKitImageNamed(_ name: String, compatibleWithTraitCollection: UITraitCollection? = nil) -> UIImage? {
        return UIImage(
            named: name,
            in: Bundle.interfaceKitBundle(),
            compatibleWith: compatibleWithTraitCollection
        )
    }

    public enum Template: String {
        case plusRound = "PlusRound"
        case cancelRound = "CancelRound"
        case close = "Close"
    }
    
    public class func templateImage(_ template: Template) -> UIImage {
        return UIImage.interfaceKitImageNamed(template.rawValue)!
    }
    
    /**
     Generates an UIImage from a CAGradientLayer
     
     - parameter gradientLayer: The defined gradient layer
     
     - returns: The UIImage based on the gradient layer
     */
    static public func image(fromGradientLayer gradientLayer: CAGradientLayer) -> UIImage {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
