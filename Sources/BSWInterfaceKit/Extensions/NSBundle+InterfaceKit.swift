//
//  NSBundle+InterfaceKit.swift
//  Pods
//
//  Created by Pierluigi Cifani on 25/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

extension Bundle {
    class func interfaceKitBundle() -> Bundle {
        let frameworkBundle = Bundle.init(for: InterfaceKit.self)
        if let url = Bundle.main.url(forResource: "BSWInterfaceKitAssets", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        } else if let url = frameworkBundle.url(forResource: "BSWInterfaceKitAssets", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        } else {
            fatalError()
        }
    }
}

private class InterfaceKit: NSObject {}
