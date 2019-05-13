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
    
    convenience init?(html: String) {
        guard let data = html.data(using: .utf16, allowLossyConversion: false) else {
            return nil
        }
        
        guard let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf16.rawValue], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString: attributedString)
    }

    func modifyingFont(_ newFont: UIFont) -> NSAttributedString {
        let string = self.mutableCopy() as! NSMutableAttributedString
        let range = NSRange(location: 0, length: string.length)
        string.removeAttribute(.font, range: range)
        string.addAttribute(.font, value: newFont, range: range)
        return string
    }
    
    var bolded: NSAttributedString {
        let range = NSRange(location: 0, length: self.length)
        let font = self.attributes(at: 0, longestEffectiveRange: nil, in: range)[.font] as! UIFont
        return modifyingFont(font.bolded)
    }
    
    func setAttachmentWidth(_ width: CGFloat) {
        enumerateAttribute(.attachment, in: NSRange(location: 0, length: length), options: [], using: { (value, range, stop) in
            guard let attachment = value as? NSTextAttachment else { return }
            attachment.setImageWidth(width: width)
        })
    }
    
    func settingKern(_ kern: CGFloat) -> NSAttributedString {
        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        mutableCopy.setKern(kern)
        return mutableCopy
    }

    func settingParagraphStyle(_ style: NSParagraphStyle) -> NSAttributedString {
        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        mutableCopy.setParagraphStyle(style)
        return mutableCopy
    }

    func settingLineSpacing(_ lineSpacing: CGFloat) -> NSAttributedString {
        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        mutableCopy.setLineSpacing(lineSpacing)
        return mutableCopy
    }

    func settingLineHeight(_ lineHeight: CGFloat) -> NSAttributedString {
        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        mutableCopy.setLineHeight(lineHeight)
        return mutableCopy
    }

}

private extension NSTextAttachment {
    func setImageWidth(width: CGFloat) {
        let ratio = bounds.size.width / bounds.size.height
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: width, height: width / ratio)
    }
}

public extension NSMutableAttributedString {
    func addLink(onSubstring substring: String, linkURL: URL, linkColor: UIColor? = nil) {
        guard let range = self.string.range(of: substring) else { fatalError() }
        let lowerBound = range.lowerBound.utf16Offset(in: self.string)
        let upperBound = range.upperBound.utf16Offset(in: self.string)
        self.addAttribute(.link, value: linkURL, range: NSRange(location: lowerBound, length: upperBound - lowerBound))
        if let color = linkColor {
            self.addAttribute(.foregroundColor, value: color, range: NSRange(location: lowerBound, length: upperBound - lowerBound))
        }
    }

    func setKern(_ kern: CGFloat) {
        self.addAttributes([.kern: kern], range: NSRange(location: 0, length: self.length))
    }
    
    func setParagraphStyle(_ style: NSParagraphStyle) {
        self.addAttributes([.paragraphStyle: style], range: NSRange(location: 0, length: self.length))
    }
    
    func setLineSpacing(_ lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = .byTruncatingTail //We always want this
        setParagraphStyle(paragraphStyle)
    }

    func setLineHeight(_ lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byTruncatingTail //We always want this
        setParagraphStyle(paragraphStyle)
    }
}
