//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

@objc(BSWErrorView)
open class ErrorView: UIStackView {

    public struct Configuration {
        public let title: NSAttributedString
        public let message: NSAttributedString?
        public let image: UIImage?
        public let buttonConfiguration: ButtonConfiguration?
        
        public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, buttonConfiguration: ButtonConfiguration? = nil) {
            self.title = title
            self.message = message
            self.image = image
            self.buttonConfiguration = buttonConfiguration
        }
        
        func viewRepresentation() -> UIView {
            return ErrorView(config: self)
        }
    }

    private enum Constants {
        static let Spacing: CGFloat = 10
    }
    
    public convenience init(config: Configuration) {
        self.init(title: config.title, message: config.message, image: config.image, buttonConfiguration: config.buttonConfiguration)
    }
    
    public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, buttonConfiguration: ButtonConfiguration? = nil) {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .center
        spacing = Constants.Spacing
        
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
        
        if let buttonConfiguration = buttonConfiguration {
            let button = UIButton(buttonConfiguration: buttonConfiguration)
            addArrangedSubview(button)
        }
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
