//
//  Created by Pierluigi Cifani on 13/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

extension UILabel {

    public static func unlimitedLinesLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }
}
