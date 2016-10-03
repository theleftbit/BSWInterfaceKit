//
//  NSBundle+InterfaceKit.swift
//  Pods
//
//  Created by Pierluigi Cifani on 25/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension Bundle {

    class func interfaceKitBundle() -> Bundle {
        return InterfaceBundle.bundle
    }
}

private struct InterfaceBundle {
    fileprivate static let bundle = Bundle(for: InterfaceKit.self)
    fileprivate class InterfaceKit: NSObject {}
}
