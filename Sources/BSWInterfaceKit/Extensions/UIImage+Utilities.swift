//
//  UIImage+InterfaceKit.swift
//  Created by Pierluigi Cifani on 22/04/16.
//

import UIKit
import BSWInterfaceKitObjC

public extension UIImage {

    class func interfaceKitImageNamed(_ name: String, compatibleWithTraitCollection: UITraitCollection? = nil) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: name, compatibleWith: compatibleWithTraitCollection)
        } else {
            return nil
        }
    }

    enum Template: String {
        case plusRound = "plus.circle"
        case cancelRound = "xmark.circle"
        case close = "xmark"
        case camera = "camera"
    }
    
    class func templateImage(_ template: Template) -> UIImage {
        return UIImage.interfaceKitImageNamed(template.rawValue)!
    }
    
    /**
     Generates an UIImage from a CAGradientLayer
     
     - parameter gradientLayer: The defined gradient layer
     
     - returns: The UIImage based on the gradient layer
     */
    static func image(fromGradientLayer gradientLayer: CAGradientLayer) -> UIImage {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    @available(iOS, deprecated: 13.0, obsoleted: 14.0, message: "This will be removed in 14.0b; please migrate to a different API.")
    func tint(_ tintColor: UIColor) -> UIImage {
        return modifiedImage { context, rect in
            context.setBlendMode(.multiply)
            context.clip(to: rect, mask: self.cgImage!)
            tintColor.setFill()
            context.fill(rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return newImage
    }
}
