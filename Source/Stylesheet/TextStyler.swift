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
        
        fileprivate func toUIKit() -> String {
            switch self {
            case .title:
                return UIFontTextStyle.title1.rawValue
            case .headline:
                return UIFontTextStyle.headline.rawValue
            case .subheadline:
                return UIFontTextStyle.subheadline.rawValue
            case .body:
                return UIFontTextStyle.body.rawValue
            case .footnote:
                return UIFontTextStyle.footnote.rawValue
            }
        }
    }
    
    open static let styler = TextStyler()
    public init() {}
    open var preferredFontName: String?
    
    open func attributedString(_ string: String, color: UIColor = UIColor.black, forStyle style: Style = .body) -> NSAttributedString {
        
        let font = fontForStyle(style)
        
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
        ]
        
        return NSMutableAttributedString(string: string, attributes: attributes)
    }
    
    open func fontForStyle(_ style: Style) -> UIFont {
    
        let font: UIFont = {
            
            let systemFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: style.toUIKit()))
            
            guard let preferredFontName = preferredFontName,
                let font = UIFont(name: preferredFontName, size: systemFont.pointSize) else {
                    return systemFont
            }
            
            return font
        }()

        return font
    }
}
