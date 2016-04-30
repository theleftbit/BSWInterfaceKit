//
//  NSBundle+InterfaceKit.swift
//  Pods
//
//  Created by Pierluigi Cifani on 25/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension NSBundle {

    class func interfaceKitBundle() -> NSBundle {
        return InterfaceBundle.bundle
    }
}

private struct InterfaceBundle {
    private static let bundle = NSBundle(forClass: InterfaceKit.self)
    private class InterfaceKit: NSObject {}
}
