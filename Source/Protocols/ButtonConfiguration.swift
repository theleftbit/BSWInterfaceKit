//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation
import ObjectiveC

public enum ButtonTitle {
    case text(NSAttributedString)
    case image(UIImage)
    case textAndImage(NSAttributedString, UIImage)
}

public typealias ButtonActionHandler = () -> ()

public struct ButtonConfiguration {
    public let buttonTitle: ButtonTitle
    public let backgroundColor: UIColor
    public let contentInset: UIEdgeInsets
    public let cornerRadius: CGFloat
    public let actionHandler: ButtonActionHandler
    
    public init(title: String,
                titleColor: UIColor? = nil,
                backgroundColor: UIColor = .clear,
                contentInset: UIEdgeInsets = UIEdgeInsets(uniform: 5),
                cornerRadius: CGFloat = 0,
                actionHandler: @escaping ButtonActionHandler) {
        let tintColor = titleColor ?? UIApplication.shared.keyWindow!.tintColor
        self.buttonTitle = .text(TextStyler.styler.attributedString(title, color: tintColor))
        self.backgroundColor = backgroundColor
        self.actionHandler = actionHandler
        self.contentInset = contentInset
        self.cornerRadius = cornerRadius
    }

    public init(buttonTitle: ButtonTitle,
                backgroundColor: UIColor = .clear,
                contentInset: UIEdgeInsets = UIEdgeInsets(uniform: 5),
                cornerRadius: CGFloat = 0,
                actionHandler: @escaping ButtonActionHandler) {
        self.buttonTitle = buttonTitle
        self.backgroundColor = backgroundColor
        self.actionHandler = actionHandler
        self.contentInset = contentInset
        self.cornerRadius = cornerRadius
    }
}

private class ActionBlockWrapper : NSObject {
    var block : ButtonActionHandler
    init(block: @escaping ButtonActionHandler) {
        self.block = block
    }
}

extension UIButton {
    
    private struct AssociatedObjects {
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
        case let .textAndImage(title, image):
            setImage(image, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            setAttributedTitle(title, for: .normal)
        }
        layer.cornerRadius = buttonConfiguration.cornerRadius
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

    private struct AssociatedObjects {
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
