//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import BSWFoundation

@objc(BSWErrorView)
open class ErrorView: UIStackView {

    public struct Configuration {
        public let title: NSAttributedString
        public let message: NSAttributedString?
        public let image: UIImage?
        public let button: UIButton?
        
        public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, buttonConfiguration: ButtonConfiguration? = nil) {
            self.title = title
            self.message = message
            self.image = image
            if let buttonConfiguration = buttonConfiguration {
                self.button = UIButton(buttonConfiguration: buttonConfiguration)
            } else {
                self.button = nil
            }
        }

        public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, button: UIButton? = nil) {
            self.title = title
            self.message = message
            self.image = image
            self.button = button
        }

        public func viewRepresentation() -> UIView {
            return ErrorView(config: self)
        }
    }
    
    public enum Appereance {
        static public var Spacing: CGFloat = 10
    }

    public convenience init(config: Configuration) {
        self.init(title: config.title, message: config.message, image: config.image, button: config.button)
    }

    public convenience init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, buttonConfiguration: ButtonConfiguration? = nil) {
        if let buttonConfiguration = buttonConfiguration {
            self.init(title: title, message: message, image: image, button: UIButton(buttonConfiguration: buttonConfiguration))
        } else {
            self.init(title: title, message: message, image: image, button: nil)
        }
    }
    
    public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, button: UIButton? = nil) {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .center
        spacing = Appereance.Spacing
        
        if let image = image {
            let imageView = UIImageView(image: image)
            addArrangedSubview(imageView)
        }
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = title
        addArrangedSubview(label)
        
        if let message = message {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.attributedText = message
            addArrangedSubview(label)
        }
        
        if let button = button {
            addArrangedSubview(button)
        }
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func retryView(message: String, error: Error, onRetry: @escaping VoidHandler) -> ErrorView {
        ErrorView(
            title: TextStyler.styler.attributedString(message),
            message: TextStyler.styler.attributedString(error.localizedDescription),
            buttonConfiguration: .init(title: "retry".localized, actionHandler: onRetry)
        )
    }
}
#endif
