//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

extension UIStackView {
    open func addArrangedSubview(_ subview: UIView, layoutMargins: UIEdgeInsets) {

        subview.translatesAutoresizingMaskIntoConstraints = false

        let dummyView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layoutMargins = layoutMargins
            return view
        }()

        dummyView.addSubview(subview)

        subview.topAnchor.constraint(equalTo: dummyView.layoutMarginsGuide.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: dummyView.layoutMarginsGuide.bottomAnchor).isActive = true

        //If the subview will be used for text layout, use readableContentGuide instead
        let layoutGuideX: UILayoutGuide
        if subview.isKind(of: UILabel.self) || subview.isKind(of: UITextView.self) {
            layoutGuideX = dummyView.readableContentGuide
        } else {
            layoutGuideX = dummyView.layoutMarginsGuide
        }

        subview.leadingAnchor.constraint(equalTo: layoutGuideX.leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: layoutGuideX.trailingAnchor).isActive = true

        addArrangedSubview(dummyView)
    }

    public func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
        }
    }
}
