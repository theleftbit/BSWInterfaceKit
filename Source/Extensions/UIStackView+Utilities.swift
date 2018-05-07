//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

extension UIStackView {
    @objc(bsw_addArrangedSubview:layoutMargins:)
    public func addArrangedSubview(_ subview: UIView, layoutMargins: UIEdgeInsets) {

        let dummyView = StackSpacingView(layoutMargins: layoutMargins)
        dummyView.addAutolayoutSubview(subview)

        //If the subview will be used for text layout, use readableContentGuide instead
        let layoutGuide: UILayoutGuide = dummyView.layoutMarginsGuide
        // There seems to be some kind of issue with readableContentGuide in beta 1
        /*
        if subview.isKind(of: UILabel.self) || subview.isKind(of: UITextView.self) {
            layoutGuide = dummyView.readableContentGuide
        } else {
            layoutGuide = dummyView.layoutMarginsGuide
        }
         */
        subview.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true

        addArrangedSubview(dummyView)
    }

    @objc(bsw_removeAllArrangedSubviews)
    public func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
        }
    }

    @objc(BSWStackSpacingView)
    private class StackSpacingView: UIView {
        init(layoutMargins: UIEdgeInsets) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 11.0, *) {
                self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: layoutMargins.top, leading: layoutMargins.left, bottom: layoutMargins.bottom, trailing: layoutMargins.right)
            } else {
                self.layoutMargins = layoutMargins
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
