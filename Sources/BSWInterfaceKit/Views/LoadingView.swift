//
//  Created by Pierluigi Cifani on 29/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit

#if DEBUG
#if compiler(>=5.9)
#Preview {
    return LoadingView(loadingMessage: nil, activityIndicatorStyle: .large)
}
#endif
#endif

/// A simple view that represents the loading state in your app.
@objc(BSWLoadingView)
public class LoadingView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    public init(loadingMessage: NSAttributedString? = nil, activityIndicatorStyle: UIActivityIndicatorView.Style = .defaultStyle) {
        super.init(frame: .zero)
        self.addSubview(stackView)
        stackView.centerInSuperview()

        let activityIndicator = UIActivityIndicatorView(style: activityIndicatorStyle)
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

    public override var intrinsicContentSize: CGSize {
        return stackView.arrangedSubviews.count > 0 ? stackView.intrinsicContentSize : .zero
    }
}

#endif
