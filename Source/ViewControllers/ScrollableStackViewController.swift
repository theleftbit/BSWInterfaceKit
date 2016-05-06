//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

public class ScrollableStackViewController: UIViewController {
    
    let scrollableStackView = ScrollableStackView()

    public override func loadView() {
        view = scrollableStackView
    }
}
