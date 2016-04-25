//
//  UIImage+InterfaceKit.swift
//  Created by Pierluigi Cifani on 22/04/16.
//

import Foundation

extension UIImage {

    public class func interfaceKitImageNamed(name: String, compatibleWithTraitCollection: UITraitCollection? = nil) -> UIImage? {
        return UIImage(
            named: name,
            inBundle: InterfaceBundle.bundle,
            compatibleWithTraitCollection: compatibleWithTraitCollection
        )
    }
}


//Due to some Cocoapods limitations, there is no way of adding resources directly to a framework. This sucks.
private struct InterfaceBundle {
    private static let bundle = NSBundle(forClass: InterfaceKit.self)
    private class InterfaceKit: NSObject {}
}
