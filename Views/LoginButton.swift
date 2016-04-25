//
//  Created by Pierluigi Cifani on 25/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

class LoginButton: UIButton {
    
    init(title: String, target: AnyObject, selector: Selector, color: UIColor) {
        super.init(frame: CGRectZero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, forState: .Normal)
        addTarget(target, action: selector, forControlEvents: UIControlEvents.TouchDown)
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, 50)
    }
    
}