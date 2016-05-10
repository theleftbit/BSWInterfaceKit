//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public class TextStyler {
    
    public enum Style {
        case Title
        case Headline
        case Subheadline
        case Body
        case Footnote
        
        private func toUIKit() -> String {
            switch self {
            case .Title:
                return UIFontTextStyleTitle1
            case .Headline:
                return UIFontTextStyleHeadline
            case .Subheadline:
                return UIFontTextStyleSubheadline
            case .Body:
                return UIFontTextStyleBody
            case .Footnote:
                return UIFontTextStyleFootnote
            }
        }
    }
    
    public static let styler = TextStyler()
    public var preferredFontName: String?
    
    public func attributedString(string: String, forStyle style: Style = .Body) -> NSAttributedString {
        
        let font = fontForStyle(style)
        
        let fontAttribute = [
            NSFontAttributeName: font
        ]
        
        return NSMutableAttributedString(string: string, attributes: fontAttribute)
    }
    
    public func fontForStyle(style: Style) -> UIFont {
    
        let font: UIFont = {
            
            let systemFont = UIFont.preferredFontForTextStyle(style.toUIKit())
            
            guard let preferredFontName = preferredFontName,
                let font = UIFont(name: preferredFontName, size: systemFont.pointSize) else {
                    return systemFont
            }
            
            return font
        }()

        return font
    }
}