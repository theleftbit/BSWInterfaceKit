//
//  Created by Pierluigi Cifani on 02/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

open class BSWCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
