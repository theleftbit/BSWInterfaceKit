//
//  Created by Pierluigi Cifani on 10/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

open class FormLabelTableViewCell: UITableViewCell {

    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let textField: UITextField = {
        let field = UITextField()
        field.textAlignment = .right
        return field
    }()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    fileprivate func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        constrain(titleLabel, textField) { titleLabel, textField in
            titleLabel.centerY == titleLabel.superview!.centerY
            titleLabel.leadingMargin == titleLabel.superview!.leadingMargin
            textField.centerY == titleLabel.centerY
            textField.trailingMargin == textField.superview!.trailingMargin
            titleLabel.trailing == textField.leading - 5
            textField.width >= textField.superview!.width / 3
        }
    }
    
    open func configureFor(title: NSAttributedString, value: NSAttributedString) {
        titleLabel.attributedText = title
        textField.attributedText = value
        titleLabel.sizeToFit()
    }
    
    open func setKeyboardType(_ type: UIKeyboardType) {
        textField.keyboardType = type
    }
    
    open override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}
