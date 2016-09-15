//
//  Created by Pierluigi Cifani on 25/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

class LoginButton: UIButton {
    
    init(title: String, target: AnyObject, selector: Selector, color: UIColor) {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: UIControlState())
        addTarget(target, action: selector, for: UIControlEvents.touchDown)
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 50)
    }
}
