//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

open class ErrorView: UIView {
    
    var onButtonTap: ButtonActionHandler?
    var shouldCollapse = false
    
    fileprivate let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    public init(errorMessage: NSAttributedString? = nil, buttonConfiguration: ButtonConfiguration) {
        super.init(frame: .zero)
        self.addAutolayoutSubview(stackView)
        stackView.centerInSuperview()
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -10)
            ])
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = errorMessage
        
        let button = UIButton(buttonConfiguration: buttonConfiguration)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.height < self.bounds.width && shouldCollapse {
            stackView.axis = .horizontal
        }
    }
}
