//
//  UIImage+InterfaceKit.swift
//  Created by Pierluigi Cifani on 22/04/16.
//

#if canImport(UIKit)

import UIKit
import BSWInterfaceKitObjC

public extension UIImage {
    
    enum Template: String {
        case plusRound = "plus.circle"
        case cancelRound = "xmark.circle"
        case close = "xmark"
        case camera = "camera"
        case rectangle = "rectangle.fill"
        case checkmark = "checkmark"
    }
    
    /**
     Generates an UIImage a template image hosted by BSWInterfaceKit
     
     - parameter template: The template image
     
     - returns: The UIImage based on the template
     */
    static func templateImage(_ template: Template) -> UIImage {
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

    /**
     Redraws the `UIImage` to the given size. Use this method
     to redraw big PDF based images to smaller sizes and force
     a smaller `intrinsicContentSize` to the host `UIImageView`
     
     - parameter newSize: The new size of the image
     
     - returns: The resized UIImage
     */
    func scaleTo(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }

    @available(iOS, deprecated: 13.0, obsoleted: 14.0, message: "This will be removed in iOS 14; please migrate to a different API.")
    func tint(_ tintColor: UIColor) -> UIImage {
        return modifiedImage { context, rect in
            context.setBlendMode(.multiply)
            context.clip(to: rect, mask: self.cgImage!)
            tintColor.setFill()
            context.fill(rect)
        }
    }
    
    private class func interfaceKitImageNamed(_ name: String, compatibleWithTraitCollection: UITraitCollection? = nil) -> UIImage? {
        if #available(iOS 13.0, tvOS 13.0, *) {
            return UIImage(systemName: name, compatibleWith: compatibleWithTraitCollection)
        } else {
            let bundle = Bundle.main
            return UIImage(named: name, in: bundle, compatibleWith: compatibleWithTraitCollection)
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

#endif
