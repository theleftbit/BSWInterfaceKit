//
//  NSAttributedStrings+Utilities.swift
//  Pods
//
//  Created by Pierluigi Cifani on 01/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

extension Collection where Iterator.Element : NSAttributedString {

    func joinedStrings() -> NSAttributedString {
        
        //This makes me puke, but hey, choose your battles

        var extraDetailsString: NSMutableAttributedString? = nil

        self.forEach { (string) in
            if let extraDetailsString_ = extraDetailsString {
                let sumString = extraDetailsString_ + NSAttributedString(string: "\n") + string
                extraDetailsString = sumString.mutableCopy() as? NSMutableAttributedString
            } else {
                extraDetailsString = string.mutableCopy() as? NSMutableAttributedString
            }
        }
        
        return extraDetailsString!
    }
}

// concatenate attributed strings
public func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}

public extension NSAttributedString {
    func bolded() -> NSAttributedString {
        let string = self.mutableCopy() as! NSMutableAttributedString
        let range = NSRange(location: 0, length: string.length)
        let font = string.attributes(at: 0, longestEffectiveRange: nil, in: range)[.font] as! UIFont
        let boldFont = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: font.pointSize)
        string.removeAttribute(.font, range: range)
        string.addAttribute(.font, value: boldFont, range: range)
        return string
    }
}
