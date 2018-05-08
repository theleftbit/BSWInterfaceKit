//
//  Created by Pierluigi Cifani on 02/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

open class BSWCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
