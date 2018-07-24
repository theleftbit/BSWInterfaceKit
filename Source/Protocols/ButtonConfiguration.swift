//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation
import ObjectiveC

public enum ButtonTitle {
    case text(NSAttributedString)
    case image(UIImage)
}

public typealias ButtonActionHandler = () -> ()

public struct ButtonConfiguration {
    public let buttonTitle: ButtonTitle
    public let backgroundColor: UIColor
    public let contentInset: UIEdgeInsets
    public let actionHandler: ButtonActionHandler

    public init(title: String,
                titleColor: UIColor? = nil,
                backgroundColor: UIColor = .clear,
                contentInset: UIEdgeInsets = UIEdgeInsets(uniform: 5),
                actionHandler: @escaping ButtonActionHandler) {
        let tintColor = titleColor ?? UIApplication.shared.keyWindow!.tintColor
        self.buttonTitle = .text(TextStyler.styler.attributedString(title, color: tintColor))
        self.backgroundColor = backgroundColor
        self.actionHandler = actionHandler
        self.contentInset = contentInset
    }

    public init(buttonTitle: ButtonTitle,
                backgroundColor: UIColor = .clear,
                contentInset: UIEdgeInsets = UIEdgeInsets(uniform: 5),
                actionHandler: @escaping ButtonActionHandler) {
        self.buttonTitle = buttonTitle
        self.backgroundColor = backgroundColor
        self.actionHandler = actionHandler
        self.contentInset = contentInset
    }
}

private class ActionBlockWrapper : NSObject {
    var block : ButtonActionHandler
    init(block: @escaping ButtonActionHandler) {
        self.block = block
    }
}

extension UIButton {
    
    fileprivate struct AssociatedObjects {
        static var ActionBlockWrapper = "ActionBlockWrapper"
    }
    
    public convenience init(buttonConfiguration: ButtonConfiguration) {
        self.init()
        setButtonConfiguration(buttonConfiguration)
    }
    
    public func setButtonConfiguration(_ buttonConfiguration: ButtonConfiguration) {
        
        switch buttonConfiguration.buttonTitle {
        case .text(let title):
            setAttributedTitle(title, for: .normal)
        case .image(let image):
            setImage(image, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            imageEdgeInsets = UIEdgeInsets(uniform: -5)
        }
        
        backgroundColor = buttonConfiguration.backgroundColor
        contentEdgeInsets = buttonConfiguration.contentInset
        objc_setAssociatedObject(self, &AssociatedObjects.ActionBlockWrapper, ActionBlockWrapper(block: buttonConfiguration.actionHandler), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc func handleTap() {
        guard let wrapper = objc_getAssociatedObject(self, &AssociatedObjects.ActionBlockWrapper) as? ActionBlockWrapper else { return }
        wrapper.block()
    }
}

extension UIBarButtonItem {

    fileprivate struct AssociatedObjects {
        static var ActionBlockWrapper = "ActionBlockWrapper"
    }

    public convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, actionHandler: @escaping ButtonActionHandler) {
        self.init(barButtonSystemItem:systemItem, target:nil, action: #selector(handleTap))
        objc_setAssociatedObject(self, &AssociatedObjects.ActionBlockWrapper, ActionBlockWrapper(block: actionHandler), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        self.target = self
        self.action = #selector(handleTap)
    }
    
    @objc func handleTap() {
        guard let wrapper = objc_getAssociatedObject(self, &AssociatedObjects.ActionBlockWrapper) as? ActionBlockWrapper else { return }
        wrapper.block()
    }
}
