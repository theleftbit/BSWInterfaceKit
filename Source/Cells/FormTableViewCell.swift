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
        stackView.layoutMargins = FormTableViewAppearance.CellLayoutMargins
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(formInputView)
        stackView.addArrangedSubview(warningMessageLabel)
    }
}

// MARK: Standard input Views

extension FormTableViewCell {
    public class TextField: UITextField, ViewModelConfigurable {
        
        override public var intrinsicContentSize: CGSize {
            let superSize = super.intrinsicContentSize
            guard let minHeight = FormTableViewAppearance.TextFieldMinHeight else {
                return super.intrinsicContentSize
            }
            
            if superSize.height > minHeight {
                return superSize
            } else {
                return CGSize(width: UIView.noIntrinsicMetric, height: minHeight)
            }
        }
        
         public func configureFor(viewModel: String) {
            self.text = viewModel
        }
    }
}

public enum FormTableViewAppearance {
    static var CellLayoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    static var TextFieldMinHeight: CGFloat?
}
