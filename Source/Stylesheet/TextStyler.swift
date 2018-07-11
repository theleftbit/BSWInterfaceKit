//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
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
                if #available(iOS 11.0, *) {
                    return .largeTitle
                } else {
                    return .title1
                }
            case .headline:
                return .headline
            case .subheadline:
                return .subheadline
            case .body:
                return .body
            case .footnote:
                return .footnote
            }
        }
    }
    
    public static let styler = TextStyler()
    public init() {}
    open var preferredFontName: String?
    
    open func attributedString(_ string: String, color: UIColor? = nil, forStyle style: Style = .body) -> NSAttributedString {
        
        var attributes: [NSAttributedStringKey : Any] = [
            .font: fontForStyle(style)
        ]

        if let color = color {
            attributes[.foregroundColor] = color
        }
        
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
