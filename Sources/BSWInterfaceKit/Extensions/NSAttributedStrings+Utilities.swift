//
//  Created by Pierluigi Cifani on 01/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import UIKit

public enum AttributedStringSpacing {
    case simple
    case double
    
    fileprivate var attString: NSAttributedString {
        switch self {
        case .simple:
            return NSAttributedString(string: "\n")
        case .double:
            return NSAttributedString(string: "\n\n")
        }
    }
}

public extension Collection where Iterator.Element : NSAttributedString {
    
    func joinedStrings(spacing: AttributedStringSpacing = .simple) -> NSAttributedString {
        
        //This makes me puke, but hey, choose your battles

        var extraDetailsString: NSMutableAttributedString? = nil

        self.forEach { (string) in
            if let extraDetailsString_ = extraDetailsString {
                let sumString = extraDetailsString_ + spacing.attString + string
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

    func modifyingFont(_ newFont: UIFont, onSubstring: String? = nil) -> NSAttributedString {
        let string = self.mutableCopy() as! NSMutableAttributedString
        let range: NSRange = {
            if let substring = onSubstring, let nsRange = nsRangeFor(substring: substring) { return nsRange }
            else { return NSRange(location: 0, length: string.length) }
        }()
        string.enumerateAttributes(in: range, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            guard let font = value[NSAttributedString.Key.font] as? UIFont else { return }
            let finalNewFont = font.isBold ? newFont.bolded() : newFont
            string.addAttribute(.font, value: finalNewFont, range: range)
        }
        return string
    }

    func modifyingColor(_ newColor: UIColor, onSubstring: String? = nil) -> NSAttributedString {
        let string = self.mutableCopy() as! NSMutableAttributedString
        let range: NSRange = {
            if let substring = onSubstring, let nsRange = nsRangeFor(substring: substring) { return nsRange }
            else { return NSRange(location: 0, length: string.length) }
        }()
        string.removeAttribute(.foregroundColor, range: range)
        string.addAttribute(.foregroundColor, value: newColor, range: range)
        return string
    }

    func modifyingBackgroundColor(_ newColor: UIColor, onSubstring: String? = nil) -> NSAttributedString {
        let string = self.mutableCopy() as! NSMutableAttributedString
        let range: NSRange = {
            if let substring = onSubstring, let nsRange = nsRangeFor(substring: substring) { return nsRange }
            else { return NSRange(location: 0, length: string.length) }
        }()
        string.removeAttribute(.backgroundColor, range: range)
        string.addAttribute(.backgroundColor, value: newColor, range: range)
        return string
    }

    var bolded: NSAttributedString {
        return bolding(substring: self.string)
    }

    func bolding(substring: String) -> NSAttributedString {
        guard let nsRange = nsRangeFor(substring: substring) else {
            return self
        }
        guard let font = self.attributes(at: 0, longestEffectiveRange: nil, in: nsRange)[.font] as? UIFont else {
            return self
        }
        return modifyingFont(font.bolded(), onSubstring: substring)
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

    func settingParagraphStyle(_ style: (NSMutableParagraphStyle) -> ()) -> NSAttributedString {
        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        let p = NSMutableParagraphStyle()
        style(p)
        mutableCopy.setParagraphStyle(p)
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

    func settingLineHeightMultiplier(_ multiplier: CGFloat) -> NSAttributedString {
        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        mutableCopy.setLineHeightMultiplier(multiplier)
        return mutableCopy
    }
    
    func addingLink(onSubstring substring: String, linkURL: URL, linkColor: UIColor?, isUnderlined: Bool = false)  -> NSAttributedString {
        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        var linkCustomAttributes: [NSAttributedString.Key : Any] = [
            .attachment: linkURL
        ]
        if let linkColor = linkColor {
            linkCustomAttributes[.foregroundColor] = linkColor
        }
        if isUnderlined {
            linkCustomAttributes[.underlineColor] = linkColor
            linkCustomAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        mutableCopy.addAttributes(onSubstring: substring, attrs: linkCustomAttributes)
        return mutableCopy
    }
}

public extension NSAttributedString {
    ///https://stackoverflow.com/a/45161058
    convenience init(withIcon iconImage: UIImage, forFont titleFont: UIFont) {
        let icon = NSTextAttachment()
        icon.bounds = CGRect(x: 0, y: (titleFont.capHeight - iconImage.size.height).rounded() / 2, width: iconImage.size.width, height: iconImage.size.height)
        icon.image = iconImage
        self.init(attachment: icon)
    }
}


public extension NSAttributedString {
    func nsRangeFor(substring: String) -> NSRange? {
        guard let range = self.string.range(of: substring) else { return nil }
        let lowerBound = range.lowerBound.utf16Offset(in: self.string)
        let upperBound = range.upperBound.utf16Offset(in: self.string)
        return NSRange(location: lowerBound, length: upperBound - lowerBound)
    }
}

public extension NSMutableAttributedString {

    func addAttributes(onSubstring substring: String, attrs: [NSAttributedString.Key : Any]) {
        guard let range = self.nsRangeFor(substring: substring) else { fatalError() }
        self.addAttributes(attrs, range: range)
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
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byTruncatingTail //We always want this
        setParagraphStyle(paragraphStyle)
    }

    func setLineHeightMultiplier(_ multiplier: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = multiplier
        setParagraphStyle(paragraphStyle)
    }
}

#endif
