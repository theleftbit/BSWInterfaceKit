//
//  Created by Pierluigi Cifani on 02/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

class BSWCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
