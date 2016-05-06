//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

public class ScrollableStackView: UIView {
    
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    public let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .Vertical
        return stackView
    }()
 
    public init() {
        super.init(frame: CGRectZero)
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.fillSuperview()
        stackView.fillSuperview()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}