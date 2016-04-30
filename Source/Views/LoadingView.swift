//
//  Created by Pierluigi Cifani on 29/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

public class LoadingView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 10
        return stackView
    }()
    
    public init(loadingMessage: NSAttributedString?, activityIndicatorStyle: UIActivityIndicatorViewStyle = .Gray) {
        super.init(frame: CGRectZero)
        self.addSubview(stackView)
        constrain(stackView) { stackView in
            stackView.centerX == stackView.superview!.centerX
            stackView.centerY == stackView.superview!.centerY
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorStyle)
        activityIndicator.startAnimating()
        stackView.addArrangedSubview(activityIndicator)

        if let loadingMessage = loadingMessage {
            let label = UILabel()
            label.attributedText = loadingMessage
            stackView.addArrangedSubview(label)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
