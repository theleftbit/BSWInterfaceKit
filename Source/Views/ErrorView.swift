//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

open class ErrorView: UIView {
    
    private enum Constants {
        static let Spacing: CGFloat = 10
    }
        
    fileprivate let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.Spacing
        return stackView
    }()
    
    public convenience init(listConfig: ActionableListConfiguration) {
        self.init(title: listConfig.title, message: listConfig.message, image: listConfig.image, buttonConfiguration: listConfig.buttonConfiguration)
    }
    
    public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, buttonConfiguration: ButtonConfiguration? = nil) {
        super.init(frame: .zero)
        self.addAutolayoutSubview(stackView)
        stackView.pinToSuperview()

        if let image = image {
            let imageView = UIImageView(image: image)
            stackView.addArrangedSubview(imageView)
        }

        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = title
        stackView.addArrangedSubview(label)

        if let message = message {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.attributedText = message
            stackView.addArrangedSubview(label)
        }

        if let buttonConfiguration = buttonConfiguration {
            let button = UIButton(buttonConfiguration: buttonConfiguration)
            stackView.addArrangedSubview(button)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
