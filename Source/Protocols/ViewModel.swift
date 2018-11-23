//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit
import BSWFoundation
import Deferred

//MARK:- Protocols

public protocol ViewModelConfigurable: class {
    associatedtype VM
    func configureFor(viewModel: VM)
    func configureFor(viewModel: VM, traitCollection: UITraitCollection)
}

public protocol ViewModelReusable: ViewModelConfigurable {
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
}

public extension ViewModelConfigurable {
    func configureFor(viewModel: VM, traitCollection: UITraitCollection) {
        configureFor(viewModel: viewModel)
    }
}

public protocol AsyncViewModelPresenter: ViewModelConfigurable {
    var dataProvider: Task<VM>! { get set }
}

//MARK:- Extensions

extension ViewModelReusable {
    public static var reuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!

    }
    public static var reuseType: ReuseType {
        return .classReference(self)
    }
}

//MARK:- Types

public enum ReuseType {
    case nib(UINib)
    case classReference(AnyClass)
}

