//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import BSWFoundation
import Task

//MARK:- Protocols

@available(*, deprecated, message: "Plase use BSWContentView instead")
public protocol ViewModelConfigurable: AnyObject {
    associatedtype VM
    func configureFor(viewModel: VM)
}

public protocol ViewModelReusable: ViewModelConfigurable {
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
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

#endif
