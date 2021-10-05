//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import BSWFoundation
import Task

//MARK:- Protocols

@available(swift, deprecated: 5.6, obsoleted: 6.0, message: "Please use BSWContentView instead")
public protocol ViewModelConfigurable: AnyObject {
    associatedtype VM
    func configureFor(viewModel: VM)
}

@available(swift, deprecated: 5.6, obsoleted: 6.0, message: "Please use BSWContentView instead")
public protocol ViewModelReusable: ViewModelConfigurable {
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
}

@available(swift, deprecated: 5.6, obsoleted: 6.0, message: "Please use BSWContentView instead")
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
