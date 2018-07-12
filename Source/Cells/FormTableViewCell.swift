//
//  Created by Pierluigi Cifani on 30/03/2018.
//  Copyright © 2018 TheLeftBit. All rights reserved.
//

import UIKit

open class FormTableViewCell<InputView: ViewModelConfigurable & UIView>: UITableViewCell, ViewModelReusable {
    
    public struct VM {
        let inputVM : InputView.VM
        let warningMessage: NSAttributedString?
    }
    
    public let formInputView: InputView
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let warningMessageLabel = UILabel.unlimitedLinesLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.formInputView = InputView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureFor(viewModel vm: VM) {
        warningMessageLabel.attributedText = vm.warningMessage
        warningMessageLabel.isHidden = (vm.warningMessage != nil)
        formInputView.configureFor(viewModel: vm.inputVM)
    }
    
    private func layout() {
        contentView.addAutolayoutSubview(stackView)
        stackView.pinToSuperview()
        stackView.layoutMargins = Constants.Margins
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(formInputView)
        stackView.addArrangedSubview(warningMessageLabel)
    }
}

private enum Constants {
    static let Margins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
}


// MARK: Standard input Views

import UIKit

public protocol TextInputViewDelegate: class {
    func didModifyText(text: String, textInputView: TextInputView)
}

open class TextInputView: UIView, ViewModelConfigurable {
    
    public struct VM {
        let text: String?
    }
    
    public let textField = UITextField.autolayoutTextFieldWith(textStyle: .body, placeholderText: "")
    
    weak var delegate: TextInputViewDelegate?
    
    public var placeholder: String? {
        set {
            textField.placeholder = newValue
        }
        get {
            return textField.placeholder
        }
    }
    
    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        textField.delegate = self
    }
    
    private func layout() {
        addAutolayoutSubview(textField)
        textField.pinToSuperview()
    }
    
    public func configureFor(viewModel vm: TextInputView.VM) {
        textField.text = vm.text
    }
}

extension TextInputView: UITextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.didModifyText(text: textField.text ?? "", textInputView: self)
    }
}
