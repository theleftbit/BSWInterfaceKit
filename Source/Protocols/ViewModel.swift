//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

//MARK:- Protocols

public protocol ViewModelConfigurable {
    associatedtype T
    func configureFor(viewModel viewModel: T) -> Void
}

public protocol ViewModelSettable: ViewModelConfigurable {
    var viewModel: T? { get set }
}

public protocol ViewModelReusable: ViewModelConfigurable {
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
}

//MARK:- Extensions

extension ViewModelReusable where Self: UICollectionViewCell {
    public static var reuseIdentifier: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public static var reuseType: ReuseType {
        return .ClassReference(Self)
    }
}

//MARK:- Types

public enum ReuseType {
    case NIB(UINib)
    case ClassReference(AnyClass)
}

