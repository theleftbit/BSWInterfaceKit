//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

open class TextStyler {
    
    public enum Style {
        case title
        case headline
        case subheadline
        case body
        case footnote
        
        fileprivate func toUIKit() -> UIFontTextStyle {
            switch self {
            case .title:
                return UIFontTextStyle.title1
            case .headline:
                return UIFontTextStyle.headline
            case .subheadline:
                return UIFontTextStyle.subheadline
            case .body:
                return UIFontTextStyle.body
            case .footnote:
                return UIFontTextStyle.footnote
            }
        }
    }
    
    public static let styler = TextStyler()
    public init() {}
    open var preferredFontName: String?
    
    open func attributedString(_ string: String, color: UIColor = UIColor.black, forStyle style: Style = .body) -> NSAttributedString {
        
        let font = fontForStyle(style)
        
        let attributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: color,
        ]
        
        return NSMutableAttributedString(string: string, attributes: attributes)
    }
    
    open func fontForStyle(_ style: Style) -> UIFont {
    
        let uikitStyle = style.toUIKit()
        let systemFont = UIFont.preferredFont(forTextStyle: uikitStyle)
        guard
            let preferredFontName = preferredFontName,
            let font = UIFont(name: preferredFontName, size: systemFont.pointSize) else {
                return systemFont
        }

        if #available(iOS 11.0, *) {
            let metrics = UIFontMetrics(forTextStyle: uikitStyle)
            return metrics.scaledFont(for: font)
        } else {
            return font
        }
    }
}
