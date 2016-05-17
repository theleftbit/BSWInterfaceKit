//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

public class ErrorView: UIView {
    
    var onButtonTap: ButtonActionHandler?
    var shouldCollapse = false
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 10
        return stackView
    }()
    
    public init(errorMessage: NSAttributedString? = nil, buttonConfiguration: ButtonConfiguration) {
        super.init(frame: CGRectZero)
        self.addSubview(stackView)
        
        constrain(stackView) { stackView in
            stackView.centerX == stackView.superview!.centerX
            stackView.centerY == stackView.superview!.centerY
        }
        
        let label = UILabel()
        label.attributedText = errorMessage
        
        let button = UIButton(buttonConfiguration: buttonConfiguration)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if CGRectGetHeight(self.bounds) < CGRectGetWidth(self.bounds) && shouldCollapse {
            stackView.axis = .Horizontal
        }
    }
}