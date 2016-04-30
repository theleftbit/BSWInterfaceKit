//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension UIButton {
    func configureAsCheckbox() {
        self.contentMode = .ScaleAspectFit
        self.setImage(UIImage(named: "ic_checkbox"), forState: .Normal)
        self.setImage(UIImage(named: "ic_checkbox_selected"), forState: .Selected)
    }
}
