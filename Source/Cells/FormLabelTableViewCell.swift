//
//  Created by Pierluigi Cifani on 10/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

public class FormLabelTableViewCell: UITableViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Left
        return label
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.textAlignment = .Right
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
    
    private func setup() {
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
    
    public func configureFor(title title: NSAttributedString, value: NSAttributedString) {
        titleLabel.attributedText = title
        textField.attributedText = value
        titleLabel.sizeToFit()
    }
    
    public func setKeyboardType(type: UIKeyboardType) {
        textField.keyboardType = type
    }
    
    public override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}