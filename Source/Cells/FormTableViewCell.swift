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
        stackView.layoutMargins = FormTableViewCellAppearance.CellLayoutMargins
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(formInputView)
        stackView.addArrangedSubview(warningMessageLabel)
    }
}


public enum FormTableViewCellAppearance {
    public static var CellLayoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
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
        case telephone
        
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
                autocapitalizationType = .none
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
            case .telephone:
                placeholder = "telephone".localized
                textContentType = .telephoneNumber
                keyboardType = .phonePad
            case .unknown:
                break
            }
            
            isSecureTextEntry = textType.isPassword
        }
    }
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.EmptyColor
        return view
    }()
    
    private let separatorHeight: CGFloat = 2.0
    private var containsError = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        if let minHeight = Appearance.MinHeight {
            heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
        }
        addAutolayoutSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: separatorHeight),
            ])
        self.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc private func textDidChange() {
        guard containsError == false else { return }
        separatorLine.backgroundColor = (text == nil || text!.isEmpty) ? Appearance.EmptyColor : Appearance.CorrectColor
    }
    
    public struct VM {
        public let text: String?
        public let containsError: Bool
        public init(text: String?, containsError: Bool) {
            self.text = text
            self.containsError = containsError
        }
        
        enum State {
            case empty
            case error
            case filled
        }
        
        var state: State {
            guard !containsError else {
                return .error
            }
            
            guard let text = self.text, text.count > 0 else {
                return .empty
            }
            
            return .filled
        }
    }
    
    public func configureFor(viewModel: VM) {
        text = viewModel.text
        containsError = viewModel.containsError
        switch viewModel.state {
        case .empty:
            separatorLine.backgroundColor = Appearance.EmptyColor
        case .error:
            separatorLine.backgroundColor = Appearance.ErrorColor
        case .filled:
            separatorLine.backgroundColor = Appearance.CorrectColor
        }
    }
    
    public enum Appearance {
        public static var MinHeight: CGFloat?
        public static var EmptyColor = UIColor(white: 155.0 / 255.0, alpha: 1.0)
        public static var ErrorColor = UIColor.red
        public static var CorrectColor = UIColor.black
    }
}

// MARK: Appereance

