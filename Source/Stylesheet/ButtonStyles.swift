//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension UIButton {
    func configureAsCheckbox() {
        self.contentMode = .scaleAspectFit
        self.setImage(UIImage(named: "ic_checkbox"), for: UIControlState())
        self.setImage(UIImage(named: "ic_checkbox_selected"), for: .selected)
    }
}
