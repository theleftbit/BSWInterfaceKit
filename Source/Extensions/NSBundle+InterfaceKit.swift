//
//  NSBundle+InterfaceKit.swift
//  Pods
//
//  Created by Pierluigi Cifani on 25/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

extension Bundle {
    class func interfaceKitBundle() -> Bundle {
        return Bundle.init(for: InterfaceKit.self)
    }
}

fileprivate class InterfaceKit: NSObject {}
