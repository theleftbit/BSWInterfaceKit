//
//  NSAttributedStrings+Utilities.swift
//  Pods
//
//  Created by Pierluigi Cifani on 01/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

// concatenate attributed strings
func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.appendAttributedString(left)
    result.appendAttributedString(right)
    return result
}
