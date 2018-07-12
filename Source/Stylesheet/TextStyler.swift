//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

open class TextStyler {
    
    // https://gist.github.com/zacwest/916d31da5d03405809c4
    
    public static let styler = TextStyler()
    public init() {}
    open var preferredFontName: String?
    
    open func attributedString(_ string: String, color: UIColor? = nil, forStyle style: UIFont.TextStyle = .body) -> NSAttributedString {
        
        var attributes: [NSAttributedString.Key : Any] = [
            .font: fontForStyle(style)
        ]

        if let color = color {
            attributes[.foregroundColor] = color
        }
        
        return NSMutableAttributedString(string: string, attributes: attributes)
    }
    
    open func fontForStyle(_ style: UIFont.TextStyle) -> UIFont {
    
        let systemFont = UIFont.preferredFont(forTextStyle: style)
        guard
            let preferredFontName = preferredFontName,
            let font = UIFont(name: preferredFontName, size: systemFont.pointSize) else {
                return systemFont
        }

        if #available(iOS 11.0, *) {
            let metrics = UIFontMetrics(forTextStyle: style)
            return metrics.scaledFont(for: font)
        } else {
            return font
        }
    }
}
