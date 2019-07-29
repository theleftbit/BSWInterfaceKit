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
            return UIImage(bezierPathStroke: UIBezierPath.named(name: name))
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

private extension UIBezierPath {
    static func named(name: String) -> UIBezierPath {
        switch name {
        case "checkmark":
            let path = UIBezierPath(rect: CGRect(x: 0.000000, y: 0.000000, width: 12.791016, height: 12.773438))
            path.move(to: CGPoint(x: 4.746094, y: 0.000000))
            path.addQuadCurve(to: CGPoint(x: 5.103516, y: 0.087891), controlPoint: CGPoint(x: 4.945312, y: 0.000000))
            path.addQuadCurve(to: CGPoint(x: 5.373047, y: 0.345703), controlPoint: CGPoint(x: 5.261719, y: 0.175781))
            path.addLine(to: CGPoint(x: 12.632812, y: 11.718750))
            path.addQuadCurve(to: CGPoint(x: 12.755859, y: 11.964844), controlPoint: CGPoint(x: 12.720703, y: 11.853516))
            path.addQuadCurve(to: CGPoint(x: 12.791016, y: 12.181641), controlPoint: CGPoint(x: 12.791016, y: 12.076172))
            path.addQuadCurve(to: CGPoint(x: 12.629883, y: 12.612305), controlPoint: CGPoint(x: 12.791016, y: 12.451172))
            path.addQuadCurve(to: CGPoint(x: 12.205078, y: 12.773438), controlPoint: CGPoint(x: 12.468750, y: 12.773438))
            path.addQuadCurve(to: CGPoint(x: 11.894531, y: 12.700195), controlPoint: CGPoint(x: 12.017578, y: 12.773438))
            path.addQuadCurve(to: CGPoint(x: 11.660156, y: 12.445312), controlPoint: CGPoint(x: 11.771484, y: 12.626953))
            path.addLine(to: CGPoint(x: 4.716797, y: 1.464844))
            path.addLine(to: CGPoint(x: 1.166016, y: 5.976562))
            path.addQuadCurve(to: CGPoint(x: 0.615234, y: 6.287109), controlPoint: CGPoint(x: 0.937500, y: 6.287109))
            path.addQuadCurve(to: CGPoint(x: 0.172852, y: 6.120117), controlPoint: CGPoint(x: 0.345703, y: 6.287109))
            path.addQuadCurve(to: CGPoint(x: 0.000000, y: 5.689453), controlPoint: CGPoint(x: 0.000000, y: 5.953125))
            path.addQuadCurve(to: CGPoint(x: 0.046875, y: 5.458008), controlPoint: CGPoint(x: 0.000000, y: 5.578125))
            path.addQuadCurve(to: CGPoint(x: 0.187500, y: 5.220703), controlPoint: CGPoint(x: 0.093750, y: 5.337891))
            path.addLine(to: CGPoint(x: 4.083984, y: 0.357422))
            path.addQuadCurve(to: CGPoint(x: 4.746094, y: 0.000000), controlPoint: CGPoint(x: 4.371094, y: 0.000000))
            path.close()
            return path
        case "rectangle.fill":
            let path = UIBezierPath(rect: CGRect(x: 0.000000, y: 0.000000, width: 17.753906, height: 13.769531))
            path.move(to: CGPoint(x: 2.285156, y: 0.000000))
            path.addLine(to: CGPoint(x: 15.474609, y: 0.000000))
            path.addQuadCurve(to: CGPoint(x: 17.182617, y: 0.568359), controlPoint: CGPoint(x: 16.611328, y: 0.000000))
            path.addQuadCurve(to: CGPoint(x: 17.753906, y: 2.255859), controlPoint: CGPoint(x: 17.753906, y: 1.136719))
            path.addLine(to: CGPoint(x: 17.753906, y: 11.513672))
            path.addQuadCurve(to: CGPoint(x: 17.182617, y: 13.201172), controlPoint: CGPoint(x: 17.753906, y: 12.632812))
            path.addQuadCurve(to: CGPoint(x: 15.474609, y: 13.769531), controlPoint: CGPoint(x: 16.611328, y: 13.769531))
            path.addLine(to: CGPoint(x: 2.285156, y: 13.769531))
            path.addQuadCurve(to: CGPoint(x: 0.574219, y: 13.204102), controlPoint: CGPoint(x: 1.148438, y: 13.769531))
            path.addQuadCurve(to: CGPoint(x: 0.000000, y: 11.513672), controlPoint: CGPoint(x: 0.000000, y: 12.638672))
            path.addLine(to: CGPoint(x: 0.000000, y: 2.255859))
            path.addQuadCurve(to: CGPoint(x: 0.574219, y: 0.565430), controlPoint: CGPoint(x: 0.000000, y: 1.130859))
            path.addQuadCurve(to: CGPoint(x: 2.285156, y: 0.000000), controlPoint: CGPoint(x: 1.148438, y: 0.000000))
            path.close()
            return path
        default:
            fatalError()
        }
    }
}
