//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

open class ScrollableStackViewController: UIViewController {
    
    open var scrollableStackView = ScrollableStackView()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollableStackView)
        scrollableStackView.fillSuperview()
    }
}
