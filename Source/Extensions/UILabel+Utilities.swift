//
//  Created by Pierluigi Cifani on 13/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

extension UILabel {

    public static func unlimitedLinesLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }
}