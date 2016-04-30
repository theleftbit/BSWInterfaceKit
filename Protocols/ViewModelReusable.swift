//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public enum ReuseType {
    case NIB(UINib)
    case ClassReference(AnyClass)
}

public protocol ViewModelReusable {
    associatedtype T
    
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
    
    func configureFor(viewModel viewModel: T) -> Void
}

extension ViewModelReusable where Self: UICollectionViewCell {
    public static var reuseIdentifier: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public static var reuseType: ReuseType {
        return .ClassReference(Self)
    }
}
