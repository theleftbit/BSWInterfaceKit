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
        return InterfaceBundle.bundle
    }
}

private struct InterfaceBundle {
    fileprivate static let bundle: Bundle = {
        let podBundle = Bundle(for: InterfaceKit.self)
        let url = podBundle.url(forResource: "BSWInterfaceKit", withExtension: "bundle")!
        return Bundle(url: url)!
    }()
    fileprivate class InterfaceKit: NSObject {}
}
