//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import BSWFoundation

/// This class allows you generate `NSAttributedString`s that respect the user's [Dynamic Type](https://developer.apple.com/documentation/uikit/uifont/scaling_fonts_automatically/) setting.
///
/// More info on how the fonts scale [here] (https://gist.github.com/zacwest/916d31da5d03405809c4)
open class TextStyler {
    
    /// Shared `TextStyler` that uses the system font.
    public static let styler = TextStyler(fontDescriptor: nil)
    
    /// Initializes the `TextStyler` with the given font name.
    convenience init(preferredFontName: String? = nil) {
        if let fontName = preferredFontName {
            self.init(fontDescriptor: .init(name: fontName, size: 0))
        } else {
            self.init(fontDescriptor: nil)
        }
    }
    public init(fontDescriptor: UIFontDescriptor? = nil) {
        self.fontDescriptor = fontDescriptor
    }

    public let fontDescriptor: UIFontDescriptor?
    
    /// This is how small you're willing to go in the font size.
    open var minContentSizeSupported = UIContentSizeCategory.small
    /// This is how big you're willing to go in the font size.
    open var maxContentSizeSupported = UIContentSizeCategory.extraExtraExtraLarge
    
    /// Generates an `NSAttributedString` with the given parameters
    /// - Parameters:
    ///   - string: The `String`
    ///   - color: The `Color`
    ///   - style: The `UIFont.TextStyle`
    /// - Returns: The `NSAttributedString`
    open func attributedString(_ string: String, color: UIColor? = nil, forStyle style: UIFont.TextStyle = .body) -> NSAttributedString {
        
        var attributes: [NSAttributedString.Key : Any] = [
            .font: fontForStyle(style)
        ]

        if let color = color {
            attributes[.foregroundColor] = color
        }
        
        return NSMutableAttributedString(string: string, attributes: attributes)
    }
    
    /// Generates a `UIFont` for a given `UIFont.TextStyle`
    open func fontForStyle(_ style: UIFont.TextStyle) -> UIFont {
    
        // Make sure the trait collection we apply
        // is within the user's accepted bounds
        let traitCollection: UITraitCollection? = {
            guard !UIApplication.shared.isRunningTests else { return nil }
            let userSelectedTrait = UIApplication.shared.preferredContentSizeCategory
            if userSelectedTrait < minContentSizeSupported {
                return UITraitCollection(preferredContentSizeCategory: minContentSizeSupported)
            } else if userSelectedTrait > maxContentSizeSupported {
                return UITraitCollection(preferredContentSizeCategory: maxContentSizeSupported)
            } else {
                return nil
            }
        }()
        let systemFont = UIFont.preferredFont(forTextStyle: style, compatibleWith: traitCollection)
        if let fontDescriptor = fontDescriptor {
            let font = UIFont.init(descriptor: fontDescriptor, size: systemFont.pointSize)
            let metrics = UIFontMetrics(forTextStyle: style)
            return metrics.scaledFont(for: font, compatibleWith: traitCollection)
        } else {
            return systemFont
        }
    }
}

#endif
