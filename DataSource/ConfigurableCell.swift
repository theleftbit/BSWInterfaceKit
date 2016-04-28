//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public enum CellReuseType {
    case NIB(UINib)
    case ClassReference(AnyClass)
}

public protocol ConfigurableCell {
    typealias T
    
    static var reuseType: CellReuseType { get }
    static var reuseIdentifier: String { get }
    
    func configureFor(viewModel viewModel: T) -> Void
}

extension ConfigurableCell where Self: UICollectionViewCell {
    public static var reuseIdentifier: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}

