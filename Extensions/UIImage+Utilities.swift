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
}
