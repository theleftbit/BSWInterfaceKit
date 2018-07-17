//
//  Created by Pierluigi Cifani on 30/03/2018.
//  Copyright © 2018 TheLeftBit. All rights reserved.
//

import UIKit

open class FormTableViewCell<InputView: ViewModelConfigurable & UIView>: UITableViewCell, ViewModelReusable {
    
    public struct VM {
        public let inputVM : InputView.VM
        public let warningMessage: NSAttributedString?
        public init(inputVM : InputView.VM, warningMessage: NSAttributedString?) {
            self.inputVM = inputVM
            self.warningMessage = warningMessage
        }
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
        warningMessageLabel.isHidden = (vm.warningMessage == nil)
        formInputView.configureFor(viewModel: vm.inputVM)
    }
    
    private func layout() {
        contentView.addAutolayoutSubview(stackView)
        stackView.pinToSuperview()
        stackView.layoutMargins = FormTableViewAppearance.CellLayoutMargins
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(formInputView)
        stackView.addArrangedSubview(warningMessageLabel)
    }
}

// MARK: Standard input Views

@available(iOS 10.0, *)
open class FormTextField: UITextField, ViewModelConfigurable {
    
    public enum TextType {
        case unknown
        case name
        case lastName
        case email
        case password
        case newPassword
        
        fileprivate var isPassword: Bool {
            switch self {
            case .newPassword, .password: return true
            default: return false
            }
        }
    }
    
    public var textType: TextType = .unknown {
        didSet {
            switch textType {
            case .name:
                placeholder = "name-placeholder".localized
                textContentType = .givenName
                keyboardType = .default
            case .lastName:
                placeholder = "lastname-placeholder".localized
                textContentType = .familyName
                keyboardType = .default
            case .email:
                placeholder = "email-placeholder".localized
                textContentType = .emailAddress
                keyboardType = .emailAddress
            case .password:
                placeholder = "password-placeholder".localized
                if #available(iOS 11.0, *) {
                    textContentType = .password
                }
            case .newPassword:
                placeholder = "password-placeholder".localized
                if #available(iOS 12.0, *) {
                    textContentType = .newPassword
                }
            case .unknown:
                break
            }
            
            isSecureTextEntry = textType.isPassword
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        guard let minHeight = FormTableViewAppearance.TextFieldMinHeight else {
            return
        }

        heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureFor(viewModel: String?) {
        self.text = viewModel
    }
}

// MARK: Appereance

public enum FormTableViewAppearance {
    public static var CellLayoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    public static var TextFieldMinHeight: CGFloat?
}
