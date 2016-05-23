//
//  Created by Pierluigi Cifani on 17/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation
import ObjectiveC

public typealias ButtonActionHandler = Void -> Void

public struct ButtonConfiguration {
    public let title: NSAttributedString
    public let backgroundColor: UIColor
    public let contentInset: UIEdgeInsets
    public let actionHandler: ButtonActionHandler
    
    public init(title: NSAttributedString,
                backgroundColor: UIColor = UIColor.blueColor(),
                contentInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                actionHandler: ButtonActionHandler) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.actionHandler = actionHandler
        self.contentInset = contentInset
    }
}

extension UIButton {
    
    private struct AssociatedObjects {
        static var ActionBlockWrapper = "ActionBlockWrapper"
    }
    
    private class ActionBlockWrapper : NSObject {
        var block : ButtonActionHandler
        init(block: ButtonActionHandler) {
            self.block = block
        }
    }
    
    public convenience init(buttonConfiguration: ButtonConfiguration) {
        self.init()
        setButtonConfiguration(buttonConfiguration)
    }
    
    public func setButtonConfiguration(buttonConfiguration: ButtonConfiguration) {
        setAttributedTitle(buttonConfiguration.title, forState: .Normal)
        backgroundColor = buttonConfiguration.backgroundColor
        contentEdgeInsets = buttonConfiguration.contentInset
        objc_setAssociatedObject(self, &AssociatedObjects.ActionBlockWrapper, ActionBlockWrapper(block: buttonConfiguration.actionHandler), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        addTarget(self, action: #selector(handleTap), forControlEvents: .TouchDown)
    }
    
    func handleTap() {
        guard let wrapper = objc_getAssociatedObject(self, &AssociatedObjects.ActionBlockWrapper) as? ActionBlockWrapper else { return }
        wrapper.block()
    }
}